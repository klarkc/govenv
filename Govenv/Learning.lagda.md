# Learning continuity

Govenv preserves meaningful human authority by keeping conceptual project
evolution coupled to demonstrated human learning. Learning evidence is
revision-bound evidence that a human principal performed a challenge and
response; it is not a proof of the principal's mental state.

The canonical outstanding debt below is the set of learning requirements that
remain open after authorized bypasses. This GV bootstraps prospectively with no
pre-existing debt; later corrective bypasses must preserve their outstanding
requirements here until human-produced evidence closes them.

```agda
{-# OPTIONS --safe #-}

module Govenv.Learning where

open import Agda.Builtin.List using (List; [])
open import Agda.Builtin.String using (String)
open import Govenv.Authorization using (HumanPrincipal; Revision)
open import Govenv.Kernel.Learning public

record DemonstratedLearning : Set where
  constructor demonstratedLearning
  field
    requirement : LearningRequirement
    principal : HumanPrincipal
    challenge : String
    response : String
    evidenceRevision : Revision

evidence : List DemonstratedLearning
evidence = []

outstanding : LearningDebt
outstanding = []
```
