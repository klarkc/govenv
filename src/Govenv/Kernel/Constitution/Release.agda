{-# OPTIONS --safe #-}

module Govenv.Kernel.Constitution.Release where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; _==_)
open import Data.List.Base using (_++_; map)
open import Govenv.Kernel.Identifier using
  ( GovernanceRef; SomeGovernanceId; SomePhaseId
  ; IdentifierRef; indexOf; someIdentifier
  )
open import Govenv.Kernel.Constitution using
  ( History; HistoryEntry; Constitution; PhaseDeclaration; GovernanceDeclaration
  ; PropositionDeclaration; Establishment; PropositionDisposition; Supersession
  ; bootstrap; declarePhase; declare; propose; establish; abandon; supersede
  ; currentPhaseIdentity; phaseIdentity; responsibleGovernance
  )
open import Govenv.Kernel.Constitution.Snapshot using
  ( HistoryPrefix; HistorySnapshot; SnapshotPrefixOf
  ; samePrefix; appendPrefix )

data ConstitutionalImpact : Set where
  phaseIdentityIntroduced :
    SomePhaseId →
    ConstitutionalImpact

  governanceIntroduced :
    SomeGovernanceId →
    SomePhaseId →
    ConstitutionalImpact

  propositionEstablished :
    GovernanceRef →
    Nat →
    ConstitutionalImpact

  propositionAbandoned :
    GovernanceRef →
    Nat →
    ConstitutionalImpact

  governanceSuperseded :
    GovernanceRef →
    GovernanceRef →
    List Nat →
    List PropositionDisposition →
    ConstitutionalImpact

data ConstitutionalPhaseProgress : Set where
  currentUnchanged :
    Maybe SomePhaseId →
    ConstitutionalPhaseProgress

  currentIntroduced :
    SomePhaseId →
    ConstitutionalPhaseProgress

  currentAdvanced :
    SomePhaseId →
    SomePhaseId →
    ConstitutionalPhaseProgress

  roadmapCompleted :
    SomePhaseId →
    ConstitutionalPhaseProgress

record ConstitutionalDelta : Set where
  constructor constitutionalDeltaValue
  field
    impacts : List ConstitutionalImpact
    phaseProgress : ConstitutionalPhaseProgress

data ConstitutionalDeltaError : Set where
  missingResponsibleGovernance :
    Nat →
    ConstitutionalDeltaError

data ConstitutionalImpactsResult : Set where
  classifiedImpacts :
    List ConstitutionalImpact →
    ConstitutionalImpactsResult

  rejectedImpacts :
    ConstitutionalDeltaError →
    ConstitutionalImpactsResult

data ConstitutionalDeltaResult : Set where
  validConstitutionalDelta :
    ConstitutionalDelta →
    ConstitutionalDeltaResult

  invalidConstitutionalDelta :
    ConstitutionalDeltaError →
    ConstitutionalDeltaResult

private
  phaseIndex : SomePhaseId → Nat
  phaseIndex (someIdentifier phase) = indexOf phase

  establishmentIndex : Establishment → Nat
  establishmentIndex = Establishment.propositionIndex

  establishmentIndices : List Establishment → List Nat
  establishmentIndices = map establishmentIndex

  governanceIntroduction :
    History →
    GovernanceDeclaration →
    List ConstitutionalImpact
  governanceIntroduction history declaration
    with phaseIdentity
      history
      (indexOf (GovernanceDeclaration.phase declaration))
  ... | nothing =
    phaseIdentityIntroduced
      (someIdentifier (GovernanceDeclaration.phase declaration)) ∷
    governanceIntroduced
      (someIdentifier (GovernanceDeclaration.governance declaration))
      (someIdentifier (GovernanceDeclaration.phase declaration)) ∷
    []
  ... | just phase =
    governanceIntroduced
      (someIdentifier (GovernanceDeclaration.governance declaration))
      phase ∷
    []

  classifyEntry :
    History →
    HistoryEntry →
    ConstitutionalImpactsResult
  classifyEntry history (bootstrap genesis) =
    classifiedImpacts []
  classifyEntry history (declarePhase declaration) =
    classifiedImpacts
      (phaseIdentityIntroduced
        (someIdentifier (PhaseDeclaration.phase declaration)) ∷ [])
  classifyEntry history (declare declaration) =
    classifiedImpacts (governanceIntroduction history declaration)
  classifyEntry history (propose declaration) =
    classifiedImpacts []
  classifyEntry history (establish event) with
    responsibleGovernance history (Establishment.propositionIndex event)
  ... | nothing =
    rejectedImpacts
      (missingResponsibleGovernance
        (Establishment.propositionIndex event))
  ... | just governance =
    classifiedImpacts
      (propositionEstablished
        governance
        (Establishment.propositionIndex event) ∷ [])
  classifyEntry history (abandon proposition) with
    responsibleGovernance history proposition
  ... | nothing =
    rejectedImpacts (missingResponsibleGovernance proposition)
  ... | just governance =
    classifiedImpacts
      (propositionAbandoned governance proposition ∷ [])
  classifyEntry history (supersede event) =
    classifiedImpacts
      (governanceSuperseded
        (Supersession.previous event)
        (Supersession.successor event)
        (establishmentIndices (Supersession.establishments event))
        (Supersession.dispositions event) ∷ [])

constitutionalImpacts :
  {prefix current : History} →
  HistoryPrefix prefix current →
  ConstitutionalImpactsResult
constitutionalImpacts samePrefix =
  classifiedImpacts []
constitutionalImpacts
  (appendPrefix {current = prior} relation entry)
  with constitutionalImpacts relation | classifyEntry prior entry
... | rejectedImpacts error | _ =
  rejectedImpacts error
... | classifiedImpacts priorImpacts | rejectedImpacts error =
  rejectedImpacts error
... | classifiedImpacts priorImpacts | classifiedImpacts currentImpacts =
  classifiedImpacts (priorImpacts ++ currentImpacts)

private
  classifyPhaseProgress :
    History →
    History →
    ConstitutionalPhaseProgress
  classifyPhaseProgress prefix current
    with currentPhaseIdentity prefix | currentPhaseIdentity current
  ... | nothing | nothing =
    currentUnchanged nothing
  ... | nothing | just currentPhase =
    currentIntroduced currentPhase
  ... | just previousPhase | nothing =
    roadmapCompleted previousPhase
  ... | just previousPhase | just currentPhase
    with phaseIndex previousPhase == phaseIndex currentPhase
  ...   | true =
    currentUnchanged (just currentPhase)
  ...   | false =
    currentAdvanced previousPhase currentPhase

constitutionalDelta :
  {prefix current : History} →
  HistoryPrefix prefix current →
  ConstitutionalDeltaResult
constitutionalDelta {prefix} {current} relation
  with constitutionalImpacts relation
... | rejectedImpacts error =
  invalidConstitutionalDelta error
... | classifiedImpacts impacts =
  validConstitutionalDelta
    (constitutionalDeltaValue
      impacts
      (classifyPhaseProgress prefix current))

snapshotConstitutionalDelta :
  (snapshot : HistorySnapshot) →
  (current : Constitution) →
  SnapshotPrefixOf snapshot current →
  ConstitutionalDeltaResult
snapshotConstitutionalDelta snapshot current relation =
  constitutionalDelta relation

constitutionalDeltaChanged :
  ConstitutionalDelta →
  Bool
constitutionalDeltaChanged
  (constitutionalDeltaValue [] (currentUnchanged phase)) = false
constitutionalDeltaChanged delta = true
