#!/usr/bin/env bash
set -euo pipefail

explicit_snapshot="${GOVENV_PREVIOUS_ROADMAP_SNAPSHOT:-${1:-}}"
explicit_purpose_snapshot="${GOVENV_PREVIOUS_PROJECT_PURPOSE_SNAPSHOT:-${2:-}}"
root="$(git rev-parse --show-toplevel)"
cd "${root}"

input_root=".govenv/roadmap-evolution-input"
mkdir -p "${input_root}"

previous_ref=""
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

purpose_snapshot_path=""
if [[ -n "${explicit_purpose_snapshot}" ]]; then
  purpose_snapshot_path="${explicit_purpose_snapshot}"
elif [[ -n "${previous_ref}" ]] &&
     git rev-parse --verify "${previous_ref}^{commit}" >/dev/null 2>&1; then
  candidate_purpose_snapshot="${input_root}/previous-project-purpose.snapshot"
  if git show "${previous_ref}:.govenv/project-purpose.snapshot" \
      > "${candidate_purpose_snapshot}" 2>/dev/null; then
    purpose_snapshot_path="${candidate_purpose_snapshot}"
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

previous_purpose_available=false
previous_purpose_expr='""'
previous_purpose_review_index=0
if [[ -n "${purpose_snapshot_path}" ]]; then
  [[ -f "${purpose_snapshot_path}" ]] || {
    echo "Governed project purpose snapshot is missing: ${purpose_snapshot_path}" >&2
    exit 3
  }

  purpose_header=""
  purpose_expr=""
  purpose_review_index=""
  while IFS= read -r line; do
    case "${line}" in
      govenv-project-purpose-snapshot-v1)
        [[ -z "${purpose_header}" ]] || {
          echo "Duplicate project purpose snapshot header." >&2
          exit 3
        }
        purpose_header="${line}"
        ;;
      "review-index "*)
        value="${line#review-index }"
        [[ "${value}" =~ ^[0-9]+$ ]] || {
          echo "Invalid project purpose review index: ${line}" >&2
          exit 3
        }
        [[ -z "${purpose_review_index}" ]] || {
          echo "Duplicate project purpose review index." >&2
          exit 3
        }
        purpose_review_index="${value}"
        ;;
      "purpose "*)
        value="${line#purpose }"
        [[ "${value}" =~ ^\".*\"$ ]] || {
          echo "Invalid project purpose snapshot value: ${line}" >&2
          exit 3
        }
        [[ -z "${purpose_expr}" ]] || {
          echo "Duplicate project purpose snapshot value." >&2
          exit 3
        }
        purpose_expr="${value}"
        ;;
      "") ;;
      *)
        echo "Invalid project purpose snapshot line: ${line}" >&2
        exit 3
        ;;
    esac
  done < "${purpose_snapshot_path}"

  [[ "${purpose_header}" == "govenv-project-purpose-snapshot-v1" ]] || {
    echo "Unsupported project purpose snapshot format." >&2
    exit 3
  }
  [[ -n "${purpose_expr}" ]] || {
    echo "Project purpose snapshot has no purpose." >&2
    exit 3
  }
  [[ -n "${purpose_review_index}" ]] || {
    echo "Project purpose snapshot has no review index." >&2
    exit 3
  }

  previous_purpose_available=true
  previous_purpose_expr="${purpose_expr}"
  previous_purpose_review_index="${purpose_review_index}"
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
open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)

previous : RoadmapSnapshot
previous = roadmapSnapshot (${phase_expr}) (${items_expr})

previousPurposeAvailable : Bool
previousPurposeAvailable = ${previous_purpose_available}

previousPurpose : String
previousPurpose = ${previous_purpose_expr}

previousPurposeReviewIndex : Nat
previousPurposeReviewIndex = ${previous_purpose_review_index}
EOF2

agda -i "${input_root}" -i . -i src --compile \
  --compile-dir="${build_dir}" src/Govenv/Adapter/RoadmapEvolution.agda >/dev/null
"${build_dir}/RoadmapEvolution"

if ! agda -i "${input_root}" -i . -i src \
    src/Govenv/Adapter/PurposeVigilance.agda >/dev/null; then
  echo "Project purpose vigilance failed: review the complete resulting roadmap, then either advance purposeReviewIndex by one when reaffirming the current purpose or change purpose and reset the index to zero." >&2
  exit 4
fi
