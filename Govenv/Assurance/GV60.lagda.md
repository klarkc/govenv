# GV60 assurance

GV60 is an observed invariant. The governed rule compares the candidate `README.md` contents with the canonical `Govenv.Materialization.Readme` projection; only exact equality establishes candidate evidence.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV60 where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String; primStringEquality)
open import Govenv.Kernel.Assurance using
  ( ObservedEvidence; observedEvidence; CandidateEvidence
  ; checked; checkedEstablished; establishObserved )
open import Govenv.Kernel.Fact using (Facts; observed; empty; _∷ᶠ_)
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using (Verdict; holds; violated)
open import Govenv.Projection.Readme using (renderReadme)

data Subject : Set where
  readmeFile : Subject

Observation : Subject → Set
Observation readmeFile = String

data Diagnostic : Set where
  readmeDrift : Diagnostic

data Obligation : Set where

dependencies : Agda.Builtin.List.List Subject
dependencies = readmeFile ∷ []

check : Facts Subject Observation dependencies → Verdict Diagnostic Obligation
check (observed actual ∷ᶠ empty) with primStringEquality actual renderReadme
... | true = holds
... | false = violated readmeDrift

rule : Rule Subject Observation dependencies Diagnostic Obligation
rule = record { check = check }

evidence : ObservedEvidence 60
evidence = observedEvidence
  Subject
  Observation
  dependencies
  Diagnostic
  Obligation
  rule

data NoLegacy : Nat → Set where

candidateFacts : String → Facts Subject Observation dependencies
candidateFacts actual = observed actual ∷ᶠ empty
