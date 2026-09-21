# Architecture

Govenv architecture is semantic, not path-derived. Architectural subjects are
Agda declaration identities (`Name`) and roles describe their semantic place in
the system. Source paths belong to `Govenv.SourceLayout`; the root closure is
owned by `Govenv.lagda.md`; generated artifacts belong to their materialization
authority. None of those transport/layout concerns is an architectural role.

GV98 is still pending. This module therefore defines the architectural role
vocabulary and allowed dependency directions without claiming that every
repository declaration has already been classified or that those dependencies
are already enforced.

```agda
{-# OPTIONS --safe #-}

module Govenv.Architecture where

open import Agda.Builtin.List using (List; []; _∷_)
open import Govenv.Kernel.Architecture

allowedDependencies : List Dependency
allowedDependencies =
    allow governance kernel
  ∷ allow protocol governance
  ∷ allow assurance governance
  ∷ allow assurance protocol
  ∷ allow assurance materialization
  ∷ allow assurance kernel
  ∷ allow experiment kernel
  ∷ allow materialization governance
  ∷ allow materialization protocol
  ∷ allow materialization kernel
  ∷ allow projection materialization
  ∷ allow projection kernel
  ∷ allow adapter assurance
  ∷ allow adapter projection
  ∷ []
```
