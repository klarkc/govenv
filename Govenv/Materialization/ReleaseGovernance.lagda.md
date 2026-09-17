# Release governance materialization

This module owns the typed release governance document and the canonical changelog state. `CHANGELOG.md` is a whole-file materialization owned by Govenv: on an ordinary authorized revision its governed `Unreleased` state is derived from the latest published release boundary to the causal semantic revision and contains both the typed governance delta and the conventional release notes for non-derived commits in that same interval. Derived materialization commits resolve through single-parent Git edges until the first non-derived causal revision and never become release-note content, so provenance survives rebase rewriting without making the changelog self-referential. On a Release Please candidate that exact `Unreleased` payload is frozen beneath an empty `Unreleased` heading under the candidate SemVer; only candidate metadata such as version, heading, and freeze boundary may be added. The freeze records its published-base tag and full authorizing revision, so the exact approved candidate remains reconstructible during the interval after human merge and before tag publication; once the tag exists, the same frozen entry becomes immutable release history. Release Please remains the observer for SemVer and may independently analyze Conventional Commits, but its rendered notes are verification input rather than changelog authority. Historical release entries are observed only from immutable revision-addressable release boundaries and are carried as reconstruction inputs, never trusted from the surviving mutable changelog.

The pull-request and GitHub Release projections share the same typed release entry. A frozen candidate is not ready for human authorization until its exact final head has passed the authoritative repository check under candidate-safe, read-only execution; the privileged Release job may author and read back the candidate but must not execute candidate repository state. `ReleaseGovernance/placement-counterexample.md` preserves the PR #3 placement regression, `ReleaseGovernance/history-preservation-counterexample.md` preserves the observed loss of the 0.2.0 governance history, `ReleaseGovernance/push-auth-counterexample.md` preserves the Stage B release-branch mutation regression from run #35, `ReleaseGovernance/rebase-provenance-counterexample.md` preserves the stale-SHA materialization regression from run #39, `ReleaseGovernance/candidate-validation-counterexample.md` preserves the missing post-mutation candidate check observed on PR #15 after run #43, and `ReleaseGovernance/unreleased-notes-counterexample.md` preserves the 0.2.3 regression where `c41881f` was inside the governed range but absent from the materialized `Unreleased` notes, and `ReleaseGovernance/published-verification-counterexample.md` preserves the 0.2.4 read-back projection mismatch and the cross-run boundary-trust gap it exposed. Candidate validation must reject recurrence before human approval may establish release authority.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.ReleaseGovernance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; zero; suc; _==_)
open import Agda.Builtin.String using (String; primStringAppend; primStringEquality)
open import Govenv.Kernel.Identifier using
  ( GovernanceRef; PhaseId; SomeGovernanceId; SomePhaseId
  ; descriptionOf; indexOf; someIdentifier )
open import Govenv.Kernel.Release
open import Govenv.Kernel.Roadmap using
  ( Membership; PhaseNode; PhaseState; Roadmap
  ; complete; membership; phaseNode; progressing; lookupGovernanceRef )
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

record PhaseChange : Set where
  constructor phaseChange
  field
    previousPhase : SomePhaseId
    currentPhase : SomePhaseId

record PropositionChange : Set where
  constructor propositionChange
  field
    previousProposition : String
    currentProposition : String

data SupersessionDelta : Set where
  resolvedSupersession :
    SomeGovernanceId →
    SomeGovernanceId →
    Maybe PhaseChange →
    Maybe PropositionChange →
    SupersessionDelta
  unresolvedSupersession :
    SomeGovernanceId → GovernanceRef → SupersessionDelta

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
    supersessions : List SupersessionDelta
    phase : PhaseProgress
    noImpactLabel : String
    introducedPhaseLabel : String
    unchangedPhaseLabel : String
    roadmapCompleteLabel : String
    footer : String
    baseRevision : String
    headRevision : String

data ReleaseNoteKind : Set where
  featureNote fixNote governanceNote documentationNote refactorNote : ReleaseNoteKind
  performanceNote testNote buildNote ciNote choreNote : ReleaseNoteKind

record ConventionalCommitObservation : Set where
  constructor conventionalCommit
  field
    commitType : String
    commitScope : String
    commitDescription : String
    commitRevision : String
    commitDerived : Bool

record ReleaseNote : Set where
  constructor releaseNote
  field
    noteKind : ReleaseNoteKind
    noteScope : String
    noteDescription : String
    noteRevision : String
    noteRevisionUrl : String

record ReleaseNoteGroup : Set where
  constructor releaseNoteGroup
  field
    noteGroupLabel : String
    noteGroupItems : List ReleaseNote

record ReleaseEntry : Set where
  constructor releaseEntry
  field
    entryDocument : ReleaseDocument
    entryNoteGroups : List ReleaseNoteGroup

private
  _++_ : String → String → String
  _++_ = primStringAppend

  releaseNoteKindIndex : ReleaseNoteKind → Nat
  releaseNoteKindIndex featureNote = 0
  releaseNoteKindIndex fixNote = 1
  releaseNoteKindIndex governanceNote = 2
  releaseNoteKindIndex documentationNote = 3
  releaseNoteKindIndex refactorNote = 4
  releaseNoteKindIndex performanceNote = 5
  releaseNoteKindIndex testNote = 6
  releaseNoteKindIndex buildNote = 7
  releaseNoteKindIndex ciNote = 8
  releaseNoteKindIndex choreNote = 9

  notesOfKind : ReleaseNoteKind → List ReleaseNote → List ReleaseNote
  notesOfKind kind [] = []
  notesOfKind kind (note ∷ rest)
    with releaseNoteKindIndex kind == releaseNoteKindIndex (ReleaseNote.noteKind note)
  ... | true = note ∷ notesOfKind kind rest
  ... | false = notesOfKind kind rest

  matchReleaseNoteKind :
    String → String → ReleaseNoteKind → Maybe ReleaseNoteKind → Maybe ReleaseNoteKind
  matchReleaseNoteKind observed expected kind fallback
    with primStringEquality observed expected
  ... | true = just kind
  ... | false = fallback

  classifyReleaseNoteKind : String → Maybe ReleaseNoteKind
  classifyReleaseNoteKind value =
    matchReleaseNoteKind value "feat" featureNote
    (matchReleaseNoteKind value "fix" fixNote
    (matchReleaseNoteKind value "gov" governanceNote
    (matchReleaseNoteKind value "docs" documentationNote
    (matchReleaseNoteKind value "refactor" refactorNote
    (matchReleaseNoteKind value "perf" performanceNote
    (matchReleaseNoteKind value "test" testNote
    (matchReleaseNoteKind value "build" buildNote
    (matchReleaseNoteKind value "ci" ciNote
    (matchReleaseNoteKind value "chore" choreNote nothing)))))))))

  semanticReleaseNotes : List ConventionalCommitObservation → List ReleaseNote
  semanticReleaseNotes [] = []
  semanticReleaseNotes (commit ∷ rest)
    with ConventionalCommitObservation.commitDerived commit
       | classifyReleaseNoteKind (ConventionalCommitObservation.commitType commit)
  ... | true | _ = semanticReleaseNotes rest
  ... | false | nothing = semanticReleaseNotes rest
  ... | false | just kind =
    releaseNote
      kind
      (ConventionalCommitObservation.commitScope commit)
      (ConventionalCommitObservation.commitDescription commit)
      (ConventionalCommitObservation.commitRevision commit)
      ("https://github.com/klarkc/govenv/commit/" ++ ConventionalCommitObservation.commitRevision commit) ∷
    semanticReleaseNotes rest

releaseNotes : List ConventionalCommitObservation → List ReleaseNoteGroup
releaseNotes observations =
  releaseNoteGroup "Features" (notesOfKind featureNote notes) ∷
  releaseNoteGroup "Bug Fixes" (notesOfKind fixNote notes) ∷
  releaseNoteGroup "Governance" (notesOfKind governanceNote notes) ∷
  releaseNoteGroup "Documentation" (notesOfKind documentationNote notes) ∷
  releaseNoteGroup "Code Refactoring" (notesOfKind refactorNote notes) ∷
  releaseNoteGroup "Performance" (notesOfKind performanceNote notes) ∷
  releaseNoteGroup "Tests" (notesOfKind testNote notes) ∷
  releaseNoteGroup "Build System" (notesOfKind buildNote notes) ∷
  releaseNoteGroup "Continuous Integration" (notesOfKind ciNote notes) ∷
  releaseNoteGroup "Miscellaneous" (notesOfKind choreNote notes) ∷ []
  where
  notes : List ReleaseNote
  notes = semanticReleaseNotes observations

record CandidateBoundary : Set where
  constructor candidateBoundary
  field
    candidateVersion : String
    candidateHeading : String
    candidateBaseRef : String
    candidateAuthorizedRevision : String

data ChangelogCurrent : Set where
  emptyUnreleased : ChangelogCurrent
  unreleased : ReleaseEntry → ChangelogCurrent
  frozenCandidate : CandidateBoundary → ReleaseEntry → ChangelogCurrent

record ChangelogDocument : Set where
  constructor changelogDocument
  field
    current : ChangelogCurrent
    historicalEntries : List String

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

  lookupMembershipPhase :
    {phaseIdx : Nat} {phaseDescription : String} →
    (phase : PhaseId phaseIdx phaseDescription) →
    Nat → List (Membership phase) → Maybe SomePhaseId
  lookupMembershipPhase phase idx [] = nothing
  lookupMembershipPhase phase idx
    (membership governanceId state relation ∷ rest)
    with idx == indexOf governanceId
  ... | true = just (someIdentifier phase)
  ... | false = lookupMembershipPhase phase idx rest

  lookupPhaseOwner :
    {state : PhaseState} → Nat → PhaseNode state → Maybe SomePhaseId
  lookupPhaseOwner idx (phaseNode phaseId items) =
    lookupMembershipPhase phaseId idx items

  lookupPhaseOwners :
    {state : PhaseState} → Nat → List (PhaseNode state) → Maybe SomePhaseId
  lookupPhaseOwners idx [] = nothing
  lookupPhaseOwners idx (phase ∷ rest) with lookupPhaseOwner idx phase
  ... | just phaseId = just phaseId
  ... | nothing = lookupPhaseOwners idx rest

  lookupGovernancePhase : Nat → Roadmap → Maybe SomePhaseId
  lookupGovernancePhase idx (progressing finished current futures)
    with lookupPhaseOwners idx finished
  ... | just phaseId = just phaseId
  ... | nothing with lookupPhaseOwner idx current
  ...   | just phaseId = just phaseId
  ...   | nothing = lookupPhaseOwners idx futures
  lookupGovernancePhase idx (complete finished) =
    lookupPhaseOwners idx finished

  governanceIndex : SomeGovernanceId → Nat
  governanceIndex (someIdentifier governanceId) = indexOf governanceId

  governanceDescription : SomeGovernanceId → String
  governanceDescription (someIdentifier governanceId) = descriptionOf governanceId

  samePhase : SomePhaseId → SomePhaseId → Bool
  samePhase (someIdentifier previous) (someIdentifier current) =
    indexOf previous == indexOf current

  phaseChangeBetween : SomePhaseId → SomePhaseId → Maybe PhaseChange
  phaseChangeBetween previous current with samePhase previous current
  ... | true = nothing
  ... | false = just (phaseChange previous current)

  phaseChangeFor :
    Roadmap → SomeGovernanceId → SomeGovernanceId → Maybe PhaseChange
  phaseChangeFor roadmap previous current
    with lookupGovernancePhase (governanceIndex previous) roadmap
       | lookupGovernancePhase (governanceIndex current) roadmap
  ... | just previousOwner | just currentOwner =
    phaseChangeBetween previousOwner currentOwner
  ... | _ | _ = nothing

  propositionChangeFor :
    SomeGovernanceId → SomeGovernanceId → Maybe PropositionChange
  propositionChangeFor previous current
    with primStringEquality
      (governanceDescription previous)
      (governanceDescription current)
  ... | true = nothing
  ... | false = just
      (propositionChange
        (governanceDescription previous)
        (governanceDescription current))

supersessionDeltas : Roadmap → List ItemImpact → List SupersessionDelta
supersessionDeltas roadmap [] = []
supersessionDeltas roadmap
  (impact previous state (supersededProgress replacement) ∷ rest)
  with lookupGovernanceRef replacement roadmap
... | nothing =
  unresolvedSupersession previous replacement ∷ supersessionDeltas roadmap rest
... | just current =
  resolvedSupersession
    previous
    current
    (phaseChangeFor roadmap previous current)
    (propositionChangeFor previous current) ∷
  supersessionDeltas roadmap rest
supersessionDeltas roadmap (impact itemId state progress ∷ rest) =
  supersessionDeltas roadmap rest

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
    (supersessionDeltas roadmap impacts)
    phase
    "no roadmap item impact"
    "phase governance introduced"
    "unchanged"
    "roadmap complete"
    "Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent."
    baseRevision
    headRevision

pullRequestBody :
  Nat → String → String → String → Roadmap → GovernanceDelta → Materialization ReleaseDocument
pullRequestBody number releaseVersion baseRevision headRevision roadmap delta = materialized
  (githubPullRequestBodySection number releaseGovernanceImpact
    (afterReleaseHeadingInBody releaseVersion))
  automatic
  repository
  authorizedOnly
  pullRequestBodySectionEquality
  (document baseRevision headRevision roadmap delta)

changelog : ChangelogCurrent → List String → Materialization ChangelogDocument
changelog current history = materialized
  (repositoryFile "CHANGELOG.md")
  automatic
  repository
  authorizedOnly
  trackedEquality
  (changelogDocument current history)

githubRelease :
  String → String → String → Roadmap → GovernanceDelta → Materialization ReleaseDocument
githubRelease tag baseRevision headRevision roadmap delta = materialized
  (githubReleaseBodySection tag releaseGovernanceImpactInRelease replaceCarriedChangelogSection)
  automatic
  repository
  authorizedOnly
  githubReleaseBodySectionEquality
  (document baseRevision headRevision roadmap delta)
```
