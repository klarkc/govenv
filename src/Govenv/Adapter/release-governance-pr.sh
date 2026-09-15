#!/usr/bin/env bash
set -euo pipefail

placement_counterexample="${GOVENV_RELEASE_PLACEMENT_COUNTEREXAMPLE:-}"
push_auth_counterexample="${GOVENV_RELEASE_PUSH_AUTH_COUNTEREXAMPLE:-}"
release_pr="${GOVENV_RELEASE_PR:-${1:-}}"
if [[ -z "${placement_counterexample}" ]] &&
   [[ -z "${push_auth_counterexample}" ]] &&
   [[ -z "${release_pr}" || ! "${release_pr}" =~ ^[0-9]+$ ]]; then
  echo "GOVENV_RELEASE_PR or the first argument must be a pull request number." >&2
  exit 2
fi

root="$(git rev-parse --show-toplevel)"
cd "${root}"

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

strip_section() {
  awk '
    /<!-- govenv-governance-impact:start -->/ { skip = 1; next }
    /<!-- govenv-governance-impact:end -->/ { skip = 0; next }
    !skip { print }
  ' "$1"
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

materialize_section_at_release() {
  local input="$1"
  local section="$2"
  local version="$3"
  local output="$4"

  strip_section "${input}" |
    awk -v section="${section}" -v version="${version}" '
      function emit_section( line) {
        while ((getline line < section) > 0) print line
        close(section)
      }
      BEGIN { heading = "## [" version "]" }
      !inserted && index($0, heading) == 1 {
        print
        print ""
        emit_section()
        print ""
        inserted = 1
        next
      }
      { print }
      END { if (!inserted) exit 42 }
    ' > "${output}"
}

verify_section_at_release() {
  local document="$1"
  local section="$2"
  local version="$3"
  local label="$4"
  local observed
  local observed_heading
  local marker_count

  observed="$(mktemp)"
  extract_section "${document}" > "${observed}"
  if ! cmp -s "${section}" "${observed}"; then
    echo "${label} governance read-back verification failed." >&2
    diff -u "${section}" "${observed}" >&2 || true
    rm -f "${observed}"
    return 5
  fi
  rm -f "${observed}"

  marker_count="$(grep -c '<!-- govenv-governance-impact:start -->' "${document}" || true)"
  if [[ "${marker_count}" != "1" ]]; then
    echo "${label} governance marker cardinality verification failed: ${marker_count}." >&2
    return 5
  fi

  observed_heading="$(extract_section_release_heading "${document}")"
  if [[ "${observed_heading}" != "## [${version}]"* ]]; then
    echo "${label} governance placement verification failed." >&2
    echo "Expected release: ${version}" >&2
    echo "Observed heading: ${observed_heading}" >&2
    return 5
  fi
}

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

GOVENV_RELEASE_VERSION="${release_version}" \
  bash src/Govenv/Adapter/release-governance.sh "${release_pr}" >/dev/null
body_impact=".govenv/release-governance-body.md"
changelog_impact=".govenv/release-governance-changelog.md"

current_changelog="${worktree}/CHANGELOG.md"
updated_changelog="${tmp}/CHANGELOG.updated.md"

materialize_section_at_release \
  "${current_changelog}" "${root}/${changelog_impact}" \
  "${release_version}" "${updated_changelog}"

cp "${updated_changelog}" "${current_changelog}"
if ! git -C "${worktree}" diff --quiet -- CHANGELOG.md; then
  git -C "${worktree}" add CHANGELOG.md
  GIT_AUTHOR_NAME="github-actions[bot]" \
  GIT_AUTHOR_EMAIL="41898282+github-actions[bot]@users.noreply.github.com" \
  GIT_COMMITTER_NAME="github-actions[bot]" \
  GIT_COMMITTER_EMAIL="41898282+github-actions[bot]@users.noreply.github.com" \
    git -C "${worktree}" commit \
      -m "chore(materialize): update release governance impact" >/dev/null
  git_with_github_token "${worktree}" push origin "HEAD:${head_ref}"
fi

git fetch origin "+refs/heads/${head_ref}:refs/remotes/origin/${head_ref}"
remote_changelog="${tmp}/CHANGELOG.remote.md"
git show "origin/${head_ref}:CHANGELOG.md" > "${remote_changelog}"
verify_section_at_release \
  "${remote_changelog}" "${root}/${changelog_impact}" \
  "${release_version}" "Release changelog"

current_body="${tmp}/body.current.md"
updated_body="${tmp}/body.updated.md"
gh pr view "${release_pr}" --json body --jq '.body // ""' > "${current_body}"

materialize_section_at_release \
  "${current_body}" "${root}/${body_impact}" \
  "${release_version}" "${updated_body}"

gh pr edit "${release_pr}" --body-file "${updated_body}" >/dev/null
gh pr view "${release_pr}" --json body --jq '.body // ""' > "${current_body}"
verify_section_at_release \
  "${current_body}" "${root}/${body_impact}" \
  "${release_version}" "Release pull request"

printf 'Release governance materialized and verified for PR #%s.\n' "${release_pr}"
