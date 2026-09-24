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
open import Govenv.Kernel.Roadmap using (GovernanceTarget; governanceTarget)
open import Govenv.Project using (purpose)
open import Govenv.Roadmap using (roadmap)

source : DirectionSource
source =
  directionSource purpose (snapshotRoadmap roadmap)

currentSummary : BoundedText 400
currentSummary = boundedText
  "Govenv is in P1 with compiler-checked project direction and consolidation closure established. The declared observations extracted from the 2026-09-23 recovery corpus are fully dispositioned; remaining gaps are explicit roadmap work led by constitutional-history migration and dependency/environment authority classification."
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
nextTarget = governanceTarget (GVR 116) refl

nextSummary : BoundedText 400
nextSummary = boundedText
  "Migrate roadmap and release governance to append-only constitutional history in GV116, then resolve dependency/environment authority in GV117 before resuming broader agent/runtime and social-publishing work."
  refl

nextClaims : List (NextClaim roadmap)
nextClaims =
  nextClaim (planned nextTarget)
    "The recovery corpus is closed; its largest unresolved architectural gap is the history-first constitutional model tracked by GV116."
  ∷ []

nextGapCoverage : GapCoverage roadmap
nextGapCoverage = gapCoverage
  (addressedNow (planned nextTarget)
    "The long-term purpose now has a closed recovery context; GV116 addresses the most fundamental remaining semantic-model gap.")
  (addressedNow (planned nextTarget)
    "Current state records the recovery corpus as fully dispositioned and identifies constitutional-history migration as the next blocking gap.")

next : Next roadmap
next = nextReview nextSummary nextClaims nextGapCoverage

review : DirectionReview roadmap purpose
review = directionReview source refl current next zero
```
