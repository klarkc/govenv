# Architecture

Govenv declares the architectural roles of repository areas and the dependency directions allowed between them. Candidate validation observes every versioned Agda and literate-Agda source path and requires it to remain inside the governed Govenv source roots. This source-boundary check is intentionally narrower than total area classification: existing frontend source such as `src/Govenv/Roadmap/DSL.agda` is valid project source even though frontend is not yet modeled as an architecture role. `Architecture/source-placement-counterexample.md` preserves the PR #32 GV1 regression that exposed the previously missing source-boundary assurance.

```agda
{-# OPTIONS --safe #-}

module Govenv.Architecture where

open import Agda.Builtin.List
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit
open import Govenv.Kernel.Architecture

sourceRoots : List String
sourceRoots =
    "Govenv.lagda.md"
  ∷ "Govenv/"
  ∷ "src/Govenv/"
  ∷ []

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
    ∷ area ".govenv/roadmap.snapshot" generated
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
