#!/usr/bin/env bash
set -euo pipefail

candidate_root="${1:?candidate root is required}"
release_version="${2:?release version is required}"
snapshot="${candidate_root}/.govenv/learning.snapshot"

if [[ ! -f "${snapshot}" ]]; then
  echo "Learning snapshot is required for release eligibility." >&2
  exit 4
fi

if ! grep -Fxq 'govenv-learning-snapshot-v1' "${snapshot}"; then
  echo "Unsupported learning snapshot format." >&2
  exit 4
fi

debt_clear="$(awk '$1 == "debt-clear" { print $2; exit }' "${snapshot}")"
if [[ "${debt_clear}" != true && "${debt_clear}" != false ]]; then
  echo "Learning snapshot has no valid debt-clear value." >&2
  exit 4
fi

release_core="${release_version%%[-+]*}"
IFS=. read -r release_major release_minor release_patch <<< "${release_core}"

previous_tag="$(git -C "${candidate_root}" describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || true)"
if [[ -z "${previous_tag}" ]]; then
  release_kind=minor-or-major
else
  previous_core="${previous_tag#v}"
  previous_core="${previous_core%%[-+]*}"
  IFS=. read -r previous_major previous_minor previous_patch <<< "${previous_core}"
  if [[ "${release_major}" == "${previous_major}" && "${release_minor}" == "${previous_minor}" ]]; then
    release_kind=patch
  else
    release_kind=minor-or-major
  fi
fi

if [[ "${release_kind}" == patch ]]; then
  printf 'Learning gate: patch release may carry known debt.\n'
  exit 0
fi

if [[ "${debt_clear}" != true ]]; then
  echo "Learning gate: major/minor release blocked by outstanding learning debt." >&2
  exit 5
fi

printf 'Learning gate: major/minor release has zero outstanding debt.\n'
