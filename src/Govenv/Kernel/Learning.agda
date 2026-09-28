{-# OPTIONS --safe #-}

module Govenv.Kernel.Learning where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat; zero; suc; _<_)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Release using (ReleaseKind; major; minor; patch)

data CandidateKind : Set where
  corrective feature refactor learningEvidence other : CandidateKind

data LearningImpact : Set where
  none reinforces expands : LearningImpact

data LearningBypass : Set where
  noBypass urgentCorrective : LearningBypass

record LearningRequirement : Set where
  constructor learningRequirement
  field
    claim : String
    sourceRevision : String

LearningDebt : Set
LearningDebt = List LearningRequirement

record CandidateLearningAssessment : Set where
  constructor candidateLearningAssessment
  field
    kind : CandidateKind
    impact : LearningImpact
    rationale : String
    requirements : LearningDebt
    bypass : LearningBypass
    reviewIndex : Nat

record LearningSnapshot : Set where
  constructor learningSnapshot
  field
    snapshotBootstrapComplete : Bool
    snapshotDebtCount : Nat
    snapshotDebtClear : Bool
    snapshotCandidateAllowed : Bool
    snapshotAssessment : CandidateLearningAssessment

debtCount : LearningDebt → Nat
debtCount [] = zero
debtCount (_ ∷ rest) = suc (debtCount rest)

learningEvidenceProgress : Nat → Nat → Bool
learningEvidenceProgress previous current = current < previous

learningEvidenceCandidateAllowed : Bool → Nat → Nat → Bool
learningEvidenceCandidateAllowed true previous current =
  learningEvidenceProgress previous current
learningEvidenceCandidateAllowed false previous current = false

debtClear : LearningDebt → Bool
debtClear [] = true
debtClear (_ ∷ _) = false

requirementsPresent : LearningDebt → Bool
requirementsPresent [] = false
requirementsPresent (_ ∷ _) = true

sameCandidateKind : CandidateKind → CandidateKind → Bool
sameCandidateKind corrective corrective = true
sameCandidateKind feature feature = true
sameCandidateKind refactor refactor = true
sameCandidateKind learningEvidence learningEvidence = true
sameCandidateKind other other = true
sameCandidateKind left right = false

sameLearningImpact : LearningImpact → LearningImpact → Bool
sameLearningImpact none none = true
sameLearningImpact reinforces reinforces = true
sameLearningImpact expands expands = true
sameLearningImpact left right = false

sameLearningBypass : LearningBypass → LearningBypass → Bool
sameLearningBypass noBypass noBypass = true
sameLearningBypass urgentCorrective urgentCorrective = true
sameLearningBypass left right = false

private
  expandsRequirementsValid : LearningImpact → Bool → Bool
  expandsRequirementsValid expands hasRequirements = hasRequirements
  expandsRequirementsValid none hasRequirements = true
  expandsRequirementsValid reinforces hasRequirements = true

  learningEvidenceShapeValid :
    CandidateKind →
    LearningImpact →
    Bool →
    LearningBypass →
    Bool
  learningEvidenceShapeValid learningEvidence expands hasRequirements bypass = false
  learningEvidenceShapeValid learningEvidence impact true bypass = false
  learningEvidenceShapeValid learningEvidence impact false urgentCorrective = false
  learningEvidenceShapeValid learningEvidence impact false noBypass = true
  learningEvidenceShapeValid candidate impact hasRequirements bypass = true

  baseGate :
    CandidateKind →
    LearningDebt →
    LearningBypass →
    Bool
  baseGate learningEvidence debt noBypass = true
  baseGate candidate debt bypass with debtClear debt
  ... | true = true
  baseGate corrective debt urgentCorrective | false = true
  baseGate candidate debt bypass | false = false

candidateLearningAllowed :
  CandidateKind →
  LearningImpact →
  Bool →
  Bool →
  Bool →
  LearningDebt →
  LearningBypass →
  Bool
candidateLearningAllowed kind impact hasRequirements closed preserved debt bypass
  with learningEvidenceShapeValid kind impact hasRequirements bypass
... | false = false
... | true with expandsRequirementsValid impact hasRequirements
...   | false = false
candidateLearningAllowed kind expands hasRequirements false preserved debt noBypass
  | true | true = false
candidateLearningAllowed kind expands hasRequirements false false debt urgentCorrective
  | true | true = false
candidateLearningAllowed kind impact hasRequirements closed preserved debt bypass
  | true | true = baseGate kind debt bypass

prLearningAllowed : CandidateKind → LearningDebt → LearningBypass → Bool
prLearningAllowed candidate debt bypass =
  baseGate candidate debt bypass

releaseLearningAllowed : ReleaseKind → LearningDebt → Bool
releaseLearningAllowed patch debt = true
releaseLearningAllowed major debt = debtClear debt
releaseLearningAllowed minor debt = debtClear debt
