#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

comparison_base_sha="${GOVENV_CANDIDATE_COMPARISON_BASE_SHA:-${GOVENV_CANDIDATE_BASE_SHA:-${1:-}}}"
target_branch="${GOVENV_CANDIDATE_TARGET_BRANCH:-}"
authorized_branch="${GOVENV_AUTHORIZED_BRANCH:-}"

if [[ -z "$comparison_base_sha" || -z "$target_branch" || -z "$authorized_branch" ]]; then
  echo "Candidate learning gate requires comparison-base SHA, target branch, and governed authorized branch." >&2
  exit 3
fi

git rev-parse --verify "$comparison_base_sha^{commit}" >/dev/null 2>&1 || {
  echo "Candidate learning gate cannot resolve comparison base revision: $comparison_base_sha" >&2
  exit 3
}

candidate_boundary=candidateComposition
if [[ "$target_branch" == "$authorized_branch" ]]; then
  candidate_boundary=authorizationBoundary
fi

substantive_paths=()
while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  case "$path" in
    README.md|AGENTS.md|CHANGELOG.md|devenv.lock|.govenv/*|.github/workflows/*)
      ;;
    *)
      substantive_paths+=("$path")
      ;;
  esac
done < <(git diff --name-only "$comparison_base_sha"...HEAD --)

if [[ "${#substantive_paths[@]}" -eq 0 ]]; then
  echo "Learning candidate gate: no substantive candidate delta."
  exit 0
fi

evidence_only=false
if [[ "${#substantive_paths[@]}" -eq 1 &&
      "${substantive_paths[0]}" == "Govenv/LearningEvidence.lagda.md" ]]; then
  evidence_only=true
fi

snapshot=".govenv/learning.snapshot"
[[ -f "$snapshot" ]] || {
  echo "Learning candidate gate requires the governed learning snapshot." >&2
  exit 4
}

snapshot_header="$(sed -n '1p' "$snapshot")"
if [[ "$snapshot_header" != "govenv-learning-snapshot-v3" ]]; then
  echo "Learning candidate gate requires learning snapshot v3 for substantive candidates." >&2
  exit 4
fi

input_root=".govenv/learning-candidate-input"
input_dir="$input_root/Govenv/Adapter"
mkdir -p "$input_dir"

previous_snapshot="$input_root/previous-learning.snapshot"
previous_header=""
if git show "$comparison_base_sha:.govenv/learning.snapshot" > "$previous_snapshot" 2>/dev/null; then
  previous_header="$(sed -n '1p' "$previous_snapshot")"
fi

if [[ "$evidence_only" == true ]]; then
  if [[ "$previous_header" != "govenv-learning-snapshot-v3" ]]; then
    echo "Learning-evidence candidates require a v3 predecessor snapshot." >&2
    exit 4
  fi

  previous_debt_count="$(awk '$1 == "debt-count" { print $2; exit }' "$previous_snapshot")"
  current_debt_count="$(awk '$1 == "debt-count" { print $2; exit }' "$snapshot")"

  [[ "$previous_debt_count" =~ ^[0-9]+$ && "$current_debt_count" =~ ^[0-9]+$ ]] || {
    echo "Learning evidence progress requires valid debt-count values." >&2
    exit 4
  }

  cat > "$input_dir/LearningEvidenceObservation.agda" <<EOF
{-# OPTIONS --safe #-}
module Govenv.Adapter.LearningEvidenceObservation where

open import Agda.Builtin.Nat using (Nat)

previousDebtCount : Nat
previousDebtCount = $previous_debt_count

currentDebtCount : Nat
currentDebtCount = $current_debt_count
EOF

  if ! agda -i "$input_root" -i . -i src       src/Govenv/Adapter/LearningEvidenceProgress.agda >/dev/null; then
    echo "Learning-evidence candidate did not reduce outstanding learning debt." >&2
    exit 5
  fi

  echo "Learning candidate gate: human evidence-only candidate reduces debt."
  exit 0
fi

previous_available=false
previous_kind=other
previous_impact=none
previous_bypass=noBypass
previous_rationale='""'
previous_index=0

if [[ -n "$previous_header" ]]; then
  if [[ "$previous_header" == "govenv-learning-snapshot-v2" ||
        "$previous_header" == "govenv-learning-snapshot-v3" ]]; then
    previous_available=true

    kind_value="$(awk '$1 == "assessment-kind" { print $2; exit }' "$previous_snapshot")"
    case "$kind_value" in
      corrective|feature|refactor|other) previous_kind="$kind_value" ;;
      learning-evidence) previous_kind=learningEvidence ;;
      *) echo "Invalid previous learning assessment kind: $kind_value" >&2; exit 4 ;;
    esac

    impact_value="$(awk '$1 == "assessment-impact" { print $2; exit }' "$previous_snapshot")"
    case "$impact_value" in
      none|reinforces|expands) previous_impact="$impact_value" ;;
      *) echo "Invalid previous learning assessment impact: $impact_value" >&2; exit 4 ;;
    esac

    bypass_value="$(awk '$1 == "assessment-bypass" { print $2; exit }' "$previous_snapshot")"
    case "$bypass_value" in
      none) previous_bypass=noBypass ;;
      urgent-corrective) previous_bypass=urgentCorrective ;;
      *) echo "Invalid previous learning assessment bypass: $bypass_value" >&2; exit 4 ;;
    esac

    previous_index="$(awk '$1 == "review-index" { print $2; exit }' "$previous_snapshot")"
    [[ "$previous_index" =~ ^[0-9]+$ ]] || {
      echo "Invalid previous learning assessment review index." >&2
      exit 4
    }

    previous_rationale="$(sed -n 's/^review-rationale //p' "$previous_snapshot" | head -1)"
    [[ "$previous_rationale" =~ ^\".*\"$ ]] || {
      echo "Invalid previous learning assessment rationale." >&2
      exit 4
    }
  elif [[ "$previous_header" != "govenv-learning-snapshot-v1" ]]; then
    echo "Unsupported previous learning snapshot format: $previous_header" >&2
    exit 4
  fi
fi

cat > "$input_dir/LearningCandidateObservation.agda" <<EOF
{-# OPTIONS --safe #-}
module Govenv.Adapter.LearningCandidateObservation where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Learning

candidateBoundary : CandidateLearningBoundary
candidateBoundary = $candidate_boundary

previousAssessmentAvailable : Bool
previousAssessmentAvailable = $previous_available

previousAssessmentKind : CandidateKind
previousAssessmentKind = $previous_kind

previousAssessmentImpact : LearningImpact
previousAssessmentImpact = $previous_impact

previousAssessmentBypass : LearningBypass
previousAssessmentBypass = $previous_bypass

previousAssessmentRationale : String
previousAssessmentRationale = $previous_rationale

previousAssessmentReviewIndex : Nat
previousAssessmentReviewIndex = $previous_index

candidateChanged : Bool
candidateChanged = true
EOF

if ! agda -i "$input_root" -i . -i src     src/Govenv/Adapter/LearningCandidateVigilance.agda >/dev/null; then
  echo "Learning candidate review is stale or the candidate gate is closed." >&2
  echo "Refresh Govenv.Learning.assessment for this candidate; do not mechanically change reviewIndex." >&2
  exit 5
fi

echo "Learning candidate gate: assessment is fresh and boundary decision is allowed."
