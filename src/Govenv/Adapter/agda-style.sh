#!/usr/bin/env bash
set -euo pipefail

baseline_catalogued=3
baseline_checked=3
custom_enabled=3
custom_checked=3
hard_failures=0
advisories=0

printf '%s\n' 'govenv-agda-style-v1'
printf '%s\n' 'baseline-source agda-stdlib/doc/style-guide.md'
printf '%s\n' 'baseline-inventory partial'
printf 'baseline-rules catalogued=%d checked=%d total=unknown\n' \
  "$baseline_catalogued" "$baseline_checked"
printf 'custom-rules enabled=%d checked=%d\n' "$custom_enabled" "$custom_checked"
printf 'mechanism-rules lint=%d formatter=%d both=%d manual=%d\n' \
  "$((baseline_checked + custom_checked - 1))" 1 0 0
printf 'total-rules catalogued=%d checked=%d coverage=partial\n' \
  "$((baseline_catalogued + custom_enabled))" \
  "$((baseline_checked + custom_checked))"

agda_files=()
while IFS= read -r -d '' file; do
  agda_files+=("$file")
done < <(find Govenv src/Govenv -type f \
  \( -name '*.agda' -o -name '*.lagda.md' \) -print0 | sort -z)

code_lines() {
  local file="$1"
  case "$file" in
    *.lagda.md)
      awk '
        /^\`\`\`agda[[:space:]]*$/ { in_agda = 1; next }
        /^\`\`\`[[:space:]]*$/ && in_agda { in_agda = 0; next }
        in_agda { print }
      ' "$file"
      ;;
    *)
      cat "$file"
      ;;
  esac
}

for file in "${agda_files[@]}"; do
  while IFS= read -r line; do
    if [[ "$line" =~ [[:blank:]]+$ ]]; then
      printf 'error govenv-no-trailing-whitespace %s\n' "$file" >&2
      hard_failures=$((hard_failures + 1))
      break
    fi
    if [ "${#line}" -gt 72 ]; then
      advisories=$((advisories + 1))
    fi
    if [[ "$line" == *'⦃'* || "$line" == *'⦄'* ]]; then
      printf 'error stdlib-no-unicode-instance-braces %s\n' "$file" >&2
      hard_failures=$((hard_failures + 1))
      break
    fi
  done < <(code_lines "$file")

  if code_lines "$file" | grep -Eq '^[[:space:]]*mutual([[:space:]]|$)'; then
    printf 'error stdlib-no-mutual-block %s\n' "$file" >&2
    hard_failures=$((hard_failures + 1))
  fi
done

while IFS= read -r -d '' file; do
  if ! grep -Fq '{-# OPTIONS --safe #-}' "$file"; then
    printf 'error govenv-safe-formal-source %s\n' "$file" >&2
    hard_failures=$((hard_failures + 1))
  fi
done < <(
  {
    find Govenv -type f -name '*.lagda.md' -print0
    find src/Govenv/Kernel -type f -name '*.agda' -print0
  } | sort -z
)

while IFS= read -r -d '' file; do
  if grep -Eq '^[[:space:]]*postulate([[:space:]]|$)' "$file"; then
    printf 'error govenv-no-kernel-postulate %s\n' "$file" >&2
    hard_failures=$((hard_failures + 1))
  fi
done < <(find src/Govenv/Kernel -type f -name '*.agda' -print0 | sort -z)

printf 'advisory stdlib-line-length-72 violations=%d\n' "$advisories"
printf 'result hard-failures=%d\n' "$hard_failures"

if [ "$hard_failures" -ne 0 ]; then
  exit 1
fi
