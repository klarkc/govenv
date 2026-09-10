{-# OPTIONS --safe #-}

module Govenv.Kernel.Assurance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat; zero; suc)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Fact using (Facts)
open import Govenv.Kernel.Identifier using (PhaseId; indexOf)
open import Govenv.Kernel.Roadmap using
  ( Roadmap; progressing; complete; PhaseState; PhaseNode; phaseNode
  ; Membership; membership; done; todo; cancelled; superseded )
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using (holds)

record StaticEvidence (idx : Nat) : Set₁ where
  constructor staticEvidence
  field
    Proposition : Set
    proof : Proposition

record ObservedEvidence (idx : Nat) : Set₁ where
  constructor observedEvidence
  field
    Subject : Set
    Observation : Subject → Set
    dependencies : List Subject
    Diagnostic : Set
    Obligation : Set
    rule : Rule Subject Observation dependencies Diagnostic Obligation

record ObservedWitness {idx : Nat} (evidence : ObservedEvidence idx) : Set₁ where
  open ObservedEvidence evidence
  field
    facts : Facts Subject Observation dependencies
    established : Rule.check rule facts ≡ holds

data CompletionAssurance
  (Legacy : Nat → Set)
  (idx : Nat) : Set₁ where
  inherited : Legacy idx → CompletionAssurance Legacy idx
  statically : StaticEvidence idx → CompletionAssurance Legacy idx
  checked : ObservedEvidence idx → CompletionAssurance Legacy idx

data CandidateEvidence
  {Legacy : Nat → Set} {idx : Nat} :
  CompletionAssurance Legacy idx → Set₁ where
  staticEstablished :
    {evidence : StaticEvidence idx} →
    CandidateEvidence (statically evidence)
  checkedEstablished :
    {evidence : ObservedEvidence idx} →
    ObservedWitness evidence →
    CandidateEvidence (checked evidence)

record AssuranceSpec (Legacy : Nat → Set) : Set₁ where
  constructor assures
  field
    {idx} : Nat
    assurance : CompletionAssurance Legacy idx

migrationComplete :
  {Legacy : Nat → Set} → List (AssuranceSpec Legacy) → Bool
migrationComplete [] = true
migrationComplete (assures (inherited legacy) ∷ rest) = false
migrationComplete (assures (statically evidence) ∷ rest) =
  migrationComplete rest
migrationComplete (assures (checked evidence) ∷ rest) =
  migrationComplete rest

private
  _and_ : Bool → Bool → Bool
  true and right = right
  false and right = false

  equalNat : Nat → Nat → Bool
  equalNat zero zero = true
  equalNat zero (suc right) = false
  equalNat (suc left) zero = false
  equalNat (suc left) (suc right) = equalNat left right

  containsNat : Nat → List Nat → Bool
  containsNat value [] = false
  containsNat value (x ∷ xs) with equalNat value x
  ... | true = true
  ... | false = containsNat value xs

  assuranceIndex :
    {Legacy : Nat → Set} → AssuranceSpec Legacy → Nat
  assuranceIndex (assures {idx} assurance) = idx

  assuranceIndices :
    {Legacy : Nat → Set} → List (AssuranceSpec Legacy) → List Nat
  assuranceIndices [] = []
  assuranceIndices (assurance ∷ rest) =
    assuranceIndex assurance ∷ assuranceIndices rest

  containsAssurance :
    {Legacy : Nat → Set} → Nat → List (AssuranceSpec Legacy) → Bool
  containsAssurance idx assurances = containsNat idx (assuranceIndices assurances)

  uniqueNats : List Nat → Bool
  uniqueNats [] = true
  uniqueNats (x ∷ xs) = notContains x xs and uniqueNats xs
    where
    notContains : Nat → List Nat → Bool
    notContains value values with containsNat value values
    ... | true = false
    ... | false = true

  doneItemsCovered :
    {Legacy : Nat → Set}
    {phaseIdx : Nat} {phaseDescription : String}
    {phase : PhaseId phaseIdx phaseDescription} →
    List (AssuranceSpec Legacy) → List (Membership phase) → Bool
  doneItemsCovered assurances [] = true
  doneItemsCovered assurances (membership governanceId done relation ∷ rest) =
    containsAssurance (indexOf governanceId) assurances and
    doneItemsCovered assurances rest
  doneItemsCovered assurances (membership governanceId todo relation ∷ rest) =
    doneItemsCovered assurances rest
  doneItemsCovered assurances (membership governanceId cancelled relation ∷ rest) =
    doneItemsCovered assurances rest
  doneItemsCovered assurances
    (membership governanceId (superseded replacement) relation ∷ rest) =
      doneItemsCovered assurances rest

  phaseCovered :
    {Legacy : Nat → Set} {state : PhaseState} →
    List (AssuranceSpec Legacy) → PhaseNode state → Bool
  phaseCovered assurances (phaseNode phaseId items) =
    doneItemsCovered assurances items

  phasesCovered :
    {Legacy : Nat → Set} {state : PhaseState} →
    List (AssuranceSpec Legacy) → List (PhaseNode state) → Bool
  phasesCovered assurances [] = true
  phasesCovered assurances (phase ∷ rest) =
    phaseCovered assurances phase and phasesCovered assurances rest

  roadmapCovered :
    {Legacy : Nat → Set} → List (AssuranceSpec Legacy) → Roadmap → Bool
  roadmapCovered assurances (progressing finishedPhases current futurePhases) =
    phasesCovered assurances finishedPhases and
    (phaseCovered assurances current and phasesCovered assurances futurePhases)
  roadmapCovered assurances (complete finishedPhases) =
    phasesCovered assurances finishedPhases

completionCoverage :
  {Legacy : Nat → Set} → List (AssuranceSpec Legacy) → Roadmap → Bool
completionCoverage assurances roadmap =
  uniqueNats (assuranceIndices assurances) and roadmapCovered assurances roadmap
