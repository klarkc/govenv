#!/usr/bin/env bash
set -euo pipefail

release_tag="${GOVENV_RELEASE_TAG:-${1:-}}"
release_sha="${GOVENV_RELEASE_SHA:-${2:-}}"

if [[ -z "${release_tag}" ]]; then
  echo "GOVENV_RELEASE_TAG or the first argument must identify the GitHub Release tag." >&2
  exit 2
fi
if [[ -z "${release_sha}" ]]; then
  release_sha="${release_tag}"
fi

root="$(git rev-parse --show-toplevel)"
cd "${root}"

GOVENV_RELEASE_TARGET=github-release \
GOVENV_RELEASE_TAG="${release_tag}" \
GOVENV_RELEASE_HEAD_REF="${release_sha}" \
  bash src/Govenv/Adapter/release-governance.sh >/dev/null

expected=".govenv/release-governance-release.md"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
current="${tmp}/release.current.md"
updated="${tmp}/release.updated.md"
observed="${tmp}/release.observed.md"

gh release view "${release_tag}" --json body --jq '.body // ""' > "${current}"
awk -v section="${root}/${expected}" '
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
  END {
    if (!replaced) {
      # Release Please normally carries the changelog section into the release body.
      # Absence is rejected instead of inventing target placement in the adapter.
      exit 42
    }
  }
' "${current}" > "${updated}" || {
  echo "GitHub Release body does not contain the governed changelog section." >&2
  exit 4
}

gh release edit "${release_tag}" --notes-file "${updated}" >/dev/null

gh release view "${release_tag}" --json body --jq '.body // ""' |
  awk '
    /<!-- govenv-governance-impact:start -->/ { capture = 1 }
    capture { print }
    /<!-- govenv-governance-impact:end -->/ { exit }
  ' > "${observed}"

if ! cmp -s "${expected}" "${observed}"; then
  echo "GitHub Release governance read-back verification failed." >&2
  diff -u "${expected}" "${observed}" >&2 || true
  exit 5
fi

printf 'Release governance materialized and verified for %s.\n' "${release_tag}"
