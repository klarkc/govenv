{-# OPTIONS --safe #-}

module Govenv.Kernel.Constitution.Snapshot where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Data.List.Base using (_++_; map)
open import Govenv.Kernel.Identifier using
  (GovernanceRef; SomeGovernanceId; SomePhaseId; someIdentifier)
open import Govenv.Kernel.Constitution using
  ( History
  ; HistoryEntry
  ; ValidHistory
  ; Constitution
  ; SomeProposition
  ; PhaseDeclaration
  ; GovernanceDeclaration
  ; PropositionDeclaration
  ; Establishment
  ; Disposition
  ; PropositionDisposition
  ; Supersession
  ; bootstrap
  ; declarePhase
  ; declare
  ; propose
  ; establish
  ; abandon
  ; supersede
  ; preserved
  ; abandoned
  ; withdrawn
  ; reformulated
  ; _▻_
  ; currentPhaseIdentity
  )
import Govenv.Kernel.Constitution as Constitutional
open import Govenv.Kernel.Constitution.Genesis using
  ( Genesis
  ; GenesisState
  ; GenesisGovernance
  ; pendingAtCutover
  ; completedAtCutover
  ; abandonedAtCutover
  ; supersededAtCutover
  )

-- A prefix proof states that the left history is preserved byte-for-byte in
-- constitutional order and that the right history differs only by append-only
-- extension. No equality or interpretation of Proposition Statements is needed:
-- the proof is built from the actual typed History spine.

data HistoryPrefix : History → History → Set₁ where
  samePrefix :
    {history : History} →
    HistoryPrefix history history

  appendPrefix :
    {prefix current : History} →
    HistoryPrefix prefix current →
    (entry : HistoryEntry) →
    HistoryPrefix prefix (current ▻ entry)

prefixEntries :
  {prefix current : History} →
  HistoryPrefix prefix current →
  List HistoryEntry
prefixEntries samePrefix = []
prefixEntries (appendPrefix relation entry) =
  prefixEntries relation ++ (entry ∷ [])

prefixTransitive :
  {first second third : History} →
  HistoryPrefix first second →
  HistoryPrefix second third →
  HistoryPrefix first third
prefixTransitive firstToSecond samePrefix = firstToSecond
prefixTransitive firstToSecond (appendPrefix secondToCurrent entry) =
  appendPrefix (prefixTransitive firstToSecond secondToCurrent) entry

record HistorySnapshot : Set₁ where
  constructor historySnapshot
  field
    sourceRevision : String
    history : History
    validHistory : ValidHistory history

snapshotConstitution : String → Constitution → HistorySnapshot
snapshotConstitution revision current =
  historySnapshot
    revision
    (Constitution.history current)
    (Constitution.validHistory current)

SnapshotPrefixOf : HistorySnapshot → Constitution → Set₁
SnapshotPrefixOf snapshot current =
  HistoryPrefix
    (HistorySnapshot.history snapshot)
    (Constitution.history current)

snapshotPrefixOfSelf :
  (snapshot : HistorySnapshot) →
  SnapshotPrefixOf
    snapshot
    (Constitutional.constitution
      (HistorySnapshot.history snapshot)
      (HistorySnapshot.validHistory snapshot))
snapshotPrefixOfSelf snapshot = samePrefix

-- HistorySnapshot is proof-carrying and therefore lives in Set₁. Repository
-- materialization must not serialize or reconstruct those proof terms.
-- ConstitutionSnapshot is the audit-only Set projection that may cross the
-- materialization boundary.

data SnapshotGovernanceState : Set where
  observedPending : SnapshotGovernanceState
  observedCompleted : SnapshotGovernanceState
  observedAbandoned : SnapshotGovernanceState
  observedSuperseded : GovernanceRef → SnapshotGovernanceState

data SnapshotDisposition : Set where
  observedPreserved : SnapshotDisposition
  observedDispositionAbandoned : SnapshotDisposition
  observedWithdrawn : SnapshotDisposition
  observedReformulated : List Nat → SnapshotDisposition

record SnapshotPropositionDisposition : Set where
  constructor snapshotDisposition
  field
    propositionIndex : Nat
    disposition : SnapshotDisposition

data SnapshotEvent : Set where
  bootstrapBoundary :
    String →
    SnapshotEvent

  phaseDeclaredEvent :
    SomePhaseId →
    SnapshotEvent

  genesisGovernanceEvent :
    SomeGovernanceId →
    Nat →
    SnapshotGovernanceState →
    SnapshotEvent

  governanceDeclaredEvent :
    SomeGovernanceId →
    SomePhaseId →
    List Nat →
    SnapshotEvent

  propositionDeclaredEvent :
    GovernanceRef →
    Nat →
    SnapshotEvent

  propositionEstablishedEvent :
    Nat →
    SnapshotEvent

  propositionAbandonedEvent :
    Nat →
    SnapshotEvent

  governanceSupersededEvent :
    GovernanceRef →
    GovernanceRef →
    List Nat →
    List SnapshotPropositionDisposition →
    SnapshotEvent

record ConstitutionSnapshot : Set where
  constructor constitutionSnapshot
  field
    sourceRevision : String
    currentPhase : Maybe SomePhaseId
    events : List SnapshotEvent

private
  propositionIndexOf : SomeProposition → Nat
  propositionIndexOf (Constitutional.someProposition {idx = idx} subject) = idx

  propositionIndices : List SomeProposition → List Nat
  propositionIndices = map propositionIndexOf

  establishmentIndex : Establishment → Nat
  establishmentIndex = Establishment.propositionIndex

  establishmentIndices : List Establishment → List Nat
  establishmentIndices = map establishmentIndex

  observeGenesisState : GenesisState → SnapshotGovernanceState
  observeGenesisState pendingAtCutover = observedPending
  observeGenesisState completedAtCutover = observedCompleted
  observeGenesisState abandonedAtCutover = observedAbandoned
  observeGenesisState (supersededAtCutover successor) =
    observedSuperseded successor

  observeGenesisGovernance :
    GenesisGovernance →
    SnapshotEvent
  observeGenesisGovernance item =
    genesisGovernanceEvent
      (GenesisGovernance.governance item)
      (GenesisGovernance.owningPhase item)
      (observeGenesisState (GenesisGovernance.state item))

  observeGenesisPhases : List SomePhaseId → List SnapshotEvent
  observeGenesisPhases [] = []
  observeGenesisPhases (phase ∷ rest) =
    phaseDeclaredEvent phase ∷ observeGenesisPhases rest

  observeGenesisGovernanceList :
    List GenesisGovernance →
    List SnapshotEvent
  observeGenesisGovernanceList [] = []
  observeGenesisGovernanceList (item ∷ rest) =
    observeGenesisGovernance item ∷ observeGenesisGovernanceList rest

  observeGenesis : Genesis → List SnapshotEvent
  observeGenesis genesis =
    bootstrapBoundary (Genesis.sourceRevision genesis) ∷
    observeGenesisPhases (Genesis.phases genesis) ++
    observeGenesisGovernanceList (Genesis.governance genesis)

  observeDisposition : Disposition → SnapshotDisposition
  observeDisposition preserved = observedPreserved
  observeDisposition abandoned = observedDispositionAbandoned
  observeDisposition withdrawn = observedWithdrawn
  observeDisposition (reformulated targets) =
    observedReformulated targets

  observePropositionDisposition :
    PropositionDisposition →
    SnapshotPropositionDisposition
  observePropositionDisposition item =
    snapshotDisposition
      (PropositionDisposition.propositionIndex item)
      (observeDisposition (PropositionDisposition.disposition item))

  observeDispositions :
    List PropositionDisposition →
    List SnapshotPropositionDisposition
  observeDispositions = map observePropositionDisposition

  observeEntry : HistoryEntry → List SnapshotEvent
  observeEntry (bootstrap genesis) =
    observeGenesis genesis
  observeEntry (declarePhase declaration) =
    phaseDeclaredEvent
      (someIdentifier (PhaseDeclaration.phase declaration)) ∷ []
  observeEntry (declare declaration) =
    governanceDeclaredEvent
      (someIdentifier (GovernanceDeclaration.governance declaration))
      (someIdentifier (GovernanceDeclaration.phase declaration))
      (propositionIndices (GovernanceDeclaration.propositions declaration)) ∷ []
  observeEntry (propose declaration) =
    propositionDeclaredEvent
      (PropositionDeclaration.owner declaration)
      (propositionIndexOf (PropositionDeclaration.subject declaration)) ∷ []
  observeEntry (establish event) =
    propositionEstablishedEvent
      (Establishment.propositionIndex event) ∷ []
  observeEntry (abandon proposition) =
    propositionAbandonedEvent proposition ∷ []
  observeEntry (supersede event) =
    governanceSupersededEvent
      (Supersession.previous event)
      (Supersession.successor event)
      (establishmentIndices (Supersession.establishments event))
      (observeDispositions (Supersession.dispositions event)) ∷ []

observeHistory : History → List SnapshotEvent
observeHistory Constitutional.ε = []
observeHistory (history ▻ entry) =
  observeHistory history ++ observeEntry entry

observeSnapshot : HistorySnapshot → ConstitutionSnapshot
observeSnapshot snapshot =
  constitutionSnapshot
    (HistorySnapshot.sourceRevision snapshot)
    (currentPhaseIdentity (HistorySnapshot.history snapshot))
    (observeHistory (HistorySnapshot.history snapshot))
