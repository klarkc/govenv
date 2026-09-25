# Learning continuity

Govenv preserves meaningful human authority by keeping conceptual project
evolution coupled to demonstrated human learning. Learning evidence is
revision-bound evidence that a human principal performed a challenge and
response; it is not a proof of the principal's mental state.

Candidate learning assessment is an explicit Protocol judgment over the exact
candidate delta. Its classification is human-reviewable rather than compiler-
inferred: validation proves that the assessment was refreshed when candidate
state changed and that the governed gate follows from the recorded assessment,
requirements, evidence, debt, and bypass. It does not prove that a semantic
classification or natural-language rationale is correct.

```agda
{-# OPTIONS --safe #-}

module Govenv.Learning where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringEquality)
open import Govenv.Authorization using (HumanPrincipal; Revision)
open import Govenv.Kernel.Learning public

record DemonstratedLearning : Set where
  constructor demonstratedLearning
  field
    requirement : LearningRequirement
    principal : HumanPrincipal
    challenge : String
    response : String
    evidenceRevision : Revision

private
  _and_ : Bool → Bool → Bool
  true and right = right
  false and right = false

  _or_ : Bool → Bool → Bool
  true or right = true
  false or right = right

sameRequirement : LearningRequirement → LearningRequirement → Bool
sameRequirement left right =
  primStringEquality
    (LearningRequirement.claim left)
    (LearningRequirement.claim right)
  and
  primStringEquality
    (LearningRequirement.sourceRevision left)
    (LearningRequirement.sourceRevision right)

containsRequirement : LearningRequirement → LearningDebt → Bool
containsRequirement requirement [] = false
containsRequirement requirement (candidate ∷ rest) =
  sameRequirement requirement candidate or
  containsRequirement requirement rest

evidence : List DemonstratedLearning
evidence = []

requirementEvidenced :
  LearningRequirement →
  List DemonstratedLearning →
  Bool
requirementEvidenced requirement [] = false
requirementEvidenced requirement (candidate ∷ rest) =
  sameRequirement requirement (DemonstratedLearning.requirement candidate) or
  requirementEvidenced requirement rest

allRequirementsEvidenced :
  LearningDebt →
  List DemonstratedLearning →
  Bool
allRequirementsEvidenced [] evidence = true
allRequirementsEvidenced (requirement ∷ rest) evidence =
  requirementEvidenced requirement evidence and
  allRequirementsEvidenced rest evidence

allRequirementsRepresented :
  LearningDebt →
  List DemonstratedLearning →
  LearningDebt →
  Bool
allRequirementsRepresented [] evidence debt = true
allRequirementsRepresented (requirement ∷ rest) evidence debt =
  ( requirementEvidenced requirement evidence or
    containsRequirement requirement debt )
  and
  allRequirementsRepresented rest evidence debt

candidateBoundary : String
candidateBoundary =
  "14559ee1fd1786bf12635d98968d2b52514aca1a"

gateSemanticsRequirement : LearningRequirement
gateSemanticsRequirement =
  learningRequirement
    "Explain why candidate learning classification remains a Protocol judgment while the resulting PR and release gates are governed."
    candidateBoundary

bypassDebtRequirement : LearningRequirement
bypassDebtRequirement =
  learningRequirement
    "Explain why an urgent corrective bypass preserves learning debt and therefore blocks later conceptual expansion until catch-up closes it."
    candidateBoundary

assessment : CandidateLearningAssessment
assessment =
  candidateLearningAssessment
    corrective
    expands
    "GV119 promised a soft PR learning gate but candidate CI did not enforce it; this corrective candidate adds the missing typed assessment and PR boundary, while preserving its own new learning requirements as debt through the urgent corrective bypass."
    (gateSemanticsRequirement ∷ bypassDebtRequirement ∷ [])
    urgentCorrective
    0

outstanding : LearningDebt
outstanding =
  gateSemanticsRequirement
  ∷ bypassDebtRequirement
  ∷ []

assessmentRequirementsClosed : Bool
assessmentRequirementsClosed =
  allRequirementsEvidenced
    (CandidateLearningAssessment.requirements assessment)
    evidence

assessmentRequirementsPreserved : Bool
assessmentRequirementsPreserved =
  allRequirementsRepresented
    (CandidateLearningAssessment.requirements assessment)
    evidence
    outstanding

candidateAllowed : Bool
candidateAllowed =
  candidateLearningAllowed
    (CandidateLearningAssessment.kind assessment)
    (CandidateLearningAssessment.impact assessment)
    (requirementsPresent
      (CandidateLearningAssessment.requirements assessment))
    assessmentRequirementsClosed
    assessmentRequirementsPreserved
    outstanding
    (CandidateLearningAssessment.bypass assessment)
```
