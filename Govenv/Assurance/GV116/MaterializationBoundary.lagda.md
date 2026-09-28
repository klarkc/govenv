# GV116 constitutional materialization-boundary assurance

This assurance closes the projection boundary needed before the real project
cutover can switch repository and release adapters.

A `HistorySnapshot` carries `ValidHistory` and therefore lives in `Set₁`.
It is never the materialized state. `observeSnapshot` erases that proof-carrying
boundary into `ConstitutionSnapshot : Set`, retaining only stable audit
observations: source revision, derived Current, immutable phase/GovernanceId
identity, proposition identifiers, lifecycle observations imported by genesis,
and explicit constitutional transitions.

The v3 materialization keeps the existing `.govenv/roadmap.snapshot` path so
there is one release boundary rather than parallel v2/v3 authorities. The
constitutional release renderer likewise keeps the existing governance-impact
markers and external target placement while changing the semantic payload to
`ConstitutionalDelta`.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV116.MaterializationBoundary where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Maybe using (just)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Product.Base using (_,_)
open import Relation.Nullary.Decidable using (from-yes)
open import Govenv.Kernel.Identifier using (P; GV; GVR; someIdentifier)
open import Govenv.Kernel.Constitution
open import Govenv.Kernel.Constitution.Snapshot
open import Govenv.Kernel.Constitution.Release
open import Govenv.Materialization
open import Govenv.Materialization.ConstitutionSnapshot
open import Govenv.Materialization.ConstitutionalReleaseGovernance
open import Govenv.Projection.ConstitutionSnapshot
open import Govenv.Projection.ConstitutionalReleaseGovernance

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

p10 : Proposition 10
p10 = prop 10

g1 : GovernanceDeclaration
g1 =
  governanceDeclaration
    (GV 1 "audit contract")
    (P 1 "foundation")
    (someProposition p10 ∷ [])

h1 : History
h1 = ε ▻ declare g1

h1Valid : ValidHistory h1
h1Valid =
  extend
    empty
    (declare g1)
    (from-yes (entryReady? ε (declare g1)) , tt)

c1 : Constitution
c1 = constitution h1 h1Valid

proofCarryingSnapshot : HistorySnapshot
proofCarryingSnapshot =
  snapshotConstitution "abc123" c1

auditSnapshot : ConstitutionSnapshot
auditSnapshot =
  observeSnapshot proofCarryingSnapshot

observationErasesProofBoundaryExactly :
  auditSnapshot ≡
  constitutionSnapshot
    "abc123"
    (just (someIdentifier (P 1 "foundation")))
    ( governanceDeclaredEvent
        (someIdentifier (GV 1 "audit contract"))
        (someIdentifier (P 1 "foundation"))
        (10 ∷ [])
    ∷ [] )
observationErasesProofBoundaryExactly = refl

snapshotV3BytesAreStable :
  renderConstitutionSnapshot auditSnapshot ≡
  "govenv-constitution-snapshot-v3\nrevision \"abc123\"\ncurrent phase 1 \"foundation\"\nevent governance 1 phase 1 propositions [10] \"audit contract\"\n"
snapshotV3BytesAreStable = refl

snapshotV3KeepsTheExistingRepositoryBoundary :
  Materialization.target (materializationFor auditSnapshot) ≡
  repositoryFile ".govenv/roadmap.snapshot"
snapshotV3KeepsTheExistingRepositoryBoundary = refl

delta : ConstitutionalDelta
delta =
  constitutionalDeltaValue
    ( governanceIntroduced
        (someIdentifier (GV 2 "new contract"))
        (someIdentifier (P 2 "applications"))
    ∷ propositionEstablished (GVR 2) 20
    ∷ [] )
    (currentAdvanced
      (someIdentifier (P 1 "foundation"))
      (someIdentifier (P 2 "applications")))

releaseDocument : ConstitutionalReleaseDocument
releaseDocument =
  document "aaaaaaa" "bbbbbbb" delta

constitutionalReleaseBytesAreStable :
  renderPortableSection releaseDocument ≡
  "<!-- govenv-governance-impact:start -->\n### Governance impact\n\n**Phase:** ■ P1 → ▣ P2  \n**Constitutional events:** 2 constitutional event impact(s)\n\n- **+ GV2** @ P2 — new contract\n- **GV2** · Prop20 established\n<sub>Derived from an exact append-only constitutional history prefix. SemVer remains independent. `aaaaaaa..bbbbbbb`.</sub>\n<!-- govenv-governance-impact:end -->\n"
constitutionalReleaseBytesAreStable = refl

constitutionalPullRequestKeepsExternalPlacement :
  Materialization.target
    (pullRequestBody
      58
      "1.0.0"
      "aaaaaaa"
      "bbbbbbb"
      delta) ≡
  githubPullRequestBodySection
    58
    releaseGovernanceImpact
    (afterReleaseHeadingInBody "1.0.0")
constitutionalPullRequestKeepsExternalPlacement = refl

sameMarkersAsLegacyBoundary :
  startMarker ≡ "<!-- govenv-governance-impact:start -->\n"
sameMarkersAsLegacyBoundary = refl
```
