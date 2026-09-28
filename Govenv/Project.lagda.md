# Project

Govenv has one canonical project identity and purpose. Distributions may project
other branding, but they do not rename Govenv itself or redefine its purpose.
The same canonical purpose is projected as the public repository statement,
including the README hero and GitHub repository description. Public repository
metadata is governed project state rather than independently maintained GitHub
configuration.

`purposeReviewIndex` is the freshness counter for Protocol stewardship and
`purposeReviewRationale` is the explicit evidence that the triggered review was
actually exercised. Neither claims that the purpose is objectively correct.
The rationale must change whenever the review is triggered; the counter alone
must never satisfy vigilance.

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
purpose = "Turn every repository into a self-governing developer environment: define what valid means once, let agents move fast without outrunning human authority, and reproduce the same tooling, automation, and runtime anywhere."

purposeReviewRationale : String
purposeReviewRationale =
  "GV123 now makes the learning gate operationally reachable from zero through governed prompts, exact human-response capture, and debt-reducing evidence-only pull requests; this strengthens the existing human-authority purpose without changing it."

purposeReviewIndex : Nat
purposeReviewIndex = 2

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
