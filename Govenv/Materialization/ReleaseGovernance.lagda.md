# Release governance materialization

This module owns the semantic governance-impact section projected into a Release Please pull request and its changelog. Release Please owns the surrounding artifacts; Govenv owns only this typed section.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.ReleaseGovernance where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat; zero; suc)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Release
open import Govenv.Materialization

data ImpactKind : Set where
  completedImpact advancedImpact introducedImpact : ImpactKind

record ImpactGroup : Set where
  constructor impactGroup
  field
    kind : ImpactKind
    label : String
    items : List ItemImpact
    count : Nat

record ImpactLine : Set where
  constructor impactLine
  field
    impactValue : ItemImpact
    progressLabel : String

record ReleaseDocument : Set where
  constructor releaseDocument
  field
    heading : String
    phaseLabel : String
    itemsLabel : String
    completedGroup : ImpactGroup
    advancedGroup : ImpactGroup
    introducedGroup : ImpactGroup
    impactLines : List ImpactLine
    phase : PhaseProgress
    noImpactLabel : String
    introducedPhaseLabel : String
    unchangedPhaseLabel : String
    roadmapCompleteLabel : String
    footer : String
    baseRevision : String
    headRevision : String

private
  _++_ : {A : Set} → List A → List A → List A
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

  countItems : List ItemImpact → Nat
  countItems [] = zero
  countItems (item ∷ rest) = suc (countItems rest)

  completedItems : List ItemImpact → List ItemImpact
  completedItems [] = []
  completedItems (item@(impact itemId state completed) ∷ rest) =
    item ∷ completedItems rest
  completedItems (impact itemId state advanced ∷ rest) = completedItems rest
  completedItems (impact itemId state introduced ∷ rest) = completedItems rest

  advancedItems : List ItemImpact → List ItemImpact
  advancedItems [] = []
  advancedItems (impact itemId state completed ∷ rest) = advancedItems rest
  advancedItems (item@(impact itemId state advanced) ∷ rest) =
    item ∷ advancedItems rest
  advancedItems (impact itemId state introduced ∷ rest) = advancedItems rest

  introducedItems : List ItemImpact → List ItemImpact
  introducedItems [] = []
  introducedItems (impact itemId state completed ∷ rest) = introducedItems rest
  introducedItems (impact itemId state advanced ∷ rest) = introducedItems rest
  introducedItems (item@(impact itemId state introduced) ∷ rest) =
    item ∷ introducedItems rest

  group : ImpactKind → String → List ItemImpact → ImpactGroup
  group kind label items = impactGroup kind label items (countItems items)

  labelItems : String → List ItemImpact → List ImpactLine
  labelItems label [] = []
  labelItems label (item ∷ rest) =
    impactLine item label ∷ labelItems label rest

document : String → String → GovernanceDelta → ReleaseDocument
document baseRevision headRevision (governanceDeltaValue impacts phase) =
  releaseDocument
    "Governance impact"
    "Phase"
    "Items"
    (group completedImpact "completed" (completedItems impacts))
    (group advancedImpact "advanced" (advancedItems impacts))
    (group introducedImpact "introduced" (introducedItems impacts))
    ( labelItems "completed" (completedItems impacts) ++
      (labelItems "advanced" (advancedItems impacts) ++
       labelItems "introduced" (introducedItems impacts)) )
    phase
    "no roadmap item impact"
    "phase governance introduced"
    "unchanged"
    "roadmap complete"
    "Derived from typed roadmap state and governed `Refs: GV…` commit metadata. SemVer remains independent."
    baseRevision
    headRevision

pullRequestBody :
  Nat → String → String → GovernanceDelta → Materialization ReleaseDocument
pullRequestBody number baseRevision headRevision delta = materialized
  (githubPullRequestBodySection number releaseGovernanceImpact afterReleasePleaseBody)
  automatic
  repository
  pullRequestBodySectionEquality
  (document baseRevision headRevision delta)

changelog :
  Nat → String → String → GovernanceDelta → Materialization ReleaseDocument
changelog number baseRevision headRevision delta = materialized
  (githubPullRequestFileSection number "CHANGELOG.md" releaseGovernanceImpact afterReleaseHeading)
  automatic
  repository
  pullRequestFileSectionEquality
  (document baseRevision headRevision delta)
```
