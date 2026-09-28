{-# OPTIONS --safe #-}

module Govenv.Adapter.LearningEvidenceProgress where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Govenv.Adapter.LearningEvidenceObservation using
  (previousDebtCount; currentDebtCount)
open import Govenv.Kernel.Learning using (learningEvidenceCandidateAllowed)

evidenceOnlyCandidateIsAllowed :
  learningEvidenceCandidateAllowed true previousDebtCount currentDebtCount ≡ true
evidenceOnlyCandidateIsAllowed = refl
