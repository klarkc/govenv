# Architecture

Govenv declares the architectural roles of repository areas and the dependency directions allowed between them. Enforcement will move from declaration to repository checking as the evaluator lands.

```agda
{-# OPTIONS --safe #-}

module Govenv.Architecture where

open import Agda.Builtin.List
open import Agda.Builtin.Unit
open import Govenv.Kernel.Architecture

architecture : Architecture
architecture = record
  { areas =
      area "Govenv.lagda.md" closure
    ∷ area "Govenv/Materialization/" materialization
    ∷ area "Govenv/" constitution
    ∷ area "src/Govenv/Kernel/" kernel
    ∷ area "src/Govenv/Projection/" projection
    ∷ area "src/Govenv/Adapter/" adapter
    ∷ area "README.md" generated
    ∷ []
  ; dependencies =
      allow closure constitution
    ∷ allow closure materialization
    ∷ allow closure kernel
    ∷ allow constitution kernel
    ∷ allow materialization constitution
    ∷ allow materialization kernel
    ∷ allow projection materialization
    ∷ allow projection kernel
    ∷ allow adapter projection
    ∷ []
  }

ArchitectureValid : Set
ArchitectureValid = ⊤

architectureValid : ArchitectureValid
architectureValid = tt
```
