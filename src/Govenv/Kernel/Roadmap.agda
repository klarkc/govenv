{-# OPTIONS --safe #-}

module Govenv.Kernel.Roadmap where

open import Agda.Builtin.List
open import Agda.Builtin.String using (String)

data ItemState : Set where
  done todo : ItemState

data PhaseState : Set where
  finished active future : PhaseState

record Item (PhaseId : Set) (ItemId : PhaseId → Set) (owner : PhaseId) : Set where
  constructor item
  field
    itemId : ItemId owner
    itemTitle : String
    itemState : ItemState

record Phase (PhaseId : Set) (ItemId : PhaseId → Set) (state : PhaseState) : Set where
  constructor phase
  field
    phaseId : PhaseId
    phaseTitle : String
    phaseItems : List (Item PhaseId ItemId phaseId)

data Roadmap (PhaseId : Set) (ItemId : PhaseId → Set) : Set where
  progressing :
    List (Phase PhaseId ItemId finished) →
    Phase PhaseId ItemId active →
    List (Phase PhaseId ItemId future) →
    Roadmap PhaseId ItemId
  complete :
    List (Phase PhaseId ItemId finished) →
    Roadmap PhaseId ItemId

record Forest (A : Set) : Set where
  constructor forest
  field
    nodes : List A

private
  _++_ : {A : Set} → List A → List A → List A
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

  singleton : {A : Set} → A → Forest A
  singleton x = forest (x ∷ [])

FinishedPhase : (PhaseId : Set) → (PhaseId → Set) → Set
FinishedPhase PhaseId ItemId = Phase PhaseId ItemId finished

ActivePhase : (PhaseId : Set) → (PhaseId → Set) → Set
ActivePhase PhaseId ItemId = Phase PhaseId ItemId active

FuturePhase : (PhaseId : Set) → (PhaseId → Set) → Set
FuturePhase PhaseId ItemId = Phase PhaseId ItemId future

FinishedPhases : (PhaseId : Set) → (PhaseId → Set) → Set
FinishedPhases PhaseId ItemId = Forest (FinishedPhase PhaseId ItemId)

FuturePhases : (PhaseId : Set) → (PhaseId → Set) → Set
FuturePhases PhaseId ItemId = Forest (FuturePhase PhaseId ItemId)

infixr 5 _├_
infixr 3 _┬_
infix 7 _✓_ _◇_
infix 6 _■_ _▣_ _□_
infix 4 _◁_

_├_ : {A : Set} → Forest A → Forest A → Forest A
forest xs ├ forest ys = forest (xs ++ ys)

_┬_ : {A B : Set} → (A → B) → A → B
f ┬ x = f x

_✓_ :
  {PhaseId : Set} {ItemId : PhaseId → Set} {owner : PhaseId} →
  ItemId owner → String → Forest (Item PhaseId ItemId owner)
identifier ✓ title = singleton (item identifier title done)

_◇_ :
  {PhaseId : Set} {ItemId : PhaseId → Set} {owner : PhaseId} →
  ItemId owner → String → Forest (Item PhaseId ItemId owner)
identifier ◇ title = singleton (item identifier title todo)

_■_ :
  {PhaseId : Set} {ItemId : PhaseId → Set} →
  (identifier : PhaseId) → String →
  Forest (Item PhaseId ItemId identifier) → FinishedPhases PhaseId ItemId
_■_ identifier title (forest items) = singleton (phase identifier title items)

_▣_ :
  {PhaseId : Set} {ItemId : PhaseId → Set} →
  (identifier : PhaseId) → String →
  Forest (Item PhaseId ItemId identifier) → ActivePhase PhaseId ItemId
_▣_ identifier title (forest items) = phase identifier title items

_□_ :
  {PhaseId : Set} {ItemId : PhaseId → Set} →
  (identifier : PhaseId) → String →
  Forest (Item PhaseId ItemId identifier) → FuturePhases PhaseId ItemId
_□_ identifier title (forest items) = singleton (phase identifier title items)

_◁_ :
  {PhaseId : Set} {ItemId : PhaseId → Set} →
  FinishedPhases PhaseId ItemId →
  ActivePhase PhaseId ItemId →
  FuturePhases PhaseId ItemId →
  Roadmap PhaseId ItemId
forest finishedPhases ◁ currentPhase = λ where
  (forest futurePhases) → progressing finishedPhases currentPhase futurePhases
