#!/usr/bin/env bash
set -euo pipefail

explicit_snapshot="${GOVENV_PREVIOUS_ROADMAP_SNAPSHOT:-${1:-}}"
root="$(git rev-parse --show-toplevel)"
cd "${root}"

input_root=".govenv/roadmap-evolution-input"
mkdir -p "${input_root}"

if [[ -n "${explicit_snapshot}" ]]; then
  snapshot_path="${explicit_snapshot}"
else
  snapshot_path="${input_root}/previous.snapshot"
  if git diff --quiet HEAD --; then
    previous_ref="HEAD^"
  else
    previous_ref="HEAD"
  fi

  if git rev-parse --verify "${previous_ref}^{commit}" >/dev/null 2>&1 &&
     git show "${previous_ref}:.govenv/roadmap.snapshot" > "${snapshot_path}" 2>/dev/null; then
    :
  else
    printf '%s\n' 'govenv-roadmap-snapshot-v2' 'phase absent' > "${snapshot_path}"
  fi
fi

if [[ ! -f "${snapshot_path}" ]]; then
  echo "Governed roadmap snapshot is missing: ${snapshot_path}" >&2
  exit 3
fi

first_line="$(sed -n '1p' "${snapshot_path}")"
if [[ "${first_line}" == "govenv-roadmap-snapshot-v1" ]]; then
  # Snapshot v1 was never an immutable-identity release baseline. It did not
  # preserve definitions or owning phases, so the one-way v2 migration is
  # conservatively treated as introduction of the normalized current history.
  migration_snapshot="${input_root}/legacy-v1-migration.snapshot"
  printf '%s\n' 'govenv-roadmap-snapshot-v2' 'phase absent' > "${migration_snapshot}"
  snapshot_path="${migration_snapshot}"
  first_line="govenv-roadmap-snapshot-v2"
fi

if [[ "${first_line}" != "govenv-roadmap-snapshot-v2" ]]; then
  echo "Unsupported roadmap snapshot format: ${first_line}" >&2
  exit 3
fi

phase_expr=""
item_exprs=()
while IFS= read -r line; do
  case "${line}" in
    govenv-roadmap-snapshot-v2) ;;
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
      if [[ "${line}" =~ ^item\ ([0-9]+)\ phase\ ([0-9]+)\ (done|todo|cancelled)\ (\".*\")$ ]]; then
        item_exprs+=("snapshotItem ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[4]} ${BASH_REMATCH[3]}")
      elif [[ "${line}" =~ ^item\ ([0-9]+)\ phase\ ([0-9]+)\ superseded\ ([0-9]+)\ (\".*\")$ ]]; then
        item_exprs+=("snapshotItem ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[4]} (superseded (GVR ${BASH_REMATCH[3]}))")
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
done < "${snapshot_path}"

if [[ -z "${phase_expr}" ]]; then
  echo "Roadmap snapshot has no phase state." >&2
  exit 3
fi

agda_list() {
  local expression="[]"
  local index value
  for ((index=${#@}; index>0; index--)); do
    value="${!index}"
    expression="${value} ∷ (${expression})"
  done
  printf '%s' "${expression}"
}

input_dir="${input_root}/Govenv/Adapter"
build_dir=".govenv/roadmap-evolution-build"
mkdir -p "${input_dir}"
rm -rf "${build_dir}"
mkdir -p "${build_dir}"

items_expr="$(agda_list "${item_exprs[@]}")"
observation="${input_dir}/RoadmapEvolutionObservation.agda"
cat > "${observation}" <<EOF2
{-# OPTIONS --safe #-}
module Govenv.Adapter.RoadmapEvolutionObservation where

open import Govenv.Kernel.Identifier using (GVR)
open import Govenv.Kernel.Release
open import Govenv.Kernel.Roadmap using (done; todo; cancelled; superseded)
open import Agda.Builtin.List using ([]; _∷_)

previous : RoadmapSnapshot
previous = roadmapSnapshot (${phase_expr}) (${items_expr})
EOF2

agda -i "${input_root}" -i . -i src --compile \
  --compile-dir="${build_dir}" src/Govenv/Adapter/RoadmapEvolution.agda >/dev/null
"${build_dir}/RoadmapEvolution"
