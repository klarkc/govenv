# Project

Govenv has one canonical project identity and purpose. Distributions may project
other branding, but they do not rename Govenv itself or redefine its purpose.
Public repository metadata is governed project state rather than independently
maintained GitHub configuration.

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

descriptionCharacterLimit : Nat
descriptionCharacterLimit = 250

purposeCharacterLimit : Nat
purposeCharacterLimit = 500

description : String
description = "A type system for your repository. Govern code, configuration, tooling, CI, and AI agents through one typed Govenv model."

purpose : String
purpose = "Turn a repository into a formally governed environment where code, configuration, tooling, CI, and AI agents operate from one typed and verifiable Govenv semantic model, with Governance defining validity, Protocol guiding process, and governable obligations enforced at their earliest sound information boundary."

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

descriptionWithinLimit :
  (length (primStringToList description) < suc descriptionCharacterLimit) ≡ true
descriptionWithinLimit = refl

purposeWithinLimit :
  (length (primStringToList purpose) < suc purposeCharacterLimit) ≡ true
purposeWithinLimit = refl
```
