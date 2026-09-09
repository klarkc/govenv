{-# OPTIONS --safe #-}

module Govenv.Kernel.Roadmap where

open import Agda.Builtin.List
open import Agda.Builtin.String using (String)

data ItemState : Set where
  done todo : ItemState

data PhaseState : Set where
  finished active future : PhaseState

record Item (PhaseId ItemId : Set) (owner : PhaseId) : Set where
  constructor item
  field
    itemId : ItemId
    itemTitle : String
    itemState : ItemState

record Phase (PhaseId ItemId : Set) : Set where
  constructor phase
  field
    phaseId : PhaseId
    phaseTitle : String
    phaseState : PhaseState
    phaseItems : List (Item PhaseId ItemId phaseId)

Roadmap : Set → Set → Set
Roadmap PhaseId ItemId = List (Phase PhaseId ItemId)
