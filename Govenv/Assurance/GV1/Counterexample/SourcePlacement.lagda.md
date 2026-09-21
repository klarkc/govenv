# GV1 source-placement counterexample

PR #32 introduced reusable constitutional-history experiments as root-level
Agda modules under `spike/`. That candidate escaped the governed Govenv source
boundary and exposed a missing GV1 assurance.

The contradictory observation is preserved here as governed evidence rather
than as a standalone Markdown fixture. The repair is incomplete unless the
same candidate-state rule continues to reject recurrence.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV1.Counterexample.SourcePlacement where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Assurance.GV1 using
  (Subject; Observation; dependencies; Diagnostic; sourceOutsideGovenv; rule)
open import Govenv.Kernel.Fact using
  (Facts; observed; empty; _∷ᶠ_)
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using (violated)

counterexampleFacts : Facts Subject Observation dependencies
counterexampleFacts =
  observed ("spike/ConstitutionalHistory.agda" ∷ []) ∷ᶠ empty

counterexampleRejected :
  Rule.check rule counterexampleFacts ≡
  violated
    (sourceOutsideGovenv "spike/ConstitutionalHistory.agda")
counterexampleRejected = refl
```

The original candidate also contained sibling paths such as
`spike/ConstitutionalHistoryPropositional.agda` and
`spike/ConstitutionalHistoryStdlib.agda`. One witness is sufficient for the
formal recurrence check because the GV1 rule rejects the first observed source
outside the governed roots.
