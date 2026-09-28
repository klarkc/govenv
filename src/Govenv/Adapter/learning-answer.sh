#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

key="${1:-}"
if [[ -z "$key" ]]; then
  echo "usage: govenv-learning answer <prompt-key>" >&2
  exit 2
fi

build_dir=".govenv/learning-answer-build"
rm -rf "$build_dir"
mkdir -p "$build_dir"
agda -i . -i src --compile --compile-dir="$build_dir"   src/Govenv/Adapter/LearningPromptCatalog.agda >/dev/null

catalog="$("$build_dir/LearningPromptCatalog")"
line="$(
  printf '%s' "$catalog" |
    awk -F '	' -v wanted="$key" '
      $1 == wanted { print; found = 1; exit }
      END { if (!found) exit 7 }
    '
)" || {
  echo "Unknown learning prompt key: $key" >&2
  echo "Run 'govenv-learning bootstrap' or 'govenv-learning catch-up' to see available keys." >&2
  exit 2
}

IFS=$'	' read -r prompt_key claim source_revision challenge <<< "$line"

evidence_file="Govenv/LearningEvidence.lagda.md"
if grep -Fq -- "$claim" "$evidence_file"; then
  echo "Learning evidence for '$prompt_key' is already recorded."
  exit 0
fi

default_principal="$(git config user.email 2>/dev/null || true)"
if [[ -z "$default_principal" ]]; then
  default_principal="$(git config user.name 2>/dev/null || true)"
fi

principal="${GOVENV_HUMAN_PRINCIPAL:-}"
if [[ -z "$principal" ]]; then
  if [[ ! -t 0 ]]; then
    echo "Set GOVENV_HUMAN_PRINCIPAL when recording evidence non-interactively." >&2
    exit 2
  fi
  printf 'Human principal identity [%s]: ' "$default_principal"
  IFS= read -r entered_principal
  principal="${entered_principal:-$default_principal}"
fi

if [[ -z "$principal" ]]; then
  echo "A human principal identity is required." >&2
  exit 2
fi

printf '%s
' "Learning prompt: $prompt_key"
printf '%s
' "Requirement: $claim"
printf '%s
' "Bound revision: $source_revision"
printf '%s

' "Challenge: $challenge"

response=""
if [[ -n "${GOVENV_LEARNING_RESPONSE_FILE:-}" ]]; then
  response="$(cat "$GOVENV_LEARNING_RESPONSE_FILE")"
elif [[ ! -t 0 ]]; then
  response="$(cat)"
else
  response_file="$(mktemp)"
  trap 'rm -f "$response_file"' EXIT
  {
    printf '%s
' "# Govenv learning response"
    printf '%s
' "# Prompt key: $prompt_key"
    printf '%s
' "# Challenge: $challenge"
    printf '%s
' "# Write your response below. Lines beginning with # are ignored."
    printf '
'
  } > "$response_file"
  "${EDITOR:-vi}" "$response_file"
  response="$(
    awk '
      /^#/ { next }
      { lines[++count] = $0 }
      END {
        first = 1
        while (first <= count && lines[first] == "") first++
        last = count
        while (last >= first && lines[last] == "") last--
        for (i = first; i <= last; i++) print lines[i]
      }
    ' "$response_file"
  )"
  rm -f "$response_file"
  trap - EXIT
fi

if [[ -z "${response//[[:space:]]/}" ]]; then
  echo "Learning response must not be empty." >&2
  exit 2
fi

principal_literal="$(printf '%s' "$principal" | jq -Rs .)"
claim_literal="$(printf '%s' "$claim" | jq -Rs .)"
source_literal="$(printf '%s' "$source_revision" | jq -Rs .)"
challenge_literal="$(printf '%s' "$challenge" | jq -Rs .)"
response_literal="$(printf '%s' "$response" | jq -Rs .)"

block_file="$(mktemp)"
output_file="$(mktemp)"
backup_file="$(mktemp)"
trap 'rm -f "$block_file" "$output_file" "$backup_file"' EXIT
cp "$evidence_file" "$backup_file"

cat > "$block_file" <<EOF
  demonstratedLearning
    (learningRequirement $claim_literal $source_literal)
    (claimedHumanPrincipal $principal_literal)
    $challenge_literal
    $response_literal
  ∷
EOF

awk -v block_file="$block_file" '
  /govenv-learning-evidence:start/ { inside = 1 }
  inside && /^  \[\]$/ {
    while ((getline line < block_file) > 0) print line
    close(block_file)
  }
  { print }
  /govenv-learning-evidence:end/ { inside = 0 }
' "$evidence_file" > "$output_file"

mv "$output_file" "$evidence_file"

typecheck_log="$(mktemp)"
if ! agda -i . -i src Govenv/Learning.lagda.md >"$typecheck_log" 2>&1; then
  cp "$backup_file" "$evidence_file"
  cat "$typecheck_log" >&2
  rm -f "$typecheck_log"
  echo "Generated learning evidence did not typecheck; restored the previous file." >&2
  exit 5
fi
rm -f "$typecheck_log"

printf '
Recorded candidate human learning evidence for %s.
' "$prompt_key"
printf 'Review the exact diff before committing it:

'
git diff -- "$evidence_file"
printf '
This evidence becomes authoritative only through the normal reviewed pull-request merge.
'
