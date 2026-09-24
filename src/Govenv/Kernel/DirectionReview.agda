{-# OPTIONS --safe #-}

module Govenv.Kernel.DirectionReview where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.Nat using (Nat; zero; suc; _<_)
open import Agda.Builtin.String using (String; primStringToList)
open import Govenv.Kernel.Identifier using (GovernanceRef)
open import Govenv.Kernel.Release using (RoadmapSnapshot; snapshotRoadmap)
open import Govenv.Kernel.Roadmap using (Roadmap; lookupGovernanceRef)

private
  length : {A : Set} → List A → Nat
  length [] = zero
  length (_ ∷ xs) = suc (length xs)

record BoundedText (limit : Nat) : Set where
  constructor boundedText
  field
    value : String
    withinLimit : (length (primStringToList value) < suc limit) ≡ true

record DirectionSource : Set where
  constructor directionSource
  field
    sourcePurpose : String
    sourceRoadmap : RoadmapSnapshot

data SourceDisposition : Set where
  represented : String → SourceDisposition
  omittedWithReason : String → SourceDisposition

record CurrentCoverage : Set where
  constructor currentCoverage
  field
    purposeDisposition : SourceDisposition
    roadmapDisposition : SourceDisposition

record Current (source : DirectionSource) : Set where
  constructor currentReview
  field
    summary : BoundedText 400
    coverage : CurrentCoverage

governanceReferenceExists : GovernanceRef → Roadmap → Bool
governanceReferenceExists reference roadmap
  with lookupGovernanceRef reference roadmap
... | just governance = true
... | nothing = false

record GovernanceTarget (roadmap : Roadmap) : Set where
  constructor governanceTarget
  field
    reference : GovernanceRef
    validReference : governanceReferenceExists reference roadmap ≡ true

data NextTarget (roadmap : Roadmap) : Set where
  planned : GovernanceTarget roadmap → NextTarget roadmap
  investigationBeforePlanning : String → NextTarget roadmap

record NextClaim (roadmap : Roadmap) : Set where
  constructor nextClaim
  field
    target : NextTarget roadmap
    rationale : String

data GapDisposition (roadmap : Roadmap) : Set where
  addressedNow : NextTarget roadmap → String → GapDisposition roadmap
  alreadySatisfied : String → GapDisposition roadmap
  representedLater : GovernanceTarget roadmap → String → GapDisposition roadmap
  notCurrentlyRelevant : String → GapDisposition roadmap

record GapCoverage (roadmap : Roadmap) : Set where
  constructor gapCoverage
  field
    purposeGap : GapDisposition roadmap
    currentGap : GapDisposition roadmap

record Next (roadmap : Roadmap) : Set where
  constructor nextReview
  field
    summary : BoundedText 400
    claims : List (NextClaim roadmap)
    coverage : GapCoverage roadmap

record DirectionReview (roadmap : Roadmap) (purpose : String) : Set where
  constructor directionReview
  field
    source : DirectionSource
    sourceExact :
      source ≡ directionSource purpose (snapshotRoadmap roadmap)
    current : Current source
    next : Next roadmap
    reviewIndex : Nat

record DirectionReviewSnapshot : Set where
  constructor directionReviewSnapshot
  field
    snapshotReviewIndex : Nat
    snapshotCurrent : String
    snapshotNext : String

snapshotDirectionReview :
  {roadmap : Roadmap} {purpose : String} →
  DirectionReview roadmap purpose →
  DirectionReviewSnapshot
snapshotDirectionReview review =
  directionReviewSnapshot
    (DirectionReview.reviewIndex review)
    (BoundedText.value (Current.summary (DirectionReview.current review)))
    (BoundedText.value (Next.summary (DirectionReview.next review)))
