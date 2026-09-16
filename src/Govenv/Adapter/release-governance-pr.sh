#!/usr/bin/env bash
set -euo pipefail

placement_counterexample="${GOVENV_RELEASE_PLACEMENT_COUNTEREXAMPLE:-}"
history_counterexample="${GOVENV_RELEASE_HISTORY_COUNTEREXAMPLE:-}"
push_auth_counterexample="${GOVENV_RELEASE_PUSH_AUTH_COUNTEREXAMPLE:-}"
rebase_provenance_counterexample="${GOVENV_RELEASE_REBASE_PROVENANCE_COUNTEREXAMPLE:-}"
release_pr="${GOVENV_RELEASE_PR:-${1:-}}"
if [[ -z "${placement_counterexample}" ]] &&
   [[ -z "${history_counterexample}" ]] &&
   [[ -z "${push_auth_counterexample}" ]] &&
   [[ -z "${rebase_provenance_counterexample}" ]] &&
   [[ -z "${release_pr}" || ! "${release_pr}" =~ ^[0-9]+$ ]]; then
  echo "GOVENV_RELEASE_PR or the first argument must be a pull request number." >&2
  exit 2
fi

root="$(git rev-parse --show-toplevel)"
cd "${root}"
source src/Govenv/Adapter/revision-provenance.sh

write_git_askpass() {
  local target="$1"
  cat > "${target}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  *Username*) printf '%s\n' 'x-access-token' ;;
  *Password*) printf '%s\n' "${GH_TOKEN:?GH_TOKEN is required}" ;;
  *) exit 1 ;;
esac
EOF
  chmod 700 "${target}"
}

git_with_github_token() {
  local repository="$1"
  shift
  local askpass
  local status=0

  : "${GH_TOKEN:?GH_TOKEN is required for authenticated Git mutation}"
  askpass="$(mktemp)"
  write_git_askpass "${askpass}"
  BASH_ENV=/dev/null GH_TOKEN="${GH_TOKEN}" GIT_ASKPASS="${askpass}" GIT_TERMINAL_PROMPT=0 \
    git -C "${repository}" -c credential.helper= "$@" || status=$?
  rm -f "${askpass}"
  return "${status}"
}

extract_section() {
  awk '
    /<!-- govenv-governance-impact:start -->/ { capture = 1 }
    capture { print }
    /<!-- govenv-governance-impact:end -->/ { exit }
  ' "$1"
}

extract_section_release_heading() {
  awk '
    /^## \[/ { heading = $0 }
    /<!-- govenv-governance-impact:start -->/ { print heading; exit }
  ' "$1"
}

extract_section_at_release() {
  local document="$1"
  local version="$2"

  awk -v version="${version}" '
    BEGIN { heading = "## [" version "]" }
    /^## \[/ { in_target = index($0, heading) == 1 }
    in_target && /<!-- govenv-governance-impact:start -->/ { capture = 1 }
    in_target && capture { print }
    in_target && capture && /<!-- govenv-governance-impact:end -->/ { exit }
  ' "${document}"
}


extract_release_entry() {
  local document="$1"
  local version="$2"

  awk -v version="${version}" '
    BEGIN { heading = "## [" version "]" }
    /^## \[/ {
      if (capture) exit
      if (index($0, heading) == 1) capture = 1
    }
    capture { print }
  ' "${document}"
}

extract_candidate_notes() {
  local document="$1"
  local version="$2"

  awk -v version="${version}" '
    BEGIN { heading = "## [" version "]" }
    /^## \[/ {
      if (in_target) exit
      if (index($0, heading) == 1) {
        in_target = 1
        next
      }
    }
    !in_target { next }
    /^---$/ { exit }
    /<!-- govenv-governance-impact:start -->/ { governance = 1; next }
    governance && /<!-- govenv-governance-impact:end -->/ { governance = 0; next }
    governance { next }
    { lines[++count] = $0 }
    END {
      first = 1
      while (first <= count && lines[first] == "") first++
      last = count
      while (last >= first && lines[last] == "") last--
      for (i = first; i <= last; i++) print lines[i]
    }
  ' "${document}"
}

release_section_shape() {
  local document="$1"
  local version="$2"

  awk -v version="${version}" '
    BEGIN { heading = "## [" version "]" }
    /^## \[/ {
      in_target = index($0, heading) == 1
      if (in_target) headings++
      next
    }
    in_target && /<!-- govenv-governance-impact:start -->/ { starts++ }
    in_target && /<!-- govenv-governance-impact:end -->/ { ends++ }
    END { printf "%d:%d:%d\n", headings, starts, ends }
  ' "${document}"
}

materialize_section_at_release() {
  local input="$1"
  local section="$2"
  local version="$3"
  local output="$4"

  awk -v section="${section}" -v version="${version}" '
    function load_section( line) {
      while ((getline line < section) > 0) desired = desired line "\n"
      close(section)
    }
    function emit_section() {
      printf "%s", desired
    }
    BEGIN {
      heading = "## [" version "]"
      load_section()
    }
    {
      if (!capture && $0 ~ /^## \[/) {
        in_target = index($0, heading) == 1
        if (in_target) {
          target_headings++
          if (!inserted) {
            print
            print ""
            emit_section()
            print ""
            inserted = 1
            next
          }
        }
      }

      if (!capture && $0 ~ /<!-- govenv-governance-impact:start -->/) {
        capture = 1
        captured_in_target = in_target
        block = $0 "\n"
        next
      }

      if (capture) {
        block = block $0 "\n"
        if ($0 ~ /<!-- govenv-governance-impact:end -->/) {
          if (!captured_in_target && block != desired) printf "%s", block
          capture = 0
          captured_in_target = 0
          block = ""
        }
        next
      }

      print
    }
    END {
      if (capture) exit 43
      if (!inserted || target_headings != 1) exit 42
    }
  ' "${input}" > "${output}"
}

matching_section_count() {
  local document="$1"
  local section="$2"

  awk -v section="${section}" '
    function load_section( line) {
      while ((getline line < section) > 0) desired = desired line "\n"
      close(section)
    }
    BEGIN { load_section() }
    /<!-- govenv-governance-impact:start -->/ {
      capture = 1
      block = $0 "\n"
      next
    }
    capture {
      block = block $0 "\n"
      if ($0 ~ /<!-- govenv-governance-impact:end -->/) {
        if (block == desired) matches++
        capture = 0
        block = ""
      }
    }
    END { print matches + 0 }
  ' "${document}"
}

verify_section_at_release() {
  local document="$1"
  local section="$2"
  local version="$3"
  local label="$4"
  local matching_count
  local observed
  local shape

  shape="$(release_section_shape "${document}" "${version}")"
  if [[ "${shape}" != "1:1:1" ]]; then
    echo "${label} governance release-section shape verification failed: ${shape}." >&2
    echo "Expected release ${version} to contain exactly one heading and one marker pair." >&2
    return 5
  fi

  observed="$(mktemp)"
  extract_section_at_release "${document}" "${version}" > "${observed}"
  if ! cmp -s "${section}" "${observed}"; then
    echo "${label} governance read-back verification failed for release ${version}." >&2
    diff -u "${section}" "${observed}" >&2 || true
    rm -f "${observed}"
    return 5
  fi
  rm -f "${observed}"

  matching_count="$(matching_section_count "${document}" "${section}")"
  if [[ "${matching_count}" != "1" ]]; then
    echo "${label} governance target-section cardinality verification failed: ${matching_count}." >&2
    echo "Expected the release-specific governance section exactly once in the document." >&2
    return 5
  fi
}

if [[ -n "${rebase_provenance_counterexample}" ]]; then
  if [[ ! -f "${rebase_provenance_counterexample}" ]]; then
    echo "Release rebase provenance counterexample does not exist: ${rebase_provenance_counterexample}" >&2
    exit 2
  fi
  if ! grep -Fq 'Materialize run #39' "${rebase_provenance_counterexample}" ||
     ! grep -Fq 'f86ee5870abf527b4f065f827277be701f131441' "${rebase_provenance_counterexample}"; then
    echo "Release rebase provenance fixture no longer preserves the observed regression." >&2
    exit 3
  fi

  regression_tmp="$(mktemp -d)"
  trap 'rm -rf "${regression_tmp}"' EXIT
  git -C "${regression_tmp}" init -q
  git -C "${regression_tmp}" config user.name counterexample
  git -C "${regression_tmp}" config user.email counterexample@example.invalid
  printf '%s\n' base > "${regression_tmp}/state"
  git -C "${regression_tmp}" add state
  git -C "${regression_tmp}" commit -q -m 'base'
  regression_base="$(git -C "${regression_tmp}" rev-parse HEAD)"

  printf '%s\n' semantic >> "${regression_tmp}/state"
  git -C "${regression_tmp}" add state
  git -C "${regression_tmp}" commit -q \
    -m 'fix(release): semantic authority' \
    -m 'Refs: GV90 GV95'
  regression_semantic="$(git -C "${regression_tmp}" rev-parse HEAD)"

  printf '%s\n' materialized >> "${regression_tmp}/state"
  git -C "${regression_tmp}" add state
  git -C "${regression_tmp}" commit -q \
    -m 'chore(materialize): update governed materializations' \
    -m 'Derived-From-Revision: c31bfa531c8c63d73631a406e3e6ae4be0ac7e23' \
    -m 'Refs: GV18 GV19 GV51 GV90 GV95'
  regression_derived="$(git -C "${regression_tmp}" rev-parse HEAD)"

  printf '%s\n' rematerialized >> "${regression_tmp}/state"
  git -C "${regression_tmp}" add state
  git -C "${regression_tmp}" commit -q \
    -m 'chore(materialize): update governed materializations' \
    -m 'Derived-From-Parent: true' \
    -m 'Refs: GV18 GV19 GV51 GV90 GV95'
  regression_followup="$(git -C "${regression_tmp}" rev-parse HEAD)"

  observed_cause="$(cd "${regression_tmp}" && resolve_causal_revision "${regression_followup}")"
  if [[ "${observed_cause}" != "${regression_semantic}" ]]; then
    echo "Rebase-stable causal provenance did not resolve to the materialization parent." >&2
    exit 5
  fi

  mapfile -t observed_refs < <(
    cd "${regression_tmp}" &&
      emit_governance_references "${regression_base}" "${regression_followup}"
  )
  if [[ "${observed_refs[*]}" != 'GV90 GV95' ]]; then
    echo "Derived materialization references leaked independent semantic authority: ${observed_refs[*]}." >&2
    exit 5
  fi

  printf 'Release rebase provenance counterexample closed by parent-edge causality.\n'
  exit 0
fi

if [[ -n "${history_counterexample}" ]]; then
  if [[ ! -f "${history_counterexample}" ]]; then
    echo "Release history counterexample does not exist: ${history_counterexample}" >&2
    exit 2
  fi
  if ! grep -Fq '733c8126375b9b322de505fae7b5471f796af1fb' "${history_counterexample}"; then
    echo "Release history fixture no longer records the observed main revision." >&2
    exit 3
  fi

  generated_changelog="${GOVENV_RELEASE_GENERATED_CHANGELOG:-.govenv/CHANGELOG.generated.md}"
  if [[ ! -s "${generated_changelog}" ]]; then
    echo "Generated canonical changelog is required for history regression validation." >&2
    exit 3
  fi

  mapfile -t regression_versions < <(
    awk '/^## \[/{ line=$0; sub(/^## \[/, "", line); sub(/\].*$/, "", line); print line }' \
      "${history_counterexample}"
  )
  if [[ "${#regression_versions[@]}" -lt 2 ]]; then
    echo "Release history fixture must contain at least two release entries." >&2
    exit 3
  fi

  regression_tmp="$(mktemp -d)"
  trap 'rm -rf "${regression_tmp}"' EXIT
  for version in "${regression_versions[@]}"; do
    tag="v${version}"
    published_document="${regression_tmp}/${version}.published.md"
    expected_entry="${regression_tmp}/${version}.expected.md"
    observed_entry="${regression_tmp}/${version}.observed.md"
    if ! git show "${tag}:CHANGELOG.md" > "${published_document}" 2>/dev/null; then
      echo "Historical release tag ${tag} is not reconstructible." >&2
      exit 3
    fi
    extract_release_entry "${published_document}" "${version}" > "${expected_entry}"
    extract_release_entry "${generated_changelog}" "${version}" > "${observed_entry}"
    if [[ ! -s "${expected_entry}" || ! -s "${observed_entry}" ]]; then
      echo "Historical release ${version} is missing from canonical reconstruction." >&2
      exit 5
    fi
    if ! cmp -s "${expected_entry}" "${observed_entry}"; then
      echo "Historical release ${version} changed during canonical reconstruction." >&2
      diff -u "${expected_entry}" "${observed_entry}" >&2 || true
      exit 5
    fi
  done

  printf 'Release governance history reconstruction preserves %s historical entries exactly.\n' \
    "${#regression_versions[@]}"
  exit 0
fi

if [[ -n "${placement_counterexample}" ]]; then
  if [[ ! -f "${placement_counterexample}" ]]; then
    echo "Release placement counterexample does not exist: ${placement_counterexample}" >&2
    exit 2
  fi

  release_heading="$(awk '/^## \[/{ print; exit }' "${placement_counterexample}")"
  if [[ "${release_heading}" =~ ^##\ \[([^]]+)\] ]]; then
    release_version="${BASH_REMATCH[1]}"
  else
    echo "Release placement counterexample has no release heading." >&2
    exit 2
  fi
  if [[ ! "${release_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ]]; then
    echo "Release placement counterexample has an unsafe release version." >&2
    exit 2
  fi

  original_heading="$(extract_section_release_heading "${placement_counterexample}")"
  if [[ "${original_heading}" == "## [${release_version}]"* ]]; then
    echo "Release placement fixture no longer preserves the regression counterexample." >&2
    exit 3
  fi

  regression_tmp="$(mktemp -d)"
  trap 'rm -rf "${regression_tmp}"' EXIT
  regression_section="${regression_tmp}/section.md"
  regression_updated="${regression_tmp}/updated.md"
  extract_section "${placement_counterexample}" > "${regression_section}"
  materialize_section_at_release \
    "${placement_counterexample}" "${regression_section}" \
    "${release_version}" "${regression_updated}"
  verify_section_at_release \
    "${regression_updated}" "${regression_section}" \
    "${release_version}" "Release placement counterexample"
  printf 'Release governance placement counterexample closed for %s.\n' "${release_version}"
  exit 0
fi

if [[ -n "${push_auth_counterexample}" ]]; then
  if [[ ! -f "${push_auth_counterexample}" ]]; then
    echo "Release push authorization counterexample does not exist: ${push_auth_counterexample}" >&2
    exit 2
  fi
  if ! grep -Fq "fatal: could not read Username for 'https://github.com'" "${push_auth_counterexample}"; then
    echo "Release push authorization fixture no longer preserves the observed failure." >&2
    exit 3
  fi
  if ! grep -Fq 'git_with_github_token "${worktree}" push origin "HEAD:${head_ref}"' "$0"; then
    echo "Release branch mutation is no longer bound to the explicit GitHub token bridge." >&2
    exit 3
  fi

  askpass="$(mktemp)"
  write_git_askpass "${askpass}"
  username="$(BASH_ENV=/dev/null GH_TOKEN='counterexample-token' "${askpass}" "Username for https://github.com")"
  password="$(BASH_ENV=/dev/null GH_TOKEN='counterexample-token' "${askpass}" "Password for https://github.com")"
  rm -f "${askpass}"
  if [[ "${username}" != 'x-access-token' ]] ||
     [[ "${password}" != 'counterexample-token' ]]; then
    echo "Explicit GitHub token bridge verification failed." >&2
    exit 5
  fi
  printf 'Release push authorization counterexample closed.\n'
  exit 0
fi

head_ref="$(gh pr view "${release_pr}" --json headRefName --jq '.headRefName')"
if [[ -z "${head_ref}" ]]; then
  echo "Could not resolve the release pull request head branch." >&2
  exit 4
fi

tmp="$(mktemp -d)"
worktree="${tmp}/release-pr"
cleanup() {
  if [[ -d "${worktree}" ]]; then
    git worktree remove --force "${worktree}" >/dev/null 2>&1 || true
  fi
  rm -rf "${tmp}"
}
trap cleanup EXIT

git fetch origin "+refs/heads/${head_ref}:refs/remotes/origin/${head_ref}"
git worktree add --detach "${worktree}" "origin/${head_ref}" >/dev/null

release_manifest="${worktree}/.github/release-please/manifest.json"
release_version="$(jq -r '.["."] // empty' "${release_manifest}")"
if [[ -z "${release_version}" || ! "${release_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ]]; then
  echo "Could not resolve the Release Please version from ${release_manifest}." >&2
  exit 4
fi

current_body="${tmp}/body.current.md"
updated_body="${tmp}/body.updated.md"
release_notes="${tmp}/release-notes.md"
gh pr view "${release_pr}" --json body --jq '.body // ""' > "${current_body}"
release_heading="$(awk -v version="${release_version}" 'index($0, "## [" version "]") == 1 { print; exit }' "${current_body}")"
if [[ -z "${release_heading}" ]]; then
  echo "Release pull request has no heading for ${release_version}." >&2
  exit 4
fi
extract_candidate_notes "${current_body}" "${release_version}" > "${release_notes}"

GOVENV_RELEASE_VERSION="${release_version}" \
GOVENV_RELEASE_HEADING="${release_heading}" \
GOVENV_RELEASE_NOTES_FILE="${release_notes}" \
  bash src/Govenv/Adapter/release-governance.sh "${release_pr}" >/dev/null
body_impact=".govenv/release-governance-body.md"
canonical_changelog=".govenv/release-governance-changelog.md"

current_changelog="${worktree}/CHANGELOG.md"
cp "${root}/${canonical_changelog}" "${current_changelog}"
if ! git -C "${worktree}" diff --quiet -- CHANGELOG.md; then
  git -C "${worktree}" add CHANGELOG.md
  GIT_AUTHOR_NAME="github-actions[bot]" \
  GIT_AUTHOR_EMAIL="41898282+github-actions[bot]@users.noreply.github.com" \
  GIT_COMMITTER_NAME="github-actions[bot]" \
  GIT_COMMITTER_EMAIL="41898282+github-actions[bot]@users.noreply.github.com" \
    git -C "${worktree}" commit \
      -m "chore(materialize): freeze canonical release changelog" >/dev/null
  git_with_github_token "${worktree}" push origin "HEAD:${head_ref}"
fi

git fetch origin "+refs/heads/${head_ref}:refs/remotes/origin/${head_ref}"
remote_changelog="${tmp}/CHANGELOG.remote.md"
git show "origin/${head_ref}:CHANGELOG.md" > "${remote_changelog}"
if ! cmp -s "${root}/${canonical_changelog}" "${remote_changelog}"; then
  echo "Release changelog whole-file read-back verification failed." >&2
  diff -u "${root}/${canonical_changelog}" "${remote_changelog}" >&2 || true
  exit 5
fi

materialize_section_at_release \
  "${current_body}" "${root}/${body_impact}" \
  "${release_version}" "${updated_body}"

gh pr edit "${release_pr}" --body-file "${updated_body}" >/dev/null
gh pr view "${release_pr}" --json body --jq '.body // ""' > "${current_body}"
verify_section_at_release \
  "${current_body}" "${root}/${body_impact}" \
  "${release_version}" "Release pull request"

printf 'Release governance materialized and verified for PR #%s.\n' "${release_pr}"
