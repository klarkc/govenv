{-# OPTIONS --safe #-}

module Govenv.Adapter.PurposeVigilance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([])
open import Agda.Builtin.String using (primStringEquality)
open import Govenv.Adapter.RoadmapEvolutionObservation
open import Govenv.Kernel.Protocol using (protocolVigilanceFresh)
open import Govenv.Kernel.Release using
  (governanceDelta; governanceDeltaChanged; validDelta; invalidDelta)
open import Govenv.Project using (purpose; purposeReviewIndex)
open import Govenv.Roadmap using (roadmap)

not : Bool → Bool
not true = false
not false = true

roadmapChanged : Bool
roadmapChanged with governanceDelta previous [] roadmap
... | validDelta delta = governanceDeltaChanged delta
... | invalidDelta error = false

purposeChanged : Bool
purposeChanged = not (primStringEquality previousPurpose purpose)

purposeReviewFresh : Bool
purposeReviewFresh with previousPurposeAvailable
... | false = true
... | true =
  protocolVigilanceFresh
    roadmapChanged
    purposeChanged
    previousPurposeReviewIndex
    purposeReviewIndex

purposeReviewVigilance : purposeReviewFresh ≡ true
purposeReviewVigilance = refl
