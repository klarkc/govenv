{-# OPTIONS --safe #-}

module Govenv.Kernel.Release where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; _==_; _<_)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Identifier
open import Govenv.Kernel.Roadmap

data ReleaseKind : Set where
  major minor patch : ReleaseKind

data ItemProgress : Set where
  completed advanced introduced : ItemProgress

data PhaseProgress : Set where
  phaseIntroduced : SomePhaseId → PhaseProgress
  phaseUnchanged : SomePhaseId → PhaseProgress
  phaseAdvanced : SomePhaseId → SomePhaseId → PhaseProgress
  roadmapCompleted : SomePhaseId → PhaseProgress

record ItemImpact : Set where
  constructor impact
  field
    itemId : SomeGovernanceId
    itemState : ItemState
    progress : ItemProgress

record GovernanceDelta : Set where
  constructor governanceDeltaValue
  field
    itemImpacts : List ItemImpact
    phaseProgress : PhaseProgress

data SnapshotPhase : Set where
  snapshotAbsent : SnapshotPhase
  snapshotActive : Nat → SnapshotPhase
  snapshotComplete : Nat → SnapshotPhase

record SnapshotItem : Set where
  constructor snapshotItem
  field
    snapshotItemId : Nat
    snapshotItemState : ItemState

record RoadmapSnapshot : Set where
  constructor roadmapSnapshot
  field
    snapshotPhase : SnapshotPhase
    snapshotItems : List SnapshotItem

record CurrentItem : Set where
  constructor currentItem
  field
    currentItemId : SomeGovernanceId
    currentItemState : ItemState

data GovernanceDeltaError : Set where
  itemRegressed : SomeGovernanceId → GovernanceDeltaError
  governanceRemoved : Nat → GovernanceDeltaError
  phaseRegressed : Nat → SomePhaseId → GovernanceDeltaError
  emptyRoadmap : GovernanceDeltaError

data ItemDecision : Set where
  noImpact : ItemDecision
  includeImpact : ItemImpact → ItemDecision
  rejectItem : GovernanceDeltaError → ItemDecision

data ItemImpactsResult : Set where
  classifiedItems : List ItemImpact → ItemImpactsResult
  rejectedItems : GovernanceDeltaError → ItemImpactsResult

data PhaseProgressResult : Set where
  classifiedPhase : PhaseProgress → PhaseProgressResult
  rejectedPhase : GovernanceDeltaError → PhaseProgressResult

data GovernanceDeltaResult : Set where
  validDelta : GovernanceDelta → GovernanceDeltaResult
  invalidDelta : GovernanceDeltaError → GovernanceDeltaResult

private
  _++_ : {A : Set} → List A → List A → List A
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

  membershipItemList :
    {phaseIdx : Nat} {phaseDescription : String}
    {phase : PhaseId phaseIdx phaseDescription} →
    List (Membership phase) →
    List CurrentItem
  membershipItemList [] = []
  membershipItemList (membership governanceId state relation ∷ rest) =
    currentItem (someIdentifier governanceId) state ∷ membershipItemList rest

  phaseItemList :
    {state : PhaseState} →
    PhaseNode state →
    List CurrentItem
  phaseItemList (phaseNode phaseId items) = membershipItemList items

  phaseItemsList :
    {state : PhaseState} →
    List (PhaseNode state) →
    List CurrentItem
  phaseItemsList [] = []
  phaseItemsList (phase ∷ rest) =
    phaseItemList phase ++ phaseItemsList rest

  currentItems : Roadmap → List CurrentItem
  currentItems (progressing finishedPhases current futurePhases) =
    phaseItemsList finishedPhases ++
    (phaseItemList current ++ phaseItemsList futurePhases)
  currentItems (complete finishedPhases) = phaseItemsList finishedPhases

  itemIndex : CurrentItem → Nat
  itemIndex (currentItem (someIdentifier governanceId) state) =
    indexOf governanceId

  snapshotCurrentItems : List CurrentItem → List SnapshotItem
  snapshotCurrentItems [] = []
  snapshotCurrentItems (item ∷ rest) =
    snapshotItem (itemIndex item) (CurrentItem.currentItemState item) ∷
    snapshotCurrentItems rest

  phaseSomeId :
    {state : PhaseState} →
    PhaseNode state →
    SomePhaseId
  phaseSomeId (phaseNode phaseId items) = someIdentifier phaseId

  lastPhase :
    {state : PhaseState} →
    List (PhaseNode state) →
    Maybe SomePhaseId
  lastPhase [] = nothing
  lastPhase (phase ∷ []) = just (phaseSomeId phase)
  lastPhase (phase ∷ next ∷ rest) = lastPhase (next ∷ rest)

  somePhaseIndex : SomePhaseId → Nat
  somePhaseIndex (someIdentifier phaseId) = indexOf phaseId

  observedPhase : Nat → SomePhaseId
  observedPhase idx = someIdentifier (P idx "")

  snapshotOf : Roadmap → RoadmapSnapshot
  snapshotOf roadmap@(progressing finishedPhases current futurePhases) =
    roadmapSnapshot
      (snapshotActive (somePhaseIndex (phaseSomeId current)))
      (snapshotCurrentItems (currentItems roadmap))
  snapshotOf roadmap@(complete finishedPhases) with lastPhase finishedPhases
  ... | nothing =
    roadmapSnapshot snapshotAbsent (snapshotCurrentItems (currentItems roadmap))
  ... | just phaseId =
    roadmapSnapshot
      (snapshotComplete (somePhaseIndex phaseId))
      (snapshotCurrentItems (currentItems roadmap))

  findPrevious : Nat → List SnapshotItem → Maybe ItemState
  findPrevious idx [] = nothing
  findPrevious idx (snapshotItem candidate state ∷ rest) with idx == candidate
  ... | true = just state
  ... | false = findPrevious idx rest

  referenced : Nat → List Nat → Bool
  referenced idx [] = false
  referenced idx (candidate ∷ rest) with idx == candidate
  ... | true = true
  ... | false = referenced idx rest

  currentContains : Nat → List CurrentItem → Bool
  currentContains idx [] = false
  currentContains idx (item ∷ rest) with idx == itemIndex item
  ... | true = true
  ... | false = currentContains idx rest

  removedItem : List SnapshotItem → List CurrentItem → Maybe Nat
  removedItem [] current = nothing
  removedItem (snapshotItem idx state ∷ rest) current with currentContains idx current
  ... | true = removedItem rest current
  ... | false = just idx

  classifyKnown : CurrentItem → ItemState → List Nat → ItemDecision
  classifyKnown (currentItem governanceId done) done references = noImpact
  classifyKnown (currentItem governanceId todo) done references =
    rejectItem (itemRegressed governanceId)
  classifyKnown (currentItem governanceId done) todo references =
    includeImpact (impact governanceId done completed)
  classifyKnown item@(currentItem governanceId todo) todo references
    with referenced (itemIndex item) references
  ... | true = includeImpact (impact governanceId todo advanced)
  ... | false = noImpact

  classifyAbsent : CurrentItem → List Nat → ItemDecision
  classifyAbsent item@(currentItem governanceId done) references
    with referenced (itemIndex item) references
  ... | true = includeImpact (impact governanceId done completed)
  ... | false = includeImpact (impact governanceId done introduced)
  classifyAbsent item@(currentItem governanceId todo) references
    with referenced (itemIndex item) references
  ... | true = includeImpact (impact governanceId todo advanced)
  ... | false = includeImpact (impact governanceId todo introduced)

  classifyItem :
    CurrentItem → List SnapshotItem → List Nat → ItemDecision
  classifyItem item previous references with findPrevious (itemIndex item) previous
  ... | just previousState = classifyKnown item previousState references
  ... | nothing = classifyAbsent item references

  classifyItems :
    List CurrentItem → List SnapshotItem → List Nat → ItemImpactsResult
  classifyItems [] previous references = classifiedItems []
  classifyItems (item ∷ rest) previous references
    with classifyItem item previous references | classifyItems rest previous references
  ... | rejectItem error | restResult = rejectedItems error
  ... | noImpact | rejectedItems error = rejectedItems error
  ... | noImpact | classifiedItems impacts = classifiedItems impacts
  ... | includeImpact itemImpact | rejectedItems error = rejectedItems error
  ... | includeImpact itemImpact | classifiedItems impacts =
          classifiedItems (itemImpact ∷ impacts)

  activePhaseProgress : Nat → SomePhaseId → PhaseProgressResult
  activePhaseProgress previous current with previous == somePhaseIndex current
  ... | true = classifiedPhase (phaseUnchanged current)
  ... | false with previous < somePhaseIndex current
  ...   | true = classifiedPhase (phaseAdvanced (observedPhase previous) current)
  ...   | false = rejectedPhase (phaseRegressed previous current)

  completedPhaseProgress : Nat → SomePhaseId → PhaseProgressResult
  completedPhaseProgress previous current with previous == somePhaseIndex current
  ... | true = classifiedPhase (phaseUnchanged current)
  ... | false with previous < somePhaseIndex current
  ...   | true = classifiedPhase (phaseAdvanced (observedPhase previous) current)
  ...   | false = rejectedPhase (phaseRegressed previous current)

  completedToActive : Nat → SomePhaseId → PhaseProgressResult
  completedToActive previous current with previous < somePhaseIndex current
  ... | true = classifiedPhase (phaseAdvanced (observedPhase previous) current)
  ... | false = rejectedPhase (phaseRegressed previous current)

  activeToComplete : Nat → SomePhaseId → PhaseProgressResult
  activeToComplete previous last with previous == somePhaseIndex last
  ... | true = classifiedPhase (roadmapCompleted (observedPhase previous))
  ... | false with previous < somePhaseIndex last
  ...   | true = classifiedPhase (roadmapCompleted (observedPhase previous))
  ...   | false = rejectedPhase (phaseRegressed previous last)

  classifyPhase : SnapshotPhase → Roadmap → PhaseProgressResult
  classifyPhase snapshotAbsent (progressing finishedPhases current futures) =
    classifiedPhase (phaseIntroduced (phaseSomeId current))
  classifyPhase (snapshotActive previous) (progressing finishedPhases current futures) =
    activePhaseProgress previous (phaseSomeId current)
  classifyPhase (snapshotComplete previous) (progressing finishedPhases current futures) =
    completedToActive previous (phaseSomeId current)
  classifyPhase previousPhase (complete finishedPhases) with lastPhase finishedPhases
  ... | nothing = rejectedPhase emptyRoadmap
  ... | just last with previousPhase
  ...   | snapshotAbsent = classifiedPhase (phaseIntroduced last)
  ...   | snapshotActive previous = activeToComplete previous last
  ...   | snapshotComplete previous = completedPhaseProgress previous last

snapshotRoadmap : Roadmap → RoadmapSnapshot
snapshotRoadmap = snapshotOf

governanceDelta :
  RoadmapSnapshot →
  List Nat →
  Roadmap →
  GovernanceDeltaResult
governanceDelta previous@(roadmapSnapshot previousPhase previousItems) references current
  with removedItem previousItems (currentItems current)
... | just removed = invalidDelta (governanceRemoved removed)
... | nothing with classifyItems (currentItems current) previousItems references
...   | rejectedItems error = invalidDelta error
...   | classifiedItems impacts with classifyPhase previousPhase current
...     | rejectedPhase error = invalidDelta error
...     | classifiedPhase phase =
          validDelta (governanceDeltaValue impacts phase)
