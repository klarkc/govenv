{-# OPTIONS --safe #-}

module Govenv.Kernel.ConstitutionalHistorySpike.EcosystemReuse where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Data.Nat.Base using (ℕ)
open import Data.Nat.Properties using (_≟_)
open import Data.List.Base using (List; []; _∷_)
open import Data.List.Membership.DecPropositional _≟_
  using (_∈_; _∉_; _∈?_; _∉?_)
open import Data.List.Relation.Unary.All using (all?)
open import Data.List.Relation.Unary.Any using (any?)
open import Data.List.Relation.Unary.Unique.DecPropositional _≟_
  using (Unique; unique?)
open import Relation.Nullary using (Dec; ¬_)
open import Relation.Nullary.Decidable using (does; ¬?)

ids : List ℕ
ids = 1 ∷ 2 ∷ 3 ∷ []

nonZero? : (n : ℕ) → Dec (¬ (n ≡ 0))
nonZero? n = ¬? (n ≟ 0)

two? : (n : ℕ) → Dec (n ≡ 2)
two? n = n ≟ 2

uniqueDecision : does (unique? ids) ≡ true
uniqueDecision = refl

allDecision : does (all? nonZero? ids) ≡ true
allDecision = refl

anyDecision : does (any? two? ids) ≡ true
anyDecision = refl

membershipDecision : does (2 ∈? ids) ≡ true
membershipDecision = refl

nonMembershipDecision : does (4 ∉? ids) ≡ true
nonMembershipDecision = refl
