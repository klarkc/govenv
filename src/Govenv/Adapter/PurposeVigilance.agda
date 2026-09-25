{-# OPTIONS --safe #-}

module Govenv.Adapter.PurposeVigilance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([])
open import Agda.Builtin.String using (primStringEquality)
open import Govenv.Adapter.RoadmapEvolutionObservation
open import Govenv.Kernel.Protocol using (protocolReviewFresh)
open import Govenv.Kernel.Release using
  (governanceDelta; governanceDeltaChanged; validDelta; invalidDelta)
open import Govenv.Project using
  (purpose; purposeReviewRationale; purposeReviewIndex)
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

reviewEvidenceChanged : Bool
reviewEvidenceChanged =
  not
    (primStringEquality
      previousPurposeReviewRationale
      purposeReviewRationale)

purposeReviewFresh : Bool
purposeReviewFresh with previousPurposeAvailable
... | false = true
... | true =
  protocolReviewFresh
    roadmapChanged
    purposeChanged
    reviewEvidenceChanged
    previousPurposeReviewIndex
    purposeReviewIndex

purposeReviewVigilance : purposeReviewFresh ≡ true
purposeReviewVigilance = refl
