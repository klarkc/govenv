# GV6 assurance

GV6 is statically satisfied by a `Rule` whose `check` input is indexed by a non-empty dependency list.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV6 where

open import Agda.Builtin.Bool using (Bool; true)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Kernel.Assurance using (StaticEvidence; staticEvidence)
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using (holds)

Observation : Bool → Set
Observation subject = ⊤

Proposition : Set
Proposition = Rule Bool Observation (true ∷ []) ⊤ ⊤

proof : Proposition
proof = record { check = λ facts → holds }

evidence : StaticEvidence 6
evidence = staticEvidence Proposition proof
```
