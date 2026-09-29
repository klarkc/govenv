# Agda style rule catalog

Govenv inherits the Agda standard-library style guide as its baseline and may
compose additional project-specific rules. Baseline rules keep their upstream
identity and origin; Govenv additions are a separate layer and never rewrite
the baseline.

This catalog is intentionally incomplete while GV127 remains pending. Coverage
must therefore be reported as counts over the catalogued subset, never as
"100% of the stdlib style guide" until `baselineInventoryComplete` becomes
true through a reviewed inventory of the full pinned guide.

```agda
{-# OPTIONS --safe #-}

module Govenv.AgdaStyle where

open import Agda.Builtin.Bool using (Bool; false; true)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat; zero; suc)
open import Agda.Builtin.String using (String)

data RuleOrigin : Set where
  stdlib : RuleOrigin
  govenv : RuleOrigin

data Mechanism : Set where
  lint : Mechanism
  formatter : Mechanism
  both : Mechanism
  manual : Mechanism

record StyleRule : Set where
  constructor rule
  field
    id : String
    origin : RuleOrigin
    mechanism : Mechanism
    description : String

baselineInventoryComplete : Bool
baselineInventoryComplete = false

rules : List StyleRule
rules =
    rule "stdlib-line-length-72" stdlib lint
      "Check the stdlib 72-character line-length guideline."
  ∷ rule "stdlib-no-unicode-instance-braces" stdlib lint
      "Prefer ASCII {{_}} instance syntax over Unicode instance braces."
  ∷ rule "stdlib-no-mutual-block" stdlib lint
      "Treat mutual blocks as obsolete in favor of signatures before definitions."
  ∷ rule "govenv-safe-formal-source" govenv lint
      "Require --safe in governed literate Agda and reusable kernel source."
  ∷ rule "govenv-no-kernel-postulate" govenv lint
      "Keep reusable kernel source free of postulates."
  ∷ []

count : {A : Set} → List A → Nat
count [] = zero
count (_ ∷ xs) = suc (count xs)

filterOrigin : RuleOrigin → List StyleRule → List StyleRule
filterOrigin wanted [] = []
filterOrigin stdlib (r ∷ rs) with StyleRule.origin r
... | stdlib = r ∷ filterOrigin stdlib rs
... | govenv = filterOrigin stdlib rs
filterOrigin govenv (r ∷ rs) with StyleRule.origin r
... | stdlib = filterOrigin govenv rs
... | govenv = r ∷ filterOrigin govenv rs

cataloguedBaselineRules : Nat
cataloguedBaselineRules = count (filterOrigin stdlib rules)

cataloguedCustomRules : Nat
cataloguedCustomRules = count (filterOrigin govenv rules)

cataloguedRules : Nat
cataloguedRules = count rules
```
