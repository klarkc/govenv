{-# OPTIONS --safe #-}

module Govenv.Adapter.DirectionReviewVigilance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([])
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (primStringEquality)
open import Govenv.Adapter.RoadmapEvolutionObservation
open import Govenv.DirectionReview using
  (currentSummary; nextSummary; review)
open import Govenv.Kernel.DirectionReview using
  (BoundedText; DirectionReview)
open import Govenv.Kernel.Protocol using (protocolVigilanceFresh)
open import Govenv.Kernel.Release using
  (governanceDelta; governanceDeltaChanged; validDelta; invalidDelta)
open import Govenv.Project using (purpose)
open import Govenv.Roadmap using (roadmap)

not : Bool → Bool
not true = false
not false = true

_or_ : Bool → Bool → Bool
true or right = true
false or right = right

_and_ : Bool → Bool → Bool
true and right = right
false and right = false

roadmapChanged : Bool
roadmapChanged with governanceDelta previous [] roadmap
... | validDelta delta = governanceDeltaChanged delta
... | invalidDelta error = false

purposeChanged : Bool
purposeChanged = not (primStringEquality previousPurpose purpose)

sourceChanged : Bool
sourceChanged = roadmapChanged or purposeChanged

reviewChanged : Bool
reviewChanged =
  not
    ( primStringEquality
        previousCurrentSummary
        (BoundedText.value currentSummary)
      and
      primStringEquality
        previousNextSummary
        (BoundedText.value nextSummary)
    )

currentReviewIndex : Nat
currentReviewIndex = DirectionReview.reviewIndex review

directionReviewFresh : Bool
directionReviewFresh with previousDirectionReviewAvailable
... | false = true
... | true =
  protocolVigilanceFresh
    sourceChanged
    reviewChanged
    previousDirectionReviewIndex
    currentReviewIndex

directionReviewVigilance : directionReviewFresh ≡ true
directionReviewVigilance = refl
