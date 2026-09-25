{-# OPTIONS --safe #-}

module Govenv.Kernel.Learning where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Release using (ReleaseKind; major; minor; patch)

data CandidateKind : Set where
  corrective feature refactor other : CandidateKind

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

debtClear : LearningDebt → Bool
debtClear [] = true
debtClear (_ ∷ _) = false

prLearningAllowed : CandidateKind → LearningDebt → LearningBypass → Bool
prLearningAllowed candidate debt bypass with debtClear debt
... | true = true
prLearningAllowed corrective debt urgentCorrective | false = true
prLearningAllowed candidate debt bypass | false = false

releaseLearningAllowed : ReleaseKind → LearningDebt → Bool
releaseLearningAllowed patch debt = true
releaseLearningAllowed major debt = debtClear debt
releaseLearningAllowed minor debt = debtClear debt
