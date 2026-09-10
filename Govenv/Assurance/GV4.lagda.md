# GV4 assurance

GV4 is statically satisfied by constructing the minimal governed `Rule` shape with no fact dependencies.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV4 where

open import Agda.Builtin.Bool using (Bool)
open import Agda.Builtin.List using ([])
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Kernel.Assurance using (StaticEvidence; staticEvidence)
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using (holds)

Observation : Bool → Set
Observation subject = ⊤

Proposition : Set
Proposition = Rule Bool Observation [] ⊤ ⊤

proof : Proposition
proof = record { check = λ facts → holds }

evidence : StaticEvidence 4
evidence = staticEvidence Proposition proof
```
