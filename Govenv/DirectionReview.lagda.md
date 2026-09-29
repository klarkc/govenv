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
  "Govenv is in P1 with Agda 2.8.0 and ALS v8 exposed through the internal devenv language module. The reuse investigation found viable lint components but no maintained formatter/LSP solution spanning .agda and .lagda.md. A partial stdlib-baseline plus Govenv custom-rule catalog now reports coverage without claiming completeness."
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
nextTarget = governanceTarget (GVR 126) refl

nextSummary : BoundedText 400
nextSummary = boundedText
  "Execute GV126 by composing reusable Agda lint capabilities where they fit and supplying the missing deterministic formatter/LSP adapter in Stage 0. Keep the rule model extensible from the stdlib baseline with Govenv custom rules, while GV127 retains the later complete inventory and 100% mechanically covered applicable-rule target."
  refl

nextClaims : List (NextClaim roadmap)
nextClaims =
  nextClaim (planned nextTarget)
    "GV125 found reusable lint components but no adequate formatter/LSP implementation; GV126 now owns the narrow Stage-0 composition and missing formatting boundary."
  ∷ []

nextGapCoverage : GapCoverage roadmap
nextGapCoverage = gapCoverage
  (addressedNow (planned nextTarget)
    "The long-term purpose includes reproducible tooling; GV126 now turns the reuse decision into a deterministic formatter/linter capability without making style advice constitutional validity.")
  (addressedNow (planned nextTarget)
    "Current state has the Agda/LSP substrate, an explicit ecosystem disposition, and partial style-rule metrics; the immediate gap is integrating reusable lint and the missing formatter/LSP adapter.")

next : Next roadmap
next = nextReview nextSummary nextClaims nextGapCoverage

reviewRationale : String
reviewRationale =
  "GV125 now records the reuse-first investigation: ALS v8 supplies no formatting capability, current lint tools are useful only as components, and no adequate maintained formatter spans the required source forms and LSP boundary. GV127 records the later stdlib-baseline/custom-rule coverage target, so Current advances to GV126 without changing purpose."

review : DirectionReview roadmap purpose
review = directionReview source refl current next reviewRationale 0
```
