# GV125 counterexample: legacy checks re-owned the authorization boundary

After GV125 authorized the distinction between candidate composition and semantic
authorization, integration testing with an expanding candidate carrying open debt
exposed two legacy checks that still collapsed the distinction.

The shell adapter first typechecked `candidateBoundaryAllowed`, but then separately
read `candidate-allowed` from the snapshot and rejected `false` for every target.
At the same time, `Govenv.Assurance.GV122` required the repository's current
`candidateAllowed` value to be `true`, so an otherwise valid candidate-composition
state made the ordinary `govenv check` closure fail before the pull-request target
could matter.

Those checks were valid for GV122's original single authorization boundary, but
became counterexamples once GV125 made the target boundary explicit. The adapter
must translate observations and let the typed boundary decision own acceptance;
static GV122 assurance must prove the learning decision semantics rather than
require every repository candidate to be globally authorizable.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV125.Counterexample.BoundaryReownedByLegacyChecks where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Kernel.Learning

openDebt : LearningDebt
openDebt =
  learningRequirement
    "Explain the review-system roadmap."
    "candidate-base"
  ∷ []

compositionDecision :
  candidateCompositionAllowed
    feature expands true false true noBypass ≡ true
compositionDecision = refl

authorizationDecision :
  candidateLearningAllowed
    feature expands true false true openDebt noBypass ≡ false
authorizationDecision = refl

compositionUsesItsOwnDecision :
  candidateBoundaryAllowed candidateComposition true false ≡ true
compositionUsesItsOwnDecision = refl

authorizationUsesItsOwnDecision :
  candidateBoundaryAllowed authorizationBoundary true false ≡ false
authorizationUsesItsOwnDecision = refl
```
