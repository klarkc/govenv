#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

base_sha="${GOVENV_CANDIDATE_BASE_SHA:-${1:-}}"
if [[ -z "$base_sha" ]]; then
  echo "Candidate learning gate requires GOVENV_CANDIDATE_BASE_SHA or a base SHA argument." >&2
  exit 3
fi

git rev-parse --verify "$base_sha^{commit}" >/dev/null 2>&1 || {
  echo "Candidate learning gate cannot resolve base revision: $base_sha" >&2
  exit 3
}

substantive=false
while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  case "$path" in
    README.md|AGENTS.md|CHANGELOG.md|devenv.lock|.govenv/*|.github/workflows/*)
      ;;
    *)
      substantive=true
      break
      ;;
  esac
done < <(git diff --name-only "$base_sha"...HEAD --)

if [[ "$substantive" != true ]]; then
  echo "Learning candidate gate: no substantive candidate delta."
  exit 0
fi

snapshot=".govenv/learning.snapshot"
[[ -f "$snapshot" ]] || {
  echo "Learning candidate gate requires the governed learning snapshot." >&2
  exit 4
}

if ! grep -Fxq 'govenv-learning-snapshot-v2' "$snapshot"; then
  echo "Learning candidate gate requires learning snapshot v2 for substantive candidates." >&2
  exit 4
fi

candidate_allowed="$(awk '$1 == "candidate-allowed" { print $2; exit }' "$snapshot")"
if [[ "$candidate_allowed" != true && "$candidate_allowed" != false ]]; then
  echo "Learning snapshot has no valid candidate-allowed value." >&2
  exit 4
fi

input_root=".govenv/learning-candidate-input"
input_dir="$input_root/Govenv/Adapter"
mkdir -p "$input_dir"

previous_available=false
previous_kind=other
previous_impact=none
previous_bypass=noBypass
previous_rationale='""'
previous_index=0

previous_snapshot="$input_root/previous-learning.snapshot"
if git show "$base_sha:.govenv/learning.snapshot" > "$previous_snapshot" 2>/dev/null; then
  header="$(sed -n '1p' "$previous_snapshot")"
  if [[ "$header" == "govenv-learning-snapshot-v2" ]]; then
    previous_available=true

    kind_value="$(awk '$1 == "assessment-kind" { print $2; exit }' "$previous_snapshot")"
    case "$kind_value" in
      corrective|feature|refactor|other) previous_kind="$kind_value" ;;
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
  elif [[ "$header" != "govenv-learning-snapshot-v1" ]]; then
    echo "Unsupported previous learning snapshot format: $header" >&2
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

if [[ "$candidate_allowed" != true ]]; then
  echo "Learning candidate gate is closed by governed assessment/debt state." >&2
  exit 5
fi

echo "Learning candidate gate: assessment is fresh and candidate is allowed."
