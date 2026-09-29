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
  "Govenv is in P1 with compiler-checked direction, a from-zero learning bootstrap, exact human-evidence capture, candidate learning gate, consolidation closure, and Stage-0 GitHub collaboration. The selected next vertical is Agda developer tooling: internal devenv language/LSP support first, then formatter/linter reuse investigation and implementation."
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
nextTarget = governanceTarget (GVR 124) refl

nextSummary : BoundedText 400
nextSummary = boundedText
  "Complete GV124 by making Agda and its language server a first-class capability of a Govenv-owned internal devenv module, then execute GV125's formatter/linter ecosystem investigation and GV126's selected Stage-0 integration while preserving GV121 as the later external-application destination."
  refl

nextClaims : List (NextClaim roadmap)
nextClaims =
  nextClaim (planned nextTarget)
    "The project is deliberately opening the Agda tooling vertical now; GV124 establishes the missing Stage-0 language/LSP substrate required before formatter/linter reuse or implementation can be evaluated coherently."
  ∷ []

nextGapCoverage : GapCoverage roadmap
nextGapCoverage = gapCoverage
  (addressedNow (planned nextTarget)
    "The long-term purpose includes reproducing the same tooling and runtime anywhere; GV124 starts making the Agda development capability explicit and reproducible without assigning semantic authority to devenv wiring.")
  (addressedNow (planned nextTarget)
    "Current state has Agda only as an explicitly installed package, not as a first-class language/LSP capability; GV124 closes that immediate developer-environment gap before formatter/linter work.")

next : Next roadmap
next = nextReview nextSummary nextClaims nextGapCoverage

reviewRationale : String
reviewRationale =
  "The project direction now deliberately opens an Agda developer-tooling vertical. GV124 adds a Govenv-owned internal devenv language/LSP module, GV125 requires fresh ecosystem reuse investigation, and GV126 supplies the selected Stage-0 formatter/linter capability while keeping GV121 as the later ejection target; this changes execution priority without changing project purpose."

review : DirectionReview roadmap purpose
review = directionReview source refl current next reviewRationale 0
```
