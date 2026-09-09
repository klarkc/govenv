{-# OPTIONS --safe #-}

module Govenv.Kernel.Release where

open import Agda.Builtin.List using (List)
open import Agda.Builtin.Maybe using (Maybe)

data ReleaseKind : Set where
  major minor patch : ReleaseKind

data ItemProgress : Set where
  completed advanced introduced : ItemProgress

record ItemImpact (ItemId : Set) : Set where
  constructor impact
  field
    itemId : ItemId
    progress : ItemProgress

record GovernanceDelta (PhaseId ItemId : Set) : Set where
  field
    itemImpacts : List (ItemImpact ItemId)
    previousPhase : Maybe PhaseId
    currentPhase : Maybe PhaseId
