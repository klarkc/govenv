{-# OPTIONS --safe #-}

module Govenv.Kernel.Assurance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Govenv.Kernel.Rule using (Rule)

record StaticEvidence (idx : Nat) : Set₁ where
  constructor staticEvidence
  field
    Proposition : Set
    proof : Proposition

record ObservedEvidence (idx : Nat) : Set₁ where
  constructor observedEvidence
  field
    Subject : Set
    Observation : Subject → Set
    dependencies : List Subject
    Diagnostic : Set
    Obligation : Set
    rule : Rule Subject Observation dependencies Diagnostic Obligation

data CompletionAssurance
  (Legacy : Nat → Set)
  (idx : Nat) : Set₁ where
  inherited : Legacy idx → CompletionAssurance Legacy idx
  statically : StaticEvidence idx → CompletionAssurance Legacy idx
  checked : ObservedEvidence idx → CompletionAssurance Legacy idx

record AssuranceSpec (Legacy : Nat → Set) : Set₁ where
  constructor assures
  field
    {idx} : Nat
    assurance : CompletionAssurance Legacy idx

migrationComplete :
  {Legacy : Nat → Set} → List (AssuranceSpec Legacy) → Bool
migrationComplete [] = true
migrationComplete (assures (inherited legacy) ∷ rest) = false
migrationComplete (assures (statically evidence) ∷ rest) =
  migrationComplete rest
migrationComplete (assures (checked evidence) ∷ rest) =
  migrationComplete rest
