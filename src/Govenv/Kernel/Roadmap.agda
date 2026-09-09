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

record Phase (PhaseId ItemId : Set) (state : PhaseState) : Set where
  constructor phase
  field
    phaseId : PhaseId
    phaseTitle : String
    phaseItems : List (Item PhaseId ItemId phaseId)

data Roadmap (PhaseId ItemId : Set) : Set where
  progressing :
    List (Phase PhaseId ItemId finished) →
    Phase PhaseId ItemId active →
    List (Phase PhaseId ItemId future) →
    Roadmap PhaseId ItemId
  complete :
    List (Phase PhaseId ItemId finished) →
    Roadmap PhaseId ItemId
