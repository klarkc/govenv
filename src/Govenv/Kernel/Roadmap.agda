{-# OPTIONS --safe #-}

module Govenv.Kernel.Roadmap where

open import Agda.Builtin.List
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)

data ItemState : Set where
  done todo : ItemState

data PhaseState : Set where
  finished active future : PhaseState

record Item (PhaseId : Set) (owner : PhaseId) : Set where
  constructor item
  field
    itemNumber : Nat
    itemTitle : String
    itemState : ItemState

record Phase (PhaseId : Set) : Set where
  constructor phase
  field
    phaseId : PhaseId
    phaseTitle : String
    phaseState : PhaseState
    phaseItems : List (Item PhaseId phaseId)

Roadmap : Set → Set
Roadmap PhaseId = List (Phase PhaseId)
