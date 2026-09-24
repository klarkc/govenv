# Project

Govenv has one canonical project identity and purpose. Distributions may project
other branding, but they do not rename Govenv itself or redefine its purpose.
The same canonical purpose is projected as the public repository statement,
including the README hero and GitHub repository description. Public repository
metadata is governed project state rather than independently maintained GitHub
configuration.

`purposeReviewIndex` is a vigilance witness for Protocol stewardship. It does
not claim that the purpose is objectively correct; it records that a roadmap
change explicitly reaffirmed the current purpose, or resets when the purpose is
revised.

```agda
{-# OPTIONS --safe #-}

module Govenv.Project where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat; zero; suc; _<_)
open import Agda.Builtin.String using (String; primStringToList)

data ProjectId : Set where
  govenv : ProjectId

project : ProjectId
project = govenv

name : String
name = "Govenv"

purposeCharacterLimit : Nat
purposeCharacterLimit = 250

purpose : String
purpose = "Turn every repository into a self-governing developer environment: define what valid means once, catch problems early, and reproduce the same tooling, automation, and runtime anywhere."

purposeReviewIndex : Nat
purposeReviewIndex = suc (suc (suc (suc zero)))

website : String
website = "https://klarkc.github.io/govenv/"

topics : List String
topics =
    "agda"
  ∷ "ai-agents"
  ∷ "devenv"
  ∷ "formal-methods"
  ∷ "nix"
  ∷ "repository-governance"
  ∷ []

private
  length : {A : Set} → List A → Nat
  length [] = zero
  length (_ ∷ xs) = suc (length xs)

purposeWithinLimit :
  (length (primStringToList purpose) < suc purposeCharacterLimit) ≡ true
purposeWithinLimit = refl
```
