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
  "Govenv is in P1 with authorization-aware stacked-candidate learning. Agda 2.8.0 and matching ALS v8 are now a first-class internal devenv language capability with an observed assurance boundary. The Agda tooling vertical advances to formatter/linter reuse investigation before any bespoke implementation."
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
nextTarget = governanceTarget (GVR 127) refl

nextSummary : BoundedText 400
nextSummary = boundedText
  "Execute GV127's fresh Agda formatter/linter ecosystem investigation against the now-working Agda/ALS environment, then use GV128 to integrate an adequate reusable implementation or the narrowest temporary in-repository fallback behind the same LSP-facing boundary."
  refl

nextClaims : List (NextClaim roadmap)
nextClaims =
  nextClaim (planned nextTarget)
    "GV126 closes the missing Stage-0 Agda/LSP substrate; GV127 is now the explicit reuse-first decision point before any project-specific formatter/linter implementation."
  ∷ []

nextGapCoverage : GapCoverage roadmap
nextGapCoverage = gapCoverage
  (addressedNow (planned nextTarget)
    "The long-term purpose includes reproducible developer tooling; with the language/LSP substrate established, GV127 now tests ecosystem reuse before Govenv owns additional Agda tooling implementation.")
  (addressedNow (planned nextTarget)
    "Current state exposes Agda 2.8.0 and ALS v8 through the internal devenv language module; the remaining immediate gap is selecting the formatter/linter implementation boundary from fresh evidence.")

next : Next roadmap
next = nextReview nextSummary nextClaims nextGapCoverage

reviewRationale : String
reviewRationale =
  "GV126 is now established by a Govenv-owned internal devenv language module, a pinned Agda-2.8.0-compatible ALS v8 package, executable version checks, and observed assurance. Current therefore advances to the reuse-first GV127 investigation while the candidate remains composition state rather than authorized evidence."

review : DirectionReview roadmap purpose
review = directionReview source refl current next reviewRationale 0
```
