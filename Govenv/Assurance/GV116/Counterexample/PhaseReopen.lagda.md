# GV116 counterexample: completed phase reopening

PR #56 made `Current` a projection of the first phase with non-terminal
governance, but the original declaration rule still allowed a new GovernanceId
to be appended to a phase after all governance previously owned by that phase had
become terminal. That would make a later history project an earlier `Current`
again.

The repair distinguishes a genuinely unused future phase from a phase that has
already owned governance. Existing phases at or after the current frontier remain
writable, and an unused future phase may receive its first GovernanceId after all
earlier work closes; a used terminal phase may not be reopened.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV116.Counterexample.PhaseReopen where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Product.Base using (_,_)
open import Relation.Nullary using (¬_)
open import Relation.Nullary.Decidable using (from-yes; from-no)
open import Govenv.Kernel.Identifier using (P; GV)
open import Govenv.Kernel.Constitution

notReadyMeansInvalid :
  (h : History) → (entry : HistoryEntry) →
  ¬ EntryReady h entry → ¬ ValidEntry h entry
notReadyMeansInvalid h entry notReady (ready , evidence) =
  notReady ready

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

p10 : Proposition 10
p10 = prop 10

g1 : GovernanceDeclaration
g1 =
  governanceDeclaration
    (GV 1 "original phase-one work")
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

hDone : History
hDone = h1 ▻ establish (establishment 10)

hDoneValid : ValidHistory hDone
hDoneValid =
  extend
    h1Valid
    (establish (establishment 10))
    (from-yes (entryReady? h1 (establish (establishment 10))) , tt)

phaseOneClosed :
  currentPhase hDone ≡ nothing
phaseOneClosed = refl

latePhaseOneGovernance : GovernanceDeclaration
latePhaseOneGovernance =
  governanceDeclaration
    (GV 2 "late phase-one work")
    (P 1 "foundation")
    []

completedPhaseCannotReopen :
  ¬ ValidEntry hDone (declare latePhaseOneGovernance)
completedPhaseCannotReopen =
  notReadyMeansInvalid
    hDone
    (declare latePhaseOneGovernance)
    (from-no (entryReady? hDone (declare latePhaseOneGovernance)))

phase2 : PhaseDeclaration
phase2 = phaseDeclaration (P 2 "applications")

hFuture : History
hFuture = hDone ▻ declarePhase phase2

hFutureValid : ValidHistory hFuture
hFutureValid =
  extend
    hDoneValid
    (declarePhase phase2)
    (from-yes (entryReady? hDone (declarePhase phase2)) , tt)

unusedFuturePhaseDoesNotBecomeCurrent :
  currentPhase hFuture ≡ nothing
unusedFuturePhaseDoesNotBecomeCurrent = refl

g2 : GovernanceDeclaration
g2 =
  governanceDeclaration
    (GV 3 "first phase-two work")
    (P 2 "applications")
    []

futurePhaseMayReceiveFirstGovernance :
  EntryReady hFuture (declare g2)
futurePhaseMayReceiveFirstGovernance =
  from-yes (entryReady? hFuture (declare g2))

h2 : History
h2 = hFuture ▻ declare g2

phaseTwoBecomesCurrent :
  currentPhase h2 ≡ just 2
phaseTwoBecomesCurrent = refl
```
