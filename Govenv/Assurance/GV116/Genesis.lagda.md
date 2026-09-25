# GV116 constitutional genesis assurance

This assurance closes the generic one-time migration boundary needed before
Govenv can freeze its real pre-history roadmap into append-only constitutional
history. A genesis carries an explicitly revision-bound catalog of typed phases,
human GovernanceId contracts, inherited lifecycle observations, and supersession
lineage.

Inherited cutover state is deliberately not Proposition evidence. It creates no
Obligations and does not claim that legacy completed work already had formal
Statements or proofs. The bootstrap may occur only as the first history event;
afterward the ordinary append-only constitutional events are the only evolution
mechanism.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV116.Genesis where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Maybe using (just)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Product.Base using (_,_)
open import Relation.Nullary using (¬_)
open import Relation.Nullary.Decidable using (from-yes; from-no)
open import Govenv.Kernel.Identifier using
  ( GovernanceId; SomePhaseId; P; GV; GVR; someIdentifier )
open import Govenv.Kernel.Constitution.Genesis
open import Govenv.Kernel.Constitution

notReadyMeansInvalid :
  (h : History) → (entry : HistoryEntry) →
  ¬ EntryReady h entry → ¬ ValidEntry h entry
notReadyMeansInvalid h entry notReady (isReady , evidence) =
  notReady isReady

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

phase0 : SomePhaseId
phase0 = someIdentifier (P 0 "completed legacy phase")

phase1 : SomePhaseId
phase1 = someIdentifier (P 1 "active legacy phase")

item :
  {idx : Nat} {contract : String} →
  GovernanceId idx contract → Nat → GenesisState → GenesisGovernance
item governance phase state =
  genesisGovernance (someIdentifier governance) phase state

cutover : Genesis
cutover =
  constitutionalGenesis
    "authorized-revision"
    (phase0 ∷ phase1 ∷ [])
    (activeAtCutover 1)
    ( item (GV 800 "completed legacy contract") 0 completedAtCutover
    ∷ item (GV 801 "pending legacy contract") 1 pendingAtCutover
    ∷ item
        (GV 802 "superseded legacy contract")
        1
        (supersededAtCutover (GVR 803))
    ∷ item (GV 803 "successor legacy contract") 1 pendingAtCutover
    ∷ [])

history : History
history = ε ▻ bootstrap cutover

validHistory : ValidHistory history
validHistory =
  extend
    empty
    (bootstrap cutover)
    (from-yes (entryReady? ε (bootstrap cutover)) , tt)

cutoverConstitution : Constitution
cutoverConstitution = constitution history validHistory

completedLifecycleIsInherited :
  constitutionLifecycle cutoverConstitution 800 ≡ completed
completedLifecycleIsInherited = refl

pendingLifecycleIsInherited :
  constitutionLifecycle cutoverConstitution 801 ≡ pending
pendingLifecycleIsInherited = refl

supersessionLineageIsInherited :
  constitutionSuccessor cutoverConstitution 802 ≡ just (GVR 803)
supersessionLineageIsInherited = refl

-- Lineage is preserved without fabricating a formal pre-supersession
-- completion for a governance item that has no Proposition subjects.

supersededLifecycleDoesNotInventFormalCompletion :
  constitutionLifecycle cutoverConstitution 802 ≡ pending
supersededLifecycleDoesNotInventFormalCompletion = refl

-- Genesis is a one-shot event.

secondBootstrapRejected :
  ¬ ValidEntry history (bootstrap cutover)
secondBootstrapRejected =
  notReadyMeansInvalid
    history
    (bootstrap cutover)
    (from-no (entryReady? history (bootstrap cutover)))

-- Completed inherited governance cannot silently acquire new formal work.

p900 : Proposition 900
p900 = prop 900

proposalForCompleted : PropositionDeclaration
proposalForCompleted =
  propositionDeclaration (GVR 800) (someProposition p900)

completedCutoverGovernanceCannotReopen :
  ¬ ValidEntry history (propose proposalForCompleted)
completedCutoverGovernanceCannotReopen =
  notReadyMeansInvalid
    history
    (propose proposalForCompleted)
    (from-no (entryReady? history (propose proposalForCompleted)))

-- Pending inherited governance can begin formal life after cutover.

p901 : Proposition 901
p901 = prop 901

proposalForPending : PropositionDeclaration
proposalForPending =
  propositionDeclaration (GVR 801) (someProposition p901)

pendingCutoverGovernanceCanBeFormalized :
  EntryReady history (propose proposalForPending)
pendingCutoverGovernanceCanBeFormalized =
  from-yes (entryReady? history (propose proposalForPending))

-- Superseded inherited governance remains closed even though the cutover did
-- not invent a formal completion for it.

p902 : Proposition 902
p902 = prop 902

proposalForSuperseded : PropositionDeclaration
proposalForSuperseded =
  propositionDeclaration (GVR 802) (someProposition p902)

supersededCutoverGovernanceCannotReopen :
  ¬ ValidEntry history (propose proposalForSuperseded)
supersededCutoverGovernanceCannotReopen =
  notReadyMeansInvalid
    history
    (propose proposalForSuperseded)
    (from-no (entryReady? history (propose proposalForSuperseded)))

-- Bootstrap validation rejects malformed inherited structure before a
-- Constitution can be constructed.

testPhase : SomePhaseId
testPhase = someIdentifier (P 9 "genesis-assurance")

duplicatePhase : SomePhaseId
duplicatePhase = someIdentifier (P 9 "duplicate-phase-index")

duplicatePhaseGenesis : Genesis
duplicatePhaseGenesis =
  constitutionalGenesis
    "duplicate-phase"
    (testPhase ∷ duplicatePhase ∷ [])
    (activeAtCutover 9)
    []

duplicatePhaseGenesisRejected :
  ¬ ValidEntry ε (bootstrap duplicatePhaseGenesis)
duplicatePhaseGenesisRejected =
  notReadyMeansInvalid
    ε
    (bootstrap duplicatePhaseGenesis)
    (from-no (entryReady? ε (bootstrap duplicatePhaseGenesis)))

missingCurrentPhaseGenesis : Genesis
missingCurrentPhaseGenesis =
  constitutionalGenesis
    "missing-current-phase"
    (testPhase ∷ [])
    (activeAtCutover 999)
    []

missingCurrentPhaseGenesisRejected :
  ¬ ValidEntry ε (bootstrap missingCurrentPhaseGenesis)
missingCurrentPhaseGenesisRejected =
  notReadyMeansInvalid
    ε
    (bootstrap missingCurrentPhaseGenesis)
    (from-no (entryReady? ε (bootstrap missingCurrentPhaseGenesis)))

missingOwningPhaseGenesis : Genesis
missingOwningPhaseGenesis =
  constitutionalGenesis
    "missing-owning-phase"
    (testPhase ∷ [])
    (activeAtCutover 9)
    (item (GV 899 "missing owning phase") 999 pendingAtCutover ∷ [])

missingOwningPhaseGenesisRejected :
  ¬ ValidEntry ε (bootstrap missingOwningPhaseGenesis)
missingOwningPhaseGenesisRejected =
  notReadyMeansInvalid
    ε
    (bootstrap missingOwningPhaseGenesis)
    (from-no (entryReady? ε (bootstrap missingOwningPhaseGenesis)))

duplicateGovernanceGenesis : Genesis
duplicateGovernanceGenesis =
  constitutionalGenesis
    "duplicate-governance"
    (testPhase ∷ [])
    (activeAtCutover 9)
    ( item (GV 900 "duplicate") 9 pendingAtCutover
    ∷ item (GV 900 "duplicate") 9 pendingAtCutover
    ∷ [])

duplicateGovernanceGenesisRejected :
  ¬ ValidEntry ε (bootstrap duplicateGovernanceGenesis)
duplicateGovernanceGenesisRejected =
  notReadyMeansInvalid
    ε
    (bootstrap duplicateGovernanceGenesis)
    (from-no (entryReady? ε (bootstrap duplicateGovernanceGenesis)))

missingTargetGenesis : Genesis
missingTargetGenesis =
  constitutionalGenesis
    "missing-target"
    (testPhase ∷ [])
    (activeAtCutover 9)
    (item
      (GV 903 "missing successor")
      9
      (supersededAtCutover (GVR 999))
    ∷ [])

missingTargetGenesisRejected :
  ¬ ValidEntry ε (bootstrap missingTargetGenesis)
missingTargetGenesisRejected =
  notReadyMeansInvalid
    ε
    (bootstrap missingTargetGenesis)
    (from-no (entryReady? ε (bootstrap missingTargetGenesis)))

selfSupersededGenesis : Genesis
selfSupersededGenesis =
  constitutionalGenesis
    "self-supersession"
    (testPhase ∷ [])
    (activeAtCutover 9)
    (item
      (GV 904 "self successor")
      9
      (supersededAtCutover (GVR 904))
    ∷ [])

selfSupersededGenesisRejected :
  ¬ ValidEntry ε (bootstrap selfSupersededGenesis)
selfSupersededGenesisRejected =
  notReadyMeansInvalid
    ε
    (bootstrap selfSupersededGenesis)
    (from-no (entryReady? ε (bootstrap selfSupersededGenesis)))
```
