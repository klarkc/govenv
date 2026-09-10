#!/usr/bin/env bash
set -euo pipefail

release_pr="${GOVENV_RELEASE_PR:-${1:-}}"
if [[ -z "${release_pr}" || ! "${release_pr}" =~ ^[0-9]+$ ]]; then
  echo "GOVENV_RELEASE_PR or the first argument must be a pull request number." >&2
  exit 2
fi

root="$(git rev-parse --show-toplevel)"
cd "${root}"

bash src/Govenv/Adapter/release-governance.sh "${release_pr}" >/dev/null
body_impact=".govenv/release-governance-body.md"
changelog_impact=".govenv/release-governance-changelog.md"

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

current_changelog="${worktree}/CHANGELOG.md"
updated_changelog="${tmp}/CHANGELOG.updated.md"

if grep -q '<!-- govenv-governance-impact:start -->' "${current_changelog}"; then
  awk -v section="${root}/${changelog_impact}" '
    function emit_section( line) {
      while ((getline line < section) > 0) print line
      close(section)
    }
    /<!-- govenv-governance-impact:start -->/ {
      emit_section()
      skip = 1
      replaced = 1
      next
    }
    /<!-- govenv-governance-impact:end -->/ { skip = 0; next }
    !skip { print }
    END { if (!replaced) exit 42 }
  ' "${current_changelog}" > "${updated_changelog}"
else
  awk -v section="${root}/${changelog_impact}" '
    function emit_section( line) {
      while ((getline line < section) > 0) print line
      close(section)
    }
    !inserted && /^## / {
      print
      print ""
      emit_section()
      print ""
      inserted = 1
      next
    }
    { print }
    END { if (!inserted) exit 42 }
  ' "${current_changelog}" > "${updated_changelog}"
fi

cp "${updated_changelog}" "${current_changelog}"
if ! git -C "${worktree}" diff --quiet -- CHANGELOG.md; then
  git -C "${worktree}" add CHANGELOG.md
  GIT_AUTHOR_NAME="github-actions[bot]" \
  GIT_AUTHOR_EMAIL="41898282+github-actions[bot]@users.noreply.github.com" \
  GIT_COMMITTER_NAME="github-actions[bot]" \
  GIT_COMMITTER_EMAIL="41898282+github-actions[bot]@users.noreply.github.com" \
    git -C "${worktree}" commit \
      -m "chore(materialize): update release governance impact" >/dev/null
  git -C "${worktree}" push origin "HEAD:${head_ref}"
fi

git fetch origin "+refs/heads/${head_ref}:refs/remotes/origin/${head_ref}"
remote_changelog="${tmp}/CHANGELOG.remote.md"
observed_changelog="${tmp}/governance-changelog.observed.md"
git show "origin/${head_ref}:CHANGELOG.md" > "${remote_changelog}"
extract_section "${remote_changelog}" > "${observed_changelog}"
if ! cmp -s "${changelog_impact}" "${observed_changelog}"; then
  echo "Release changelog governance read-back verification failed." >&2
  diff -u "${changelog_impact}" "${observed_changelog}" >&2 || true
  exit 5
fi

current_body="${tmp}/body.current.md"
clean_body="${tmp}/body.clean.md"
updated_body="${tmp}/body.updated.md"
observed_body="${tmp}/body.observed.md"
gh pr view "${release_pr}" --json body --jq '.body // ""' > "${current_body}"
strip_section "${current_body}" > "${clean_body}"

{
  cat "${body_impact}"
  if [[ -s "${clean_body}" ]]; then
    body_content="$(cat "${clean_body}")"
    if [[ -n "${body_content}" ]]; then
      printf '\n%s\n' "${body_content}"
    fi
  fi
} > "${updated_body}"

gh pr edit "${release_pr}" --body-file "${updated_body}" >/dev/null
gh pr view "${release_pr}" --json body --jq '.body // ""' > "${current_body}"
extract_section "${current_body}" > "${observed_body}"
if ! cmp -s "${body_impact}" "${observed_body}"; then
  echo "Release pull request governance read-back verification failed." >&2
  diff -u "${body_impact}" "${observed_body}" >&2 || true
  exit 5
fi

printf 'Release governance materialized and verified for PR #%s.\n' "${release_pr}"
