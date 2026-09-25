# GV110 mechanical-bump counterexample

PR #49 (GV119) changed the semantic roadmap and silently advanced
`purposeReviewIndex` plus the direction-review index without producing fresh
review rationale. PR #46 (GV118) then repeated the same mechanical purpose
reaffirmation. The previous assurance accepted both states because the counter
transition alone satisfied `protocolVigilanceFresh`.

This counterexample preserves the regression: a bare counter bump is a valid
counter transition, but is not sufficient evidence that the owning Protocol
review was actively exercised. `protocolReviewFresh` therefore rejects the
same transition unless explicit review evidence also changes.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV110.Counterexample.MechanicalBump where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Govenv.Kernel.Protocol using
  (protocolVigilanceFresh; protocolReviewFresh)

oldBoundaryAcceptedMechanicalBump :
  protocolVigilanceFresh true false 5 6 ≡ true
oldBoundaryAcceptedMechanicalBump = refl

strengthenedBoundaryRejectsMechanicalBump :
  protocolReviewFresh true false false 5 6 ≡ false
strengthenedBoundaryRejectsMechanicalBump = refl
```
