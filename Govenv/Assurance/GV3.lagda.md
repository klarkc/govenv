# GV3 assurance

GV3 is statically satisfied by exhaustive construction and elimination of the three governed `Verdict` cases.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV3 where

open import Agda.Builtin.Bool using (Bool; true)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Kernel.Assurance using (StaticEvidence; staticEvidence)
open import Govenv.Kernel.Verdict using (Verdict; holds; violated; unknown)

verdictCovered : Verdict ⊤ ⊤ → Bool
verdictCovered holds = true
verdictCovered (violated diagnostic) = true
verdictCovered (unknown obligation) = true

Proposition : Set
Proposition = (verdict : Verdict ⊤ ⊤) → verdictCovered verdict ≡ true

proof : Proposition
proof holds = refl
proof (violated diagnostic) = refl
proof (unknown obligation) = refl

evidence : StaticEvidence 3
evidence = staticEvidence Proposition proof
```
