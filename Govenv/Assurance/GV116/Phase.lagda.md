# GV116 constitutional phase-history assurance

This assurance establishes phase identity and Current as constitutional
projections rather than mutable roadmap state. A phase enters history either
explicitly through `declarePhase` or implicitly on the first GovernanceId
declared in that phase. New phase indices are append-only and strictly increasing;
later governance using an existing phase index must preserve its exact human
phase description.

`Current` is not a history event. It is the first phase, in constitutional phase
order, that still owns non-terminal governance. Completing the last open
governance item therefore advances Current automatically; when no phase owns open
work, Current becomes absent. Superseded governance is terminal for this
projection even when its formal proposition lifecycle was deliberately not
fabricated during legacy genesis.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV116.Phase where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Product.Base using (_,_)
open import Relation.Nullary using (¬_)
open import Relation.Nullary.Decidable using (from-yes; from-no)
open import Govenv.Kernel.Identifier using
  ( SomePhaseId; P; GV; GVR; someIdentifier )
open import Govenv.Kernel.Constitution
open import Govenv.Kernel.Constitution.Genesis

notReadyMeansInvalid :
  (h : History) → (entry : HistoryEntry) →
  ¬ EntryReady h entry → ¬ ValidEntry h entry
notReadyMeansInvalid h entry notReady (isReady , evidence) =
  notReady isReady

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

p10 : Proposition 10
p10 = prop 10

p20 : Proposition 20
p20 = prop 20

g1 : GovernanceDeclaration
g1 =
  governanceDeclaration
    (GV 1 "phase-one work")
    (P 1 "foundation")
    (someProposition p10 ∷ [])

phase2 : PhaseDeclaration
phase2 = phaseDeclaration (P 2 "applications")

g2 : GovernanceDeclaration
g2 =
  governanceDeclaration
    (GV 2 "phase-two work")
    (P 2 "applications")
    (someProposition p20 ∷ [])

h1 : History
h1 = ε ▻ declare g1

h1Valid : ValidHistory h1
h1Valid =
  extend
    empty
    (declare g1)
    (from-yes (entryReady? ε (declare g1)) , tt)

phase1IntroducedByGovernance :
  phaseDescriptionAt h1 1 ≡ just "foundation"
phase1IntroducedByGovernance = refl

phase1IsCurrent :
  currentPhase h1 ≡ just 1
phase1IsCurrent = refl

h12 : History
h12 = h1 ▻ declarePhase phase2

h12Valid : ValidHistory h12
h12Valid =
  extend
    h1Valid
    (declarePhase phase2)
    (from-yes (entryReady? h1 (declarePhase phase2)) , tt)

futurePhaseDeclarationDoesNotMoveCurrent :
  currentPhase h12 ≡ just 1
futurePhaseDeclarationDoesNotMoveCurrent = refl

h2 : History
h2 = h12 ▻ declare g2

h2Valid : ValidHistory h2
h2Valid =
  extend
    h12Valid
    (declare g2)
    (from-yes (entryReady? h12 (declare g2)) , tt)

laterPendingWorkDoesNotSkipCurrent :
  currentPhase h2 ≡ just 1
laterPendingWorkDoesNotSkipCurrent = refl

e10 : Establishment
e10 = establishment 10

h1Complete : History
h1Complete = h2 ▻ establish e10

h1CompleteValid : ValidHistory h1Complete
h1CompleteValid =
  extend
    h2Valid
    (establish e10)
    (from-yes (entryReady? h2 (establish e10)) , tt)

currentAdvancesWhenEarlierPhaseCloses :
  currentPhase h1Complete ≡ just 2
currentAdvancesWhenEarlierPhaseCloses = refl

c1Complete : Constitution
c1Complete = constitution h1Complete h1CompleteValid

constitutionProjectsDerivedCurrent :
  constitutionCurrentPhase c1Complete ≡ just 2
constitutionProjectsDerivedCurrent = refl

e20 : Establishment
e20 = establishment 20

hComplete : History
hComplete = h1Complete ▻ establish e20

hCompleteValid : ValidHistory hComplete
hCompleteValid =
  extend
    h1CompleteValid
    (establish e20)
    (from-yes (entryReady? h1Complete (establish e20)) , tt)

noOpenGovernanceMeansNoCurrentPhase :
  currentPhase hComplete ≡ nothing
noOpenGovernanceMeansNoCurrentPhase = refl

-- A phase index may not be redeclared, even with the same human description.

duplicatePhaseRejected :
  ¬ ValidEntry h12 (declarePhase phase2)
duplicatePhaseRejected =
  notReadyMeansInvalid
    h12
    (declarePhase phase2)
    (from-no (entryReady? h12 (declarePhase phase2)))

-- New phase identity is append-only: a lower index cannot be introduced after
-- a higher phase already exists.

phase0 : PhaseDeclaration
phase0 = phaseDeclaration (P 0 "retroactive phase")

backwardPhaseDeclarationRejected :
  ¬ ValidEntry h1 (declarePhase phase0)
backwardPhaseDeclarationRejected =
  notReadyMeansInvalid
    h1
    (declarePhase phase0)
    (from-no (entryReady? h1 (declarePhase phase0)))

-- Governance may reference an existing phase only with the exact declaration
-- identity; the description cannot mutate under the same phase index.

g2MutatedPhase : GovernanceDeclaration
g2MutatedPhase =
  governanceDeclaration
    (GV 3 "wrong phase identity")
    (P 2 "renamed applications")
    []

phaseIdentityMutationRejected :
  ¬ ValidEntry h12 (declare g2MutatedPhase)
phaseIdentityMutationRejected =
  notReadyMeansInvalid
    h12
    (declare g2MutatedPhase)
    (from-no (entryReady? h12 (declare g2MutatedPhase)))

-- Implicit introduction through GovernanceDeclaration obeys the same monotonic
-- phase-order rule.

g0Retroactive : GovernanceDeclaration
g0Retroactive =
  governanceDeclaration
    (GV 4 "retroactive governance")
    (P 0 "retroactive phase")
    []

implicitBackwardPhaseRejected :
  ¬ ValidEntry h1 (declare g0Retroactive)
implicitBackwardPhaseRejected =
  notReadyMeansInvalid
    h1
    (declare g0Retroactive)
    (from-no (entryReady? h1 (declare g0Retroactive)))

-- Genesis phase order is validated too; bootstrap cannot import a phase catalog
-- whose indices go backwards.

genesisPhase2 : SomePhaseId
genesisPhase2 = someIdentifier (P 2 "later")

genesisPhase1 : SomePhaseId
genesisPhase1 = someIdentifier (P 1 "earlier")

unorderedGenesis : Genesis
unorderedGenesis =
  constitutionalGenesis
    "unordered"
    (genesisPhase2 ∷ genesisPhase1 ∷ [])
    (activeAtCutover 2)
    []

unorderedGenesisRejected :
  ¬ ValidEntry ε (bootstrap unorderedGenesis)
unorderedGenesisRejected =
  notReadyMeansInvalid
    ε
    (bootstrap unorderedGenesis)
    (from-no (entryReady? ε (bootstrap unorderedGenesis)))

-- Legacy supersession lineage is terminal for Current even though the migration
-- deliberately does not invent a formal completion for the predecessor.

legacyPhase0 : SomePhaseId
legacyPhase0 = someIdentifier (P 0 "legacy")

legacyPhase1 : SomePhaseId
legacyPhase1 = someIdentifier (P 1 "current")

legacyGenesis : Genesis
legacyGenesis =
  constitutionalGenesis
    "legacy"
    (legacyPhase0 ∷ legacyPhase1 ∷ [])
    (activeAtCutover 1)
    ( genesisGovernance
        (someIdentifier (GV 40 "superseded predecessor"))
        0
        (supersededAtCutover (GVR 41))
    ∷ genesisGovernance
        (someIdentifier (GV 41 "completed successor"))
        0
        completedAtCutover
    ∷ genesisGovernance
        (someIdentifier (GV 42 "current pending work"))
        1
        pendingAtCutover
    ∷ [])

legacyHistory : History
legacyHistory = ε ▻ bootstrap legacyGenesis

legacyHistoryValid : ValidHistory legacyHistory
legacyHistoryValid =
  extend
    empty
    (bootstrap legacyGenesis)
    (from-yes (entryReady? ε (bootstrap legacyGenesis)) , tt)

supersededPredecessorDoesNotHoldEarlierPhaseOpen :
  currentPhase legacyHistory ≡ just 1
supersededPredecessorDoesNotHoldEarlierPhaseOpen = refl
```
