# Human learning evidence

This module stores exact human-produced review-contract/response evidence used
to close Govenv learning requirements. The capture tool may mechanically append
the human principal identity, governed requirement, exact current review
contract, and exact response, but it must not synthesize, rewrite, or grade the
response. Review-contract matching is evidence freshness, not proof of mental
state or response quality.

```agda
{-# OPTIONS --safe #-}

module Govenv.LearningEvidence where

open import Agda.Builtin.Equality using (refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)
open import Govenv.Authorization using
  (HumanPrincipal; humanPrincipal; observedPrincipal; human)
open import Govenv.Kernel.Learning using
  (LearningRequirement; learningRequirement)

record DemonstratedLearning : Set where
  constructor demonstratedLearning
  field
    requirement : LearningRequirement
    principal : HumanPrincipal
    reviewContract : String
    response : String

claimedHumanPrincipal : String → HumanPrincipal
claimedHumanPrincipal identity =
  humanPrincipal (observedPrincipal identity human) refl

evidence : List DemonstratedLearning
evidence =
  -- govenv-learning-evidence:start
  []
  -- govenv-learning-evidence:end
```
