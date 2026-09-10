# GV5 assurance

GV5 is statically satisfied by a fact whose observation type is indexed by its repository subject and by a correspondingly indexed fact collection.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV5 where

open import Agda.Builtin.Bool using (Bool; true)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Unit using (⊤; tt)
open import Govenv.Kernel.Assurance using (StaticEvidence; staticEvidence)
open import Govenv.Kernel.Fact using (Facts; observed; empty; _∷ᶠ_)

Observation : Bool → Set
Observation subject = ⊤

Proposition : Set
Proposition = Facts Bool Observation (true ∷ [])

proof : Proposition
proof = observed tt ∷ᶠ empty

evidence : StaticEvidence 5
evidence = staticEvidence Proposition proof
```
