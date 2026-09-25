# GV121 ungated-candidate counterexample

GV119 established a soft learning gate in the model and a hard release gate, but
the direct pull-request `Test` workflow did not invoke any candidate learning
gate. A substantive candidate could therefore receive a green candidate check
without a fresh learning assessment or closure decision.

GV121 preserves that observed assurance gap as a counterexample and closes it by
making the direct pull-request Test workflow invoke the governed candidate gate
after transient materialization and before ordinary candidate validation.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV121.Counterexample.UngatedCandidate where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Kernel.Learning

unlearned : LearningDebt
unlearned =
  learningRequirement "Unlearned conceptual expansion" "candidate-base" ∷ []

governedDecisionRejectsUngatedFeature :
  candidateLearningAllowed
    feature expands true false true unlearned noBypass ≡ false
governedDecisionRejectsUngatedFeature = refl
```
