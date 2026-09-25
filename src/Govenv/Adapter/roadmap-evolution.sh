#!/usr/bin/env bash
set -euo pipefail

explicit_snapshot="${GOVENV_PREVIOUS_ROADMAP_SNAPSHOT:-${1:-}}"
explicit_purpose_snapshot="${GOVENV_PREVIOUS_PROJECT_PURPOSE_SNAPSHOT:-${2:-}}"
explicit_direction_snapshot="${GOVENV_PREVIOUS_DIRECTION_REVIEW_SNAPSHOT:-${3:-}}"
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

direction_snapshot_path=""
if [[ -n "${explicit_direction_snapshot}" ]]; then
  direction_snapshot_path="${explicit_direction_snapshot}"
elif [[ -n "${previous_ref}" ]] &&
     git rev-parse --verify "${previous_ref}^{commit}" >/dev/null 2>&1; then
  candidate_direction_snapshot="${input_root}/previous-direction-review.snapshot"
  if git show "${previous_ref}:.govenv/direction-review.snapshot" \
      > "${candidate_direction_snapshot}" 2>/dev/null; then
    direction_snapshot_path="${candidate_direction_snapshot}"
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
previous_purpose_review_rationale_expr='""'
previous_purpose_review_index=0
if [[ -n "${purpose_snapshot_path}" ]]; then
  [[ -f "${purpose_snapshot_path}" ]] || {
    echo "Governed project purpose snapshot is missing: ${purpose_snapshot_path}" >&2
    exit 3
  }

  purpose_header=""
  purpose_expr=""
  purpose_review_rationale_expr=""
  purpose_review_index=""
  while IFS= read -r line; do
    case "${line}" in
      govenv-project-purpose-snapshot-v1|govenv-project-purpose-snapshot-v2)
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
      "review-rationale "*)
        value="${line#review-rationale }"
        [[ "${value}" =~ ^\".*\"$ ]] || {
          echo "Invalid project purpose review rationale: ${line}" >&2
          exit 3
        }
        [[ -z "${purpose_review_rationale_expr}" ]] || {
          echo "Duplicate project purpose review rationale." >&2
          exit 3
        }
        purpose_review_rationale_expr="${value}"
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

  [[ "${purpose_header}" == "govenv-project-purpose-snapshot-v1" ||
     "${purpose_header}" == "govenv-project-purpose-snapshot-v2" ]] || {
    echo "Unsupported project purpose snapshot format." >&2
    exit 3
  }
  if [[ "${purpose_header}" == "govenv-project-purpose-snapshot-v2" &&
        -z "${purpose_review_rationale_expr}" ]]; then
    echo "Project purpose snapshot has no review rationale." >&2
    exit 3
  fi
  if [[ "${purpose_header}" == "govenv-project-purpose-snapshot-v1" ]]; then
    purpose_review_rationale_expr='""'
  fi
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
  previous_purpose_review_rationale_expr="${purpose_review_rationale_expr}"
  previous_purpose_review_index="${purpose_review_index}"
fi

previous_direction_available=false
previous_direction_review_index=0
previous_direction_review_rationale_expr='""'
previous_current_expr='""'
previous_next_expr='""'
if [[ -n "${direction_snapshot_path}" ]]; then
  [[ -f "${direction_snapshot_path}" ]] || {
    echo "Governed direction review snapshot is missing: ${direction_snapshot_path}" >&2
    exit 3
  }

  direction_header=""
  direction_review_index=""
  direction_review_rationale_expr=""
  direction_current_expr=""
  direction_next_expr=""
  while IFS= read -r line; do
    case "${line}" in
      govenv-direction-review-snapshot-v1|govenv-direction-review-snapshot-v2)
        [[ -z "${direction_header}" ]] || {
          echo "Duplicate direction review snapshot header." >&2
          exit 3
        }
        direction_header="${line}"
        ;;
      "review-index "*)
        value="${line#review-index }"
        [[ "${value}" =~ ^[0-9]+$ ]] || {
          echo "Invalid direction review index: ${line}" >&2
          exit 3
        }
        [[ -z "${direction_review_index}" ]] || {
          echo "Duplicate direction review index." >&2
          exit 3
        }
        direction_review_index="${value}"
        ;;
      "review-rationale "*)
        value="${line#review-rationale }"
        [[ "${value}" =~ ^\".*\"$ ]] || {
          echo "Invalid direction review rationale: ${line}" >&2
          exit 3
        }
        [[ -z "${direction_review_rationale_expr}" ]] || {
          echo "Duplicate direction review rationale." >&2
          exit 3
        }
        direction_review_rationale_expr="${value}"
        ;;
      "current "*)
        value="${line#current }"
        [[ "${value}" =~ ^\".*\"$ ]] || {
          echo "Invalid direction Current snapshot value: ${line}" >&2
          exit 3
        }
        [[ -z "${direction_current_expr}" ]] || {
          echo "Duplicate direction Current snapshot value." >&2
          exit 3
        }
        direction_current_expr="${value}"
        ;;
      "next "*)
        value="${line#next }"
        [[ "${value}" =~ ^\".*\"$ ]] || {
          echo "Invalid direction Next snapshot value: ${line}" >&2
          exit 3
        }
        [[ -z "${direction_next_expr}" ]] || {
          echo "Duplicate direction Next snapshot value." >&2
          exit 3
        }
        direction_next_expr="${value}"
        ;;
      "") ;;
      *)
        echo "Invalid direction review snapshot line: ${line}" >&2
        exit 3
        ;;
    esac
  done < "${direction_snapshot_path}"

  [[ "${direction_header}" == "govenv-direction-review-snapshot-v1" ||
     "${direction_header}" == "govenv-direction-review-snapshot-v2" ]] || {
    echo "Unsupported direction review snapshot format." >&2
    exit 3
  }
  if [[ "${direction_header}" == "govenv-direction-review-snapshot-v2" &&
        -z "${direction_review_rationale_expr}" ]]; then
    echo "Direction review snapshot has no review rationale." >&2
    exit 3
  fi
  if [[ "${direction_header}" == "govenv-direction-review-snapshot-v1" ]]; then
    direction_review_rationale_expr='""'
  fi
  [[ -n "${direction_review_index}" && -n "${direction_current_expr}" &&
     -n "${direction_next_expr}" ]] || {
    echo "Direction review snapshot is incomplete." >&2
    exit 3
  }

  previous_direction_available=true
  previous_direction_review_index="${direction_review_index}"
  previous_direction_review_rationale_expr="${direction_review_rationale_expr}"
  previous_current_expr="${direction_current_expr}"
  previous_next_expr="${direction_next_expr}"
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

previousPurposeReviewRationale : String
previousPurposeReviewRationale = ${previous_purpose_review_rationale_expr}

previousPurposeReviewIndex : Nat
previousPurposeReviewIndex = ${previous_purpose_review_index}

previousDirectionReviewAvailable : Bool
previousDirectionReviewAvailable = ${previous_direction_available}

previousDirectionReviewIndex : Nat
previousDirectionReviewIndex = ${previous_direction_review_index}

previousDirectionReviewRationale : String
previousDirectionReviewRationale = ${previous_direction_review_rationale_expr}

previousCurrentSummary : String
previousCurrentSummary = ${previous_current_expr}

previousNextSummary : String
previousNextSummary = ${previous_next_expr}
EOF2

agda -i "${input_root}" -i . -i src --compile \
  --compile-dir="${build_dir}" src/Govenv/Adapter/RoadmapEvolution.agda >/dev/null
"${build_dir}/RoadmapEvolution"

if ! agda -i "${input_root}" -i . -i src \
    src/Govenv/Adapter/PurposeVigilance.agda >/dev/null; then
  echo "Project purpose vigilance failed: execute the 'Project purpose stewardship' Protocol review over the complete resulting roadmap. Record fresh purposeReviewRationale, then either advance purposeReviewIndex by one when reaffirming the unchanged purpose or revise purpose and reset the index to zero. Never change the counter alone." >&2
  exit 4
fi

if ! agda -i "${input_root}" -i . -i src \
    src/Govenv/Adapter/DirectionReviewVigilance.agda >/dev/null; then
  echo "Project direction review is stale: execute the 'Project direction review' Protocol over Purpose × Current against the resulting roadmap. Record fresh reviewRationale, then update Current/Next and reset the witness or advance it exactly once when reaffirming them. Never change the counter alone." >&2
  exit 4
fi
