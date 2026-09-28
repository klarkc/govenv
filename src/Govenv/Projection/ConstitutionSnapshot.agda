{-# OPTIONS --safe #-}

module Govenv.Projection.ConstitutionSnapshot where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using
  (String; primShowNat; primShowString; primStringAppend)
open import Govenv.Kernel.Identifier using
  ( GovernanceRef; SomeGovernanceId; SomePhaseId
  ; IdentifierRef; indexOf; descriptionOf; someIdentifier
  )
open import Govenv.Kernel.Constitution.Snapshot
open import Govenv.Materialization using (Materialization)
open Materialization

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

private
  renderNatList : List Nat → String
  renderNatList [] = "[]"
  renderNatList (value ∷ rest) =
    "[" ++ primShowNat value ++ renderNatTail rest
    where
    renderNatTail : List Nat → String
    renderNatTail [] = "]"
    renderNatTail (next ∷ values) =
      "," ++ primShowNat next ++ renderNatTail values

  renderGovernanceRef : GovernanceRef → String
  renderGovernanceRef reference =
    primShowNat (IdentifierRef.referenceIndex reference)

  renderGovernanceId : SomeGovernanceId → String
  renderGovernanceId (someIdentifier governance) =
    primShowNat (indexOf governance)

  renderGovernanceDescription : SomeGovernanceId → String
  renderGovernanceDescription (someIdentifier governance) =
    primShowString (descriptionOf governance)

  renderPhaseId : SomePhaseId → String
  renderPhaseId (someIdentifier phase) =
    primShowNat (indexOf phase)

  renderPhaseDescription : SomePhaseId → String
  renderPhaseDescription (someIdentifier phase) =
    primShowString (descriptionOf phase)

  renderCurrent : Maybe SomePhaseId → String
  renderCurrent nothing = "current absent\n"
  renderCurrent (just phase) =
    "current phase " ++ renderPhaseId phase ++
    " " ++ renderPhaseDescription phase ++ "\n"

  renderGenesisState : SnapshotGovernanceState → String
  renderGenesisState observedPending = "pending"
  renderGenesisState observedCompleted = "completed"
  renderGenesisState observedAbandoned = "abandoned"
  renderGenesisState (observedSuperseded successor) =
    "superseded " ++ renderGovernanceRef successor

  renderDispositionValue : SnapshotDisposition → String
  renderDispositionValue observedPreserved = "preserved"
  renderDispositionValue observedDispositionAbandoned = "abandoned"
  renderDispositionValue observedWithdrawn = "withdrawn"
  renderDispositionValue (observedReformulated targets) =
    "reformulated " ++ renderNatList targets

  renderDisposition : SnapshotPropositionDisposition → String
  renderDisposition item =
    primShowNat (SnapshotPropositionDisposition.propositionIndex item) ++
    ":" ++
    renderDispositionValue
      (SnapshotPropositionDisposition.disposition item)

  renderDispositions : List SnapshotPropositionDisposition → String
  renderDispositions [] = "[]"
  renderDispositions (item ∷ rest) =
    "[" ++ renderDisposition item ++ renderDispositionTail rest
    where
    renderDispositionTail :
      List SnapshotPropositionDisposition →
      String
    renderDispositionTail [] = "]"
    renderDispositionTail (next ∷ values) =
      "," ++ renderDisposition next ++ renderDispositionTail values

renderEvent : SnapshotEvent → String
renderEvent (bootstrapBoundary revision) =
  "event bootstrap " ++ primShowString revision ++ "\n"
renderEvent (phaseDeclaredEvent phase) =
  "event phase " ++ renderPhaseId phase ++
  " " ++ renderPhaseDescription phase ++ "\n"
renderEvent (genesisGovernanceEvent governance phase state) =
  "event genesis-governance " ++ renderGovernanceId governance ++
  " phase " ++ primShowNat phase ++
  " " ++ renderGenesisState state ++
  " " ++ renderGovernanceDescription governance ++ "\n"
renderEvent (governanceDeclaredEvent governance phase propositions) =
  "event governance " ++ renderGovernanceId governance ++
  " phase " ++ renderPhaseId phase ++
  " propositions " ++ renderNatList propositions ++
  " " ++ renderGovernanceDescription governance ++ "\n"
renderEvent (propositionDeclaredEvent owner proposition) =
  "event proposition owner " ++ renderGovernanceRef owner ++
  " proposition " ++ primShowNat proposition ++ "\n"
renderEvent (propositionEstablishedEvent proposition) =
  "event establish " ++ primShowNat proposition ++ "\n"
renderEvent (propositionAbandonedEvent proposition) =
  "event abandon " ++ primShowNat proposition ++ "\n"
renderEvent
  (governanceSupersededEvent
    previous successor establishments dispositions) =
  "event supersede " ++ renderGovernanceRef previous ++
  " -> " ++ renderGovernanceRef successor ++
  " establishments " ++ renderNatList establishments ++
  " dispositions " ++ renderDispositions dispositions ++ "\n"

renderEvents : List SnapshotEvent → String
renderEvents [] = ""
renderEvents (event ∷ rest) =
  renderEvent event ++ renderEvents rest

renderConstitutionSnapshot : ConstitutionSnapshot → String
renderConstitutionSnapshot snapshot =
  "govenv-constitution-snapshot-v3\n" ++
  "revision " ++
    primShowString (ConstitutionSnapshot.sourceRevision snapshot) ++ "\n" ++
  renderCurrent (ConstitutionSnapshot.currentPhase snapshot) ++
  renderEvents (ConstitutionSnapshot.events snapshot)

renderSnapshotMaterialization :
  Materialization ConstitutionSnapshot →
  String
renderSnapshotMaterialization materialization =
  renderConstitutionSnapshot (state materialization)
