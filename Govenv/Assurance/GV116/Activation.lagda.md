# GV116 constitutional activation-harness assurance

This assurance closes the generic activation path that must exist before Govenv's
real revision-bound genesis is frozen.

The harness never accepts an independently supplied snapshot. A
`ConstitutionalBoundary` is exactly an `AuthorizedRevision` paired with a
typed `Constitution`; its proof-carrying `HistorySnapshot`, audit snapshot v3,
and repository materialization are all derived from that pair.

The first boundary is stricter. A `ConstitutionalCutover` additionally requires:

- the one-time `Genesis`;
- proof that `Genesis.sourceRevision` is exactly the human-authorized revision;
- a valid bootstrap entry at empty history.

Release plans then require a typed `BoundaryPrefixOf` proof from that boundary
to the candidate Constitution. Neither the textual v3 snapshot nor commit
`Refs: GV…` can manufacture this proof or enter release-delta semantics.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV116.Activation where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Maybe using (just)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Product.Base using (_,_)
open import Relation.Nullary.Decidable using (from-yes)
open import Govenv.Authorization
open import Govenv.Kernel.Identifier using
  (SomePhaseId; P; GV; GVR; someIdentifier)
open import Govenv.Kernel.Constitution
open import Govenv.Kernel.Constitution.Genesis
open import Govenv.Kernel.Constitution.Snapshot
open import Govenv.Kernel.Constitution.Release
open import Govenv.Kernel.Constitution.Activation
open import Govenv.Materialization
open import Govenv.Materialization.ConstitutionalReleaseGovernance

reviewerPrincipal : Principal
reviewerPrincipal =
  observedPrincipal "human-reviewer" human

reviewer : HumanPrincipal
reviewer =
  humanPrincipal reviewerPrincipal refl

merge : HumanPullRequestMerge
merge =
  humanPullRequestMerge
    60
    reviewer
    (identifiedRevision "authorized-revision")
    authorizedTarget

authorization : AuthorizedRevision
authorization =
  authorizedRevision merge refl

phase1 : SomePhaseId
phase1 =
  someIdentifier (P 1 "foundation")

genesis : Genesis
genesis =
  constitutionalGenesis
    "authorized-revision"
    (phase1 ∷ [])
    (activeAtCutover 1)
    ( genesisGovernance
        (someIdentifier (GV 1 "legacy pending contract"))
        1
        pendingAtCutover
    ∷ [])

bootstrapEntryValid :
  ValidEntry ε (bootstrap genesis)
bootstrapEntryValid =
  from-yes (entryReady? ε (bootstrap genesis)) , tt

cutover : ConstitutionalCutover
cutover =
  constitutionalCutover
    authorization
    genesis
    refl
    bootstrapEntryValid

cutoverUsesExactAuthorizedRevision :
  boundaryRevision (cutoverBoundary cutover) ≡
  "authorized-revision"
cutoverUsesExactAuthorizedRevision = refl

genesisRevisionIsTheBoundaryRevision :
  Genesis.sourceRevision genesis ≡
  boundaryRevision (cutoverBoundary cutover)
genesisRevisionIsTheBoundaryRevision =
  cutoverGenesisRevisionMatchesBoundary cutover

snapshotRevisionCannotDriftFromBoundary :
  HistorySnapshot.sourceRevision
    (boundarySnapshot (cutoverBoundary cutover)) ≡
  "authorized-revision"
snapshotRevisionCannotDriftFromBoundary = refl

snapshotHistoryIsTheCutoverHistory :
  HistorySnapshot.history
    (boundarySnapshot (cutoverBoundary cutover)) ≡
  cutoverHistory cutover
snapshotHistoryIsTheCutoverHistory = refl

auditSnapshotCurrentComesFromTheSameConstitution :
  ConstitutionSnapshot.currentPhase
    (boundaryAuditSnapshot (cutoverBoundary cutover)) ≡
  just phase1
auditSnapshotCurrentComesFromTheSameConstitution = refl

cutoverActivatesV3AtTheExistingSnapshotPath :
  Materialization.target
    (cutoverSnapshotMaterialization cutover) ≡
  repositoryFile ".govenv/roadmap.snapshot"
cutoverActivatesV3AtTheExistingSnapshotPath = refl

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

p10 : Proposition 10
p10 = prop 10

proposal10 : PropositionDeclaration
proposal10 =
  propositionDeclaration
    (GVR 1)
    (someProposition p10)

hProposed : History
hProposed =
  cutoverHistory cutover ▻ propose proposal10

hProposedValid : ValidHistory hProposed
hProposedValid =
  extend
    (cutoverValidHistory cutover)
    (propose proposal10)
    (from-yes
      (entryReady?
        (cutoverHistory cutover)
        (propose proposal10)) , tt)

e10 : Establishment
e10 = establishment 10

hEstablished : History
hEstablished =
  hProposed ▻ establish e10

hEstablishedValid : ValidHistory hEstablished
hEstablishedValid =
  extend
    hProposedValid
    (establish e10)
    (from-yes
      (entryReady?
        hProposed
        (establish e10)) , tt)

current : Constitution
current =
  constitution hEstablished hEstablishedValid

prefix :
  BoundaryPrefixOf
    (cutoverBoundary cutover)
    current
prefix =
  appendPrefix
    (appendPrefix
      samePrefix
      (propose proposal10))
    (establish e10)

expectedDelta : ConstitutionalDelta
expectedDelta =
  constitutionalDeltaValue
    (propositionEstablished (GVR 1) 10 ∷ [])
    (roadmapCompleted phase1)

boundaryDeltaIsExactlyHistoryDerived :
  boundaryDelta
    (cutoverBoundary cutover)
    current
    prefix ≡
  validConstitutionalDelta expectedDelta
boundaryDeltaIsExactlyHistoryDerived = refl

pullRequestPlanUsesOnlyTheTypedBoundary :
  pullRequestReleasePlan
    (cutoverBoundary cutover)
    current
    prefix
    61
    "1.0.0"
    "aaaaaaa"
    "bbbbbbb" ≡
  pullRequestReleaseReady
    (pullRequestBody
      61
      "1.0.0"
      "aaaaaaa"
      "bbbbbbb"
      expectedDelta)
pullRequestPlanUsesOnlyTheTypedBoundary = refl

githubReleasePlanUsesOnlyTheTypedBoundary :
  githubReleasePlan
    (cutoverBoundary cutover)
    current
    prefix
    "v1.0.0"
    "aaaaaaa"
    "bbbbbbb" ≡
  githubReleaseReady
    (githubRelease
      "v1.0.0"
      "aaaaaaa"
      "bbbbbbb"
      expectedDelta)
githubReleasePlanUsesOnlyTheTypedBoundary = refl
```
