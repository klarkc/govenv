# GV1 assurance

GV1 source-boundary behavior is observed against the versioned Agda source
paths of the candidate repository. Every observed source must remain under the
governed `Govenv.Architecture.sourceRoots`.

The root-level `spike/ConstitutionalHistory.agda` path observed on PR #32 is
preserved as the counterexample that exposed the previously missing assurance
boundary. This closes that observed source-boundary regression but does not by
itself discharge all legacy GV1 assurance debt: identifying whether arbitrary
source is semantically reusable kernel requires a stronger classification model.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV1 where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String)
open import Govenv.Architecture using (sourceRoots)
open import Govenv.Kernel.Architecture using (firstOutsideRoots)
open import Govenv.Kernel.Assurance using
  (ObservedEvidence; observedEvidence)
open import Govenv.Kernel.Fact using
  (Facts; observed; empty; _∷ᶠ_)
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using
  (Verdict; holds; violated)

data Subject : Set where
  trackedAgdaSources : Subject

Observation : Subject → Set
Observation trackedAgdaSources = List String

dependencies : List Subject
dependencies = trackedAgdaSources ∷ []

data Diagnostic : Set where
  sourceOutsideGovenv : String → Diagnostic

data Obligation : Set where
  observeTrackedAgdaSources : Obligation

check :
  Facts Subject Observation dependencies →
  Verdict Diagnostic Obligation
check (observed paths ∷ᶠ empty)
  with firstOutsideRoots sourceRoots paths
... | nothing = holds
... | just path = violated (sourceOutsideGovenv path)

rule : Rule Subject Observation dependencies Diagnostic Obligation
rule = record { check = check }

sourceBoundaryEvidence : ObservedEvidence 1
sourceBoundaryEvidence =
  observedEvidence
    Subject Observation dependencies Diagnostic Obligation rule

counterexampleFacts : Facts Subject Observation dependencies
counterexampleFacts =
  observed ("spike/ConstitutionalHistory.agda" ∷ []) ∷ᶠ empty

counterexampleRejected :
  Rule.check rule counterexampleFacts ≡
  violated
    (sourceOutsideGovenv "spike/ConstitutionalHistory.agda")
counterexampleRejected = refl

canonicalKernelFacts : Facts Subject Observation dependencies
canonicalKernelFacts =
  observed ("src/Govenv/Kernel/Architecture.agda" ∷ []) ∷ᶠ empty

canonicalKernelAccepted :
  Rule.check rule canonicalKernelFacts ≡ holds
canonicalKernelAccepted = refl

existingFrontendFacts : Facts Subject Observation dependencies
existingFrontendFacts =
  observed ("src/Govenv/Roadmap/DSL.agda" ∷ []) ∷ᶠ empty

existingFrontendAccepted :
  Rule.check rule existingFrontendFacts ≡ holds
existingFrontendAccepted = refl
```
