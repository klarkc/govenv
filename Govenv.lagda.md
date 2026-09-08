# Govenv

Govenv is the canonical project entrypoint and formal closure root.

```agda
module Govenv where

open import Agda.Builtin.Unit
open import Govenv.Architecture

projectLoads : Set
projectLoads = ArchitectureValid

projectLoadsProof : projectLoads
projectLoadsProof = architectureValid
```
