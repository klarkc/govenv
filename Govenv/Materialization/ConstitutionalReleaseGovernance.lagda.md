# Constitutional release-governance materialization

This module defines the external materialization boundary for the event-sourced
GV116 release delta. It intentionally uses the same pull-request and GitHub
Release sections as the legacy release document, so the future adapter cutover
changes governance authority without changing the external placement contract.

The legacy `ReleaseGovernance` materialization remains active until Govenv's real
constitutional genesis and typed release snapshot boundary are frozen.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.ConstitutionalReleaseGovernance where

open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Constitution.Release using (ConstitutionalDelta)
open import Govenv.Materialization

record ConstitutionalReleaseDocument : Set where
  constructor constitutionalReleaseDocument
  field
    heading : String
    phaseLabel : String
    impactsLabel : String
    delta : ConstitutionalDelta
    noImpactLabel : String
    footer : String
    baseRevision : String
    headRevision : String

document :
  String →
  String →
  ConstitutionalDelta →
  ConstitutionalReleaseDocument
document baseRevision headRevision delta =
  constitutionalReleaseDocument
    "Governance impact"
    "Phase"
    "Constitutional events"
    delta
    "no constitutional governance impact"
    "Derived from an exact append-only constitutional history prefix. SemVer remains independent."
    baseRevision
    headRevision

pullRequestBody :
  Nat →
  String →
  String →
  String →
  ConstitutionalDelta →
  Materialization ConstitutionalReleaseDocument
pullRequestBody number releaseVersion baseRevision headRevision delta =
  materialized
    (githubPullRequestBodySection
      number
      releaseGovernanceImpact
      (afterReleaseHeadingInBody releaseVersion))
    automatic
    repository
    authorizedOnly
    pullRequestBodySectionEquality
    (document baseRevision headRevision delta)

githubRelease :
  String →
  String →
  String →
  ConstitutionalDelta →
  Materialization ConstitutionalReleaseDocument
githubRelease tag baseRevision headRevision delta =
  materialized
    (githubReleaseBodySection
      tag
      releaseGovernanceImpactInRelease
      replaceCarriedChangelogSection)
    automatic
    repository
    authorizedOnly
    githubReleaseBodySectionEquality
    (document baseRevision headRevision delta)
```
