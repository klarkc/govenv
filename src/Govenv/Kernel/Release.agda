{-# OPTIONS --safe #-}

module Govenv.Kernel.Release where

open import Agda.Builtin.List using (List)
open import Agda.Builtin.Maybe using (Maybe)

data ReleaseKind : Set where
  major minor patch : ReleaseKind

data ItemProgress : Set where
  completed advanced introduced : ItemProgress

record ItemImpact (PhaseId : Set) (ItemId : PhaseId → Set) : Set where
  constructor impact
  field
    phaseId : PhaseId
    itemId : ItemId phaseId
    progress : ItemProgress

record GovernanceDelta (PhaseId : Set) (ItemId : PhaseId → Set) : Set where
  field
    itemImpacts : List (ItemImpact PhaseId ItemId)
    previousPhase : Maybe PhaseId
    currentPhase : Maybe PhaseId
