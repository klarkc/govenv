{-# OPTIONS --safe #-}

module Govenv.Kernel.Constitution.Genesis where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; _==_)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Identifier using
  ( SomeGovernanceId
  ; SomePhaseId
  ; GovernanceRef
  ; IdentifierRef
  ; indexOf
  ; someIdentifier
  )

-- A Genesis is the one-time trust boundary between Govenv's pre-history
-- roadmap model and append-only constitutional history. These states are
-- inherited observations from an explicitly revision-bound cutover; they are
-- not Proposition evidence and create no Obligations.

data GenesisState : Set where
  pendingAtCutover : GenesisState
  completedAtCutover : GenesisState
  abandonedAtCutover : GenesisState
  supersededAtCutover : GovernanceRef → GenesisState

data GenesisPhaseState : Set where
  activeAtCutover : Nat → GenesisPhaseState
  completeAtCutover : Nat → GenesisPhaseState

record GenesisGovernance : Set where
  constructor genesisGovernance
  field
    governance : SomeGovernanceId
    owningPhase : Nat
    state : GenesisState

record Genesis : Set where
  constructor constitutionalGenesis
  field
    sourceRevision : String
    phases : List SomePhaseId
    phaseState : GenesisPhaseState
    governance : List GenesisGovernance

genesisGovernanceIndex : GenesisGovernance → Nat
genesisGovernanceIndex item with GenesisGovernance.governance item
... | someIdentifier governanceId = indexOf governanceId

owningPhaseIndex : GenesisGovernance → Nat
owningPhaseIndex = GenesisGovernance.owningPhase

phaseIndexOf : SomePhaseId → Nat
phaseIndexOf (someIdentifier phaseId) = indexOf phaseId

phaseIndices : Genesis → List Nat
phaseIndices genesis = indices (Genesis.phases genesis)
  where
  indices : List SomePhaseId → List Nat
  indices [] = []
  indices (phase ∷ rest) = phaseIndexOf phase ∷ indices rest

currentPhaseIndex : Genesis → Nat
currentPhaseIndex genesis with Genesis.phaseState genesis
... | activeAtCutover idx = idx
... | completeAtCutover idx = idx

successor : GenesisGovernance → Maybe GovernanceRef
successor item with GenesisGovernance.state item
... | supersededAtCutover target = just target
... | _ = nothing

successorIndex : GenesisGovernance → Maybe Nat
successorIndex item with successor item
... | nothing = nothing
... | just target = just (IdentifierRef.referenceIndex target)

governanceItems : Genesis → List GenesisGovernance
governanceItems = Genesis.governance

governanceIndices : Genesis → List Nat
governanceIndices genesis = indices (governanceItems genesis)
  where
  indices : List GenesisGovernance → List Nat
  indices [] = []
  indices (item ∷ rest) = genesisGovernanceIndex item ∷ indices rest

supersededIndices : Genesis → List Nat
supersededIndices genesis = indices (governanceItems genesis)
  where
  indices : List GenesisGovernance → List Nat
  indices [] = []
  indices (item ∷ rest) with GenesisGovernance.state item
  ... | supersededAtCutover _ = genesisGovernanceIndex item ∷ indices rest
  ... | _ = indices rest

stateFor : Genesis → Nat → Maybe GenesisState
stateFor genesis idx = lookup (governanceItems genesis)
  where
  lookup : List GenesisGovernance → Maybe GenesisState
  lookup [] = nothing
  lookup (item ∷ rest) with idx == genesisGovernanceIndex item
  ... | true = just (GenesisGovernance.state item)
  ... | false = lookup rest

successorFor : Genesis → Nat → Maybe GovernanceRef
successorFor genesis idx with stateFor genesis idx
... | just (supersededAtCutover target) = just target
... | _ = nothing
