# Release governance materialization

This module owns the typed release governance document shared by the canonical portable changelog entry and enriched GitHub pull-request/release projections. Release Please owns surrounding release artifacts; Govenv owns this semantic section and its target-specific materializations.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.ReleaseGovernance where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat; zero; suc)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Release
open import Govenv.Kernel.Roadmap using (Roadmap)
open import Govenv.Materialization

data ImpactKind : Set where
  completedImpact advancedImpact introducedImpact : ImpactKind
  cancelledImpact supersededImpact : ImpactKind

record ImpactGroup : Set where
  constructor impactGroup
  field
    kind : ImpactKind
    label : String
    items : List ItemImpact
    count : Nat

record ReleaseDocument : Set where
  constructor releaseDocument
  field
    heading : String
    phaseLabel : String
    itemsLabel : String
    completedGroup : ImpactGroup
    advancedGroup : ImpactGroup
    introducedGroup : ImpactGroup
    cancelledGroup : ImpactGroup
    supersededGroup : ImpactGroup
    phase : PhaseProgress
    roadmap : Roadmap
    noImpactLabel : String
    introducedPhaseLabel : String
    unchangedPhaseLabel : String
    roadmapCompleteLabel : String
    footer : String
    baseRevision : String
    headRevision : String

private
  countItems : List ItemImpact → Nat
  countItems [] = zero
  countItems (item ∷ rest) = suc (countItems rest)

  completedItems : List ItemImpact → List ItemImpact
  completedItems [] = []
  completedItems (item@(impact itemId state completed) ∷ rest) =
    item ∷ completedItems rest
  completedItems (impact itemId state advanced ∷ rest) = completedItems rest
  completedItems (impact itemId state introduced ∷ rest) = completedItems rest
  completedItems (impact itemId state cancelledProgress ∷ rest) = completedItems rest
  completedItems (impact itemId state (supersededProgress replacement) ∷ rest) =
    completedItems rest

  advancedItems : List ItemImpact → List ItemImpact
  advancedItems [] = []
  advancedItems (impact itemId state completed ∷ rest) = advancedItems rest
  advancedItems (item@(impact itemId state advanced) ∷ rest) =
    item ∷ advancedItems rest
  advancedItems (impact itemId state introduced ∷ rest) = advancedItems rest
  advancedItems (impact itemId state cancelledProgress ∷ rest) = advancedItems rest
  advancedItems (impact itemId state (supersededProgress replacement) ∷ rest) =
    advancedItems rest

  introducedItems : List ItemImpact → List ItemImpact
  introducedItems [] = []
  introducedItems (impact itemId state completed ∷ rest) = introducedItems rest
  introducedItems (impact itemId state advanced ∷ rest) = introducedItems rest
  introducedItems (item@(impact itemId state introduced) ∷ rest) =
    item ∷ introducedItems rest
  introducedItems (impact itemId state cancelledProgress ∷ rest) = introducedItems rest
  introducedItems (impact itemId state (supersededProgress replacement) ∷ rest) =
    introducedItems rest

  cancelledItems : List ItemImpact → List ItemImpact
  cancelledItems [] = []
  cancelledItems (impact itemId state completed ∷ rest) = cancelledItems rest
  cancelledItems (impact itemId state advanced ∷ rest) = cancelledItems rest
  cancelledItems (impact itemId state introduced ∷ rest) = cancelledItems rest
  cancelledItems (item@(impact itemId state cancelledProgress) ∷ rest) =
    item ∷ cancelledItems rest

  cancelledItems (impact itemId state (supersededProgress replacement) ∷ rest) =
    cancelledItems rest

  supersededItems : List ItemImpact → List ItemImpact
  supersededItems [] = []
  supersededItems (impact itemId state completed ∷ rest) = supersededItems rest
  supersededItems (impact itemId state advanced ∷ rest) = supersededItems rest
  supersededItems (impact itemId state introduced ∷ rest) = supersededItems rest
  supersededItems (impact itemId state cancelledProgress ∷ rest) = supersededItems rest
  supersededItems
    (item@(impact itemId state (supersededProgress replacement)) ∷ rest) =
      item ∷ supersededItems rest

  group : ImpactKind → String → List ItemImpact → ImpactGroup
  group kind label items = impactGroup kind label items (countItems items)

document : String → String → Roadmap → GovernanceDelta → ReleaseDocument
document baseRevision headRevision roadmap (governanceDeltaValue impacts phase) =
  releaseDocument
    "Governance impact"
    "Phase"
    "Items"
    (group completedImpact "completed" (completedItems impacts))
    (group advancedImpact "advanced" (advancedItems impacts))
    (group introducedImpact "introduced" (introducedItems impacts))
    (group cancelledImpact "cancelled" (cancelledItems impacts))
    (group supersededImpact "superseded" (supersededItems impacts))
    phase
    roadmap
    "no roadmap item impact"
    "phase governance introduced"
    "unchanged"
    "roadmap complete"
    "Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent."
    baseRevision
    headRevision

pullRequestBody :
  Nat → String → String → Roadmap → GovernanceDelta → Materialization ReleaseDocument
pullRequestBody number baseRevision headRevision roadmap delta = materialized
  (githubPullRequestBodySection number releaseGovernanceImpact afterReleaseHeadingInBody)
  automatic
  repository
  pullRequestBodySectionEquality
  (document baseRevision headRevision roadmap delta)

changelog :
  Nat → String → String → Roadmap → GovernanceDelta → Materialization ReleaseDocument
changelog number baseRevision headRevision roadmap delta = materialized
  (githubPullRequestFileSection number "CHANGELOG.md" releaseGovernanceImpact afterReleaseHeading)
  automatic
  repository
  pullRequestFileSectionEquality
  (document baseRevision headRevision roadmap delta)

githubRelease :
  String → String → String → Roadmap → GovernanceDelta → Materialization ReleaseDocument
githubRelease tag baseRevision headRevision roadmap delta = materialized
  (githubReleaseBodySection tag releaseGovernanceImpactInRelease)
  automatic
  repository
  githubReleaseBodySectionEquality
  (document baseRevision headRevision roadmap delta)
```
