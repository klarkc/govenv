{-# OPTIONS --safe #-}

module Govenv.Adapter.LearningCandidateVigilance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.String using (primStringEquality)
open import Govenv.Adapter.LearningCandidateObservation
open import Govenv.Kernel.Learning
open import Govenv.Kernel.Protocol using (protocolReviewFresh)
open import Govenv.Learning using (assessment; candidateAllowed)

private
  not : Bool → Bool
  not true = false
  not false = true

  _and_ : Bool → Bool → Bool
  true and right = right
  false and right = false

assessmentSubjectChanged : Bool
assessmentSubjectChanged =
  not
    ( sameCandidateKind
        previousAssessmentKind
        (CandidateLearningAssessment.kind assessment)
      and
      sameLearningImpact
        previousAssessmentImpact
        (CandidateLearningAssessment.impact assessment)
      and
      sameLearningBypass
        previousAssessmentBypass
        (CandidateLearningAssessment.bypass assessment)
    )

assessmentEvidenceChanged : Bool
assessmentEvidenceChanged =
  not
    (primStringEquality
      previousAssessmentRationale
      (CandidateLearningAssessment.rationale assessment))

assessmentFresh : Bool
assessmentFresh with previousAssessmentAvailable
... | false = true
... | true =
  protocolReviewFresh
    candidateChanged
    assessmentSubjectChanged
    assessmentEvidenceChanged
    previousAssessmentReviewIndex
    (CandidateLearningAssessment.reviewIndex assessment)

candidateAssessmentVigilance : assessmentFresh ≡ true
candidateAssessmentVigilance = refl

candidateLearningGate : candidateAllowed ≡ true
candidateLearningGate = refl
