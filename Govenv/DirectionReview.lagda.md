# Project direction review

The direction review is the governed human-facing bridge from project purpose
and exact roadmap state to the next selected project gap. The compiler proves
bounds, source binding, complete disposition of the authoritative Purpose and
Roadmap sources, and validity of roadmap references. It does not claim that the
natural-language judgment is correct; that judgment remains agent-authored and
human-authorized through the pull request.

```agda
{-# OPTIONS --safe #-}

module Govenv.DirectionReview where

open import Agda.Builtin.Equality using (refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (zero)
open import Govenv.Kernel.DirectionReview
open import Govenv.Kernel.Identifier using (GVR)
open import Govenv.Kernel.Release using (snapshotRoadmap)
open import Govenv.Project using (purpose)
open import Govenv.Roadmap using (roadmap)

source : DirectionSource
source =
  directionSource purpose (snapshotRoadmap roadmap)

currentSummary : BoundedText 400
currentSummary = boundedText
  "Govenv is in P1 with typed governance, materialization and release boundaries, and transient candidate validation established. Project direction is now reviewed as governed semantic state; declared session knowledge still needs consolidation before broader architectural work resumes."
  refl

currentSourceCoverage : CurrentCoverage
currentSourceCoverage = currentCoverage
  (represented
    "Purpose remains the long-term frame; Current describes the repository state from which that purpose is being pursued.")
  (represented
    "The exact typed roadmap snapshot is the authoritative project-state source for Current.")

current : Current source
current = currentReview currentSummary currentSourceCoverage

nextTarget : GovernanceTarget roadmap
nextTarget = governanceTarget (GVR 112) refl

nextSummary : BoundedText 400
nextSummary = boundedText
  "Close GV112 by requiring explicit typed disposition for every declared session, handoff, and recovery-corpus observation before semantic roadmap evolution; then use that closure to reconcile the preserved baseline before resuming broader architecture and social publishing work."
  refl

nextClaims : List (NextClaim roadmap)
nextClaims =
  nextClaim (planned nextTarget)
    "Session consolidation is the immediate missing memory-closure mechanism required before the preserved baseline can be safely reconciled."
  ∷ []

nextGapCoverage : GapCoverage roadmap
nextGapCoverage = gapCoverage
  (addressedNow (planned nextTarget)
    "The long-term purpose requires reliable governed context; GV112 closes the immediate memory gap before additional product expansion.")
  (addressedNow (planned nextTarget)
    "Current state already exposes unconsolidated session knowledge as the next blocking project gap.")

next : Next roadmap
next = nextReview nextSummary nextClaims nextGapCoverage

review : DirectionReview roadmap purpose
review = directionReview source refl current next zero
```
