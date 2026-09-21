# Source layout

Source layout is the physical discovery boundary for versioned Agda sources.
It is intentionally separate from semantic architecture: a filesystem path can
locate source, but it does not determine the architectural role of an Agda
semantic declaration.

```agda
{-# OPTIONS --safe #-}

module Govenv.SourceLayout where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)

sourceRoots : List String
sourceRoots =
    "Govenv.lagda.md"
  ∷ "Govenv/"
  ∷ "src/Govenv/"
  ∷ []
```
