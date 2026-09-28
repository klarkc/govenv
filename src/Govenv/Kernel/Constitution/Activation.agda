{-# OPTIONS --safe #-}

module Govenv.Kernel.Constitution.Activation where

open import Agda.Builtin.Equality using (_≡_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Authorization using
  ( AuthorizedRevision
  ; Revision
  ; revisionOf
  )
open import Govenv.Kernel.Constitution using
  ( Constitution
  ; ValidEntry
  ; ValidHistory
  ; constitution
  ; empty
  ; extend
  ; ε
  ; bootstrap
  ; _▻_
  )
open import Govenv.Kernel.Constitution.Genesis using
  (Genesis)
open import Govenv.Kernel.Constitution.Snapshot using
  ( HistorySnapshot
  ; ConstitutionSnapshot
  ; SnapshotPrefixOf
  ; snapshotConstitution
  ; observeSnapshot
  )
open import Govenv.Kernel.Constitution.Release using
  ( ConstitutionalDelta
  ; ConstitutionalDeltaError
  ; validConstitutionalDelta
  ; invalidConstitutionalDelta
  ; snapshotConstitutionalDelta
  )
open import Govenv.Materialization using (Materialization)
open import Govenv.Materialization.ConstitutionSnapshot using
  (materializationFor)
open import Govenv.Materialization.ConstitutionalReleaseGovernance using
  ( ConstitutionalReleaseDocument
  ; pullRequestBody
  ; githubRelease
  )

authorizedRevisionIdentifier : AuthorizedRevision → String
authorizedRevisionIdentifier authorized =
  Revision.identifier (revisionOf authorized)

record ConstitutionalBoundary : Set₁ where
  constructor constitutionalBoundary
  field
    authorization : AuthorizedRevision
    current : Constitution

boundaryRevision : ConstitutionalBoundary → String
boundaryRevision boundary =
  authorizedRevisionIdentifier
    (ConstitutionalBoundary.authorization boundary)

boundarySnapshot : ConstitutionalBoundary → HistorySnapshot
boundarySnapshot boundary =
  snapshotConstitution
    (boundaryRevision boundary)
    (ConstitutionalBoundary.current boundary)

boundaryAuditSnapshot : ConstitutionalBoundary → ConstitutionSnapshot
boundaryAuditSnapshot boundary =
  observeSnapshot (boundarySnapshot boundary)

boundarySnapshotMaterialization :
  ConstitutionalBoundary →
  Materialization ConstitutionSnapshot
boundarySnapshotMaterialization boundary =
  materializationFor (boundaryAuditSnapshot boundary)

BoundaryPrefixOf :
  ConstitutionalBoundary →
  Constitution →
  Set₁
BoundaryPrefixOf boundary current =
  SnapshotPrefixOf (boundarySnapshot boundary) current

record ConstitutionalCutover : Set₁ where
  constructor constitutionalCutover
  field
    authorization : AuthorizedRevision
    genesis : Genesis
    sourceRevisionBound :
      Genesis.sourceRevision genesis ≡
      authorizedRevisionIdentifier authorization
    bootstrapValid :
      ValidEntry ε (bootstrap genesis)

cutoverHistory :
  ConstitutionalCutover →
  Govenv.Kernel.Constitution.History
cutoverHistory cutover =
  ε ▻ bootstrap (ConstitutionalCutover.genesis cutover)

cutoverValidHistory :
  (cutover : ConstitutionalCutover) →
  ValidHistory (cutoverHistory cutover)
cutoverValidHistory cutover =
  extend
    empty
    (bootstrap (ConstitutionalCutover.genesis cutover))
    (ConstitutionalCutover.bootstrapValid cutover)

cutoverConstitution :
  ConstitutionalCutover →
  Constitution
cutoverConstitution cutover =
  constitution
    (cutoverHistory cutover)
    (cutoverValidHistory cutover)

cutoverBoundary :
  ConstitutionalCutover →
  ConstitutionalBoundary
cutoverBoundary cutover =
  constitutionalBoundary
    (ConstitutionalCutover.authorization cutover)
    (cutoverConstitution cutover)

cutoverGenesisRevisionMatchesBoundary :
  (cutover : ConstitutionalCutover) →
  Genesis.sourceRevision (ConstitutionalCutover.genesis cutover) ≡
  boundaryRevision (cutoverBoundary cutover)
cutoverGenesisRevisionMatchesBoundary cutover =
  ConstitutionalCutover.sourceRevisionBound cutover

cutoverSnapshotMaterialization :
  (cutover : ConstitutionalCutover) →
  Materialization ConstitutionSnapshot
cutoverSnapshotMaterialization cutover =
  boundarySnapshotMaterialization (cutoverBoundary cutover)

boundaryDelta :
  (boundary : ConstitutionalBoundary) →
  (current : Constitution) →
  BoundaryPrefixOf boundary current →
  Govenv.Kernel.Constitution.Release.ConstitutionalDeltaResult
boundaryDelta boundary current prefix =
  snapshotConstitutionalDelta
    (boundarySnapshot boundary)
    current
    prefix

data PullRequestReleasePlan : Set where
  pullRequestReleaseReady :
    Materialization ConstitutionalReleaseDocument →
    PullRequestReleasePlan

  pullRequestReleaseRejected :
    ConstitutionalDeltaError →
    PullRequestReleasePlan

data GithubReleasePlan : Set where
  githubReleaseReady :
    Materialization ConstitutionalReleaseDocument →
    GithubReleasePlan

  githubReleaseRejected :
    ConstitutionalDeltaError →
    GithubReleasePlan

pullRequestReleasePlan :
  (boundary : ConstitutionalBoundary) →
  (current : Constitution) →
  BoundaryPrefixOf boundary current →
  Nat →
  String →
  String →
  String →
  PullRequestReleasePlan
pullRequestReleasePlan
  boundary current prefix
  number version baseRevision headRevision
  with boundaryDelta boundary current prefix
... | invalidConstitutionalDelta error =
  pullRequestReleaseRejected error
... | validConstitutionalDelta delta =
  pullRequestReleaseReady
    (pullRequestBody
      number
      version
      baseRevision
      headRevision
      delta)

githubReleasePlan :
  (boundary : ConstitutionalBoundary) →
  (current : Constitution) →
  BoundaryPrefixOf boundary current →
  String →
  String →
  String →
  GithubReleasePlan
githubReleasePlan
  boundary current prefix
  tag baseRevision headRevision
  with boundaryDelta boundary current prefix
... | invalidConstitutionalDelta error =
  githubReleaseRejected error
... | validConstitutionalDelta delta =
  githubReleaseReady
    (githubRelease
      tag
      baseRevision
      headRevision
      delta)
