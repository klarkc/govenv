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
published_changelog="${tmp}/CHANGELOG.published.md"
canonical_entry_raw="${tmp}/release-entry.canonical.raw.md"
canonical_entry_without_boundary="${tmp}/release-entry.canonical.without-boundary.md"
canonical_entry="${tmp}/release-entry.canonical.md"
current="${tmp}/release.current.md"
observed_body="${tmp}/release.observed-body.md"
observed_governance="${tmp}/release.observed-governance.md"

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

trim_trailing_blank_lines() {
  awk '
    { lines[NR] = $0 }
    END {
      last = NR
      while (last > 0 && lines[last] == "") last--
      for (i = 1; i <= last; i++) print lines[i]
    }
  ' "$1"
}

read_release_body() {
  gh release view "$1" --json body | jq -j '.body // ""'
}

verify_release_please_observed_semantic_notes() {
  local observed="$1"
  local canonical="$2"
  local revision
  while IFS= read -r revision; do
    [[ -n "${revision}" ]] || continue
    if ! grep -Fq "/commit/${revision}" "${observed}"; then
      echo "Published Release Please observation omitted canonical semantic note ${revision}." >&2
      return 5
    fi
  done < <(grep -oE '/commit/[0-9a-f]{40}' "${canonical}" | sed 's#^/commit/##' | sort -u)
}

if ! git show "${release_sha}:CHANGELOG.md" > "${published_changelog}" 2>/dev/null; then
  echo "Published release revision has no canonical changelog." >&2
  exit 3
fi
release_version="${release_tag#v}"
extract_release_entry "${published_changelog}" "${release_version}" > "${canonical_entry_raw}"
awk '!/^<!-- govenv-release-freeze:/' "${canonical_entry_raw}" > "${canonical_entry_without_boundary}"
trim_trailing_blank_lines "${canonical_entry_without_boundary}" > "${canonical_entry}"

# The canonical release entry must itself carry exactly the governed section
# computed independently from the immutable release boundary.
awk '
  /<!-- govenv-governance-impact:start -->/ { capture = 1 }
  capture { print }
  /<!-- govenv-governance-impact:end -->/ { exit }
' "${canonical_entry}" > "${observed_governance}"
if ! cmp -s "${expected}" "${observed_governance}"; then
  echo "Canonical release entry does not carry the expected governed release document." >&2
  diff -u "${expected}" "${observed_governance}" >&2 || true
  exit 5
fi

read_release_body "${release_tag}" > "${current}"
verify_release_please_observed_semantic_notes "${current}" "${canonical_entry}"

# Apply the entire canonical entry, not merely its governance subsection. This
# makes the published GitHub Release a projection of the exact approved freeze.
gh release edit "${release_tag}" --notes-file "${canonical_entry}" >/dev/null

read_release_body "${release_tag}" > "${observed_body}"
if ! cmp -s "${canonical_entry}" "${observed_body}"; then
  echo "GitHub Release whole-body read-back verification failed." >&2
  diff -u "${canonical_entry}" "${observed_body}" >&2 || true
  exit 5
fi

printf 'Release governance materialized and verified for %s.\n' "${release_tag}"
