# GV123 prospective-only counterexample

The first GV122 candidate gate was internally consistent but its learning state
started prospectively: the governed debt contained only requirements introduced
after learning continuity existed. A principal starting from zero could
therefore reach "debt clear" without demonstrating the pre-GV122 concepts
needed to review current Govenv semantics.

This counterexample was caught during human review of PR #53 before merge. GV123
closes it by adding a governed baseline pinned to the pre-GV122 frontier and by
deriving outstanding debt from that baseline together with later carried debt.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV123.Counterexample.ProspectiveOnly where

open import Agda.Builtin.Bool using (false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([])
open import Govenv.Kernel.Learning using
  (LearningDebt; requirementsPresent)

prospectiveHistoricalBaseline : LearningDebt
prospectiveHistoricalBaseline = []

prospectiveOnlyCouldNotRepresentHistoricalLearning :
  requirementsPresent prospectiveHistoricalBaseline ≡ false
prospectiveOnlyCouldNotRepresentHistoricalLearning = refl
```
