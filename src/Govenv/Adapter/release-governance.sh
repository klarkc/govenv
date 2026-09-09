#!/usr/bin/env bash
set -euo pipefail

release_pr="${GOVENV_RELEASE_PR:-${1:-}}"
base_ref="${GOVENV_RELEASE_BASE_REF:-${2:-}}"
head_ref="${GOVENV_RELEASE_HEAD_REF:-${3:-HEAD}}"

if [[ -z "${release_pr}" || ! "${release_pr}" =~ ^[0-9]+$ ]]; then
  echo "GOVENV_RELEASE_PR or the first argument must be a pull request number." >&2
  exit 2
fi

if [[ -z "${base_ref}" ]]; then
  base_ref="$(git describe --tags --abbrev=0 2>/dev/null || true)"
fi
if [[ -z "${base_ref}" ]]; then
  echo "A release base ref is required." >&2
  exit 2
fi

root="$(git rev-parse --show-toplevel)"
cd "${root}"

git rev-parse --verify "${base_ref}^{commit}" >/dev/null
git rev-parse --verify "${head_ref}^{commit}" >/dev/null

input_root=".govenv/release-input"
input_dir="${input_root}/Govenv/Adapter"
build_dir=".govenv/release-governance-build"
mkdir -p "${input_dir}"
rm -rf "${build_dir}"
mkdir -p "${build_dir}"

previous_snapshot=".govenv/release-previous.snapshot"
if git show "${base_ref}:.govenv/roadmap.snapshot" > "${previous_snapshot}" 2>/dev/null; then
  first_line="$(sed -n '1p' "${previous_snapshot}")"
  if [[ "${first_line}" != "govenv-roadmap-snapshot-v1" ]]; then
    echo "Unsupported roadmap snapshot format at ${base_ref}." >&2
    exit 3
  fi
else
  # v0.1.0 predates governed roadmap snapshots. Treat it conservatively as
  # an absent historical roadmap; future releases must use the typed snapshot.
  printf '%s\n' 'govenv-roadmap-snapshot-v1' 'phase absent' > "${previous_snapshot}"
fi

phase_expr=""
item_exprs=()
while IFS= read -r line; do
  case "${line}" in
    govenv-roadmap-snapshot-v1) ;;
    "phase absent")
      [[ -z "${phase_expr}" ]] || { echo "Duplicate phase in snapshot." >&2; exit 3; }
      phase_expr="snapshotAbsent"
      ;;
    "phase active "*)
      value="${line#phase active }"
      [[ "${value}" =~ ^[0-9]+$ ]] || { echo "Invalid active phase: ${line}" >&2; exit 3; }
      [[ -z "${phase_expr}" ]] || { echo "Duplicate phase in snapshot." >&2; exit 3; }
      phase_expr="snapshotActive ${value}"
      ;;
    "phase complete "*)
      value="${line#phase complete }"
      [[ "${value}" =~ ^[0-9]+$ ]] || { echo "Invalid complete phase: ${line}" >&2; exit 3; }
      [[ -z "${phase_expr}" ]] || { echo "Duplicate phase in snapshot." >&2; exit 3; }
      phase_expr="snapshotComplete ${value}"
      ;;
    "item "*)
      if [[ "${line}" =~ ^item\ ([0-9]+)\ (done|todo)$ ]]; then
        item_exprs+=("snapshotItem ${BASH_REMATCH[1]} ${BASH_REMATCH[2]}")
      else
        echo "Invalid roadmap snapshot item: ${line}" >&2
        exit 3
      fi
      ;;
    "") ;;
    *)
      echo "Invalid roadmap snapshot line: ${line}" >&2
      exit 3
      ;;
  esac
done < "${previous_snapshot}"

if [[ -z "${phase_expr}" ]]; then
  echo "Roadmap snapshot has no phase state." >&2
  exit 3
fi

references=()
while IFS= read -r value; do
  [[ -n "${value}" ]] && references+=("${value#GV}")
done < <(
  git log "${base_ref}..${head_ref}" --format=%B |
    awk '
      /^Refs:/ {
        line = $0
        while (match(line, /GV[0-9]+/)) {
          print substr(line, RSTART, RLENGTH)
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' |
    sort -uV
)

agda_list() {
  local expression="[]"
  local index
  for ((index=${#@}; index>0; index--)); do
    value="${!index}"
    expression="${value} ∷ (${expression})"
  done
  printf '%s' "${expression}"
}

items_expr="$(agda_list "${item_exprs[@]}")"
reference_exprs=()
for value in "${references[@]}"; do
  reference_exprs+=("${value}")
done
references_expr="$(agda_list "${reference_exprs[@]}")"
base_revision="$(git rev-parse --short=7 "${base_ref}")"
head_revision="$(git rev-parse --short=7 "${head_ref}")"
observation="${input_dir}/ReleaseObservation.agda"

cat > "${observation}" <<EOF
{-# OPTIONS --safe #-}
module Govenv.Adapter.ReleaseObservation where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Release
open import Govenv.Kernel.Roadmap using (done; todo)

previous : RoadmapSnapshot
previous = roadmapSnapshot (${phase_expr}) (${items_expr})

references : List Nat
references = ${references_expr}

releasePullRequest : Nat
releasePullRequest = ${release_pr}

baseRevision : String
baseRevision = "${base_revision}"

headRevision : String
headRevision = "${head_revision}"
EOF

nix run github:cachix/devenv/v2.3 -- shell -- \
  agda -i "${input_root}" -i . -i src --compile \
  --compile-dir="${build_dir}" src/Govenv/Adapter/ReleaseGovernance/Body.agda >/dev/null
nix run github:cachix/devenv/v2.3 -- shell -- \
  agda -i "${input_root}" -i . -i src --compile \
  --compile-dir="${build_dir}" src/Govenv/Adapter/ReleaseGovernance/Changelog.agda >/dev/null

body_output=".govenv/release-governance-body.md"
changelog_output=".govenv/release-governance-changelog.md"
"${build_dir}/Body" > "${body_output}"
"${build_dir}/Changelog" > "${changelog_output}"

cat "${body_output}"
