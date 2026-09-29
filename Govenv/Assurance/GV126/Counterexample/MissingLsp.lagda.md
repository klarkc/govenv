# GV126 counterexample — missing matching LSP

The Agda compiler alone is insufficient for GV126. A shell that exposes Agda
2.8.0 but not the matching ALS v8 is rejected by the same observed rule.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV126.Counterexample.MissingLsp where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Govenv.Assurance.GV126 using
  ( Subject; Observation; dependencies; Diagnostic
  ; Obligation; agdaToolchain; agdaLanguageServer
  ; incompatibleAgdaLanguageCapability; rule )
open import Govenv.Kernel.Fact using
  (Facts; observed; empty; _∷ᶠ_)
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using (Verdict; violated)

counterexample : Facts Subject Observation dependencies
counterexample =
  (observed "Agda version 2.8.0") ∷ᶠ
  ((observed "missing") ∷ᶠ
  empty)

rejected :
  Rule.check rule counterexample ≡
  violated incompatibleAgdaLanguageCapability
rejected = refl
```
