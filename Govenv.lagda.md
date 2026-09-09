# Govenv

Govenv is the canonical project entrypoint and formal closure root.

```agda
module Govenv where

open import Agda.Builtin.Unit
open import Govenv.Architecture
open import Govenv.Kernel.Fact
open import Govenv.Kernel.Verdict
open import Govenv.Kernel.Rule

projectLoads : Set
projectLoads = ArchitectureValid

projectLoadsProof : projectLoads
projectLoadsProof = architectureValid
```
