# Architecture

Project-specific governance lives under `Govenv/`.
Reusable implementation lives under the reserved `Govenv.Kernel.*` namespace in `src/`.

```agda
module Govenv.Architecture where

open import Agda.Builtin.Unit

ArchitectureValid : Set
ArchitectureValid = ⊤

architectureValid : ArchitectureValid
architectureValid = tt
```
