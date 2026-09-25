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
open import Agda.Builtin.String using (String)
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
  "Govenv is in P1 with compiler-checked direction, consolidation closure, human-learning continuity, and Stage-0 GitHub collaboration available. Constitutional history remains partial; GV116 is the immediate gap, followed by dependency/environment authority in GV117 and the broader collaboration boundary in GV118."
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
  "Complete GV116 by deriving the remaining roadmap and release lifecycle from append-only constitutional history, then resolve dependency/environment authority in GV117 and close GV118's governed collaboration boundary before broader runtime and journal work."
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

reviewRationale : String
reviewRationale =
  "GV120 and GV121 establish a distinct post-bootstrap phase for language-neutral Govenv applications: Agda remains the reference formalization through self-hosting and distribution, P7 introduces the versioned IR boundary, and Agda formatting/linting is deferred as an external application that prefers ecosystem reuse before bespoke implementation. The complete direction was re-reviewed; this later phase does not displace GV116, GV117, or GV118 from the nearer sequence, so Current and Next remain accurate."

review : DirectionReview roadmap purpose
review = directionReview source refl current next reviewRationale 1
```
