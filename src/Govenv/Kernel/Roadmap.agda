{-# OPTIONS --safe #-}

module Govenv.Kernel.Roadmap where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat; zero; suc)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Assurance using (AssuranceSpec; assures)
open import Govenv.Kernel.Identifier

data ItemState : Set where
  done todo cancelled : ItemState
  superseded : GovernanceRef → ItemState

data PhaseState : Set where
  finished active future : PhaseState

data BelongsTo
  {gvIdx phaseIdx : Nat}
  {gvDescription phaseDescription : String}
  (governance : GovernanceId gvIdx gvDescription)
  (phase : PhaseId phaseIdx phaseDescription) : Set where
  belongs : BelongsTo governance phase

record GovernanceSpec : Set where
  constructor governanceSpec
  field
    {idx} : Nat
    {description} : String
    governanceId : GovernanceId idx description
    governanceState : ItemState

record Membership
  {phaseIdx : Nat}
  {phaseDescription : String}
  (phase : PhaseId phaseIdx phaseDescription) : Set where
  constructor membership
  field
    {gvIdx} : Nat
    {gvDescription} : String
    governanceId : GovernanceId gvIdx gvDescription
    governanceState : ItemState
    relation : BelongsTo governanceId phase

record PhaseNode (state : PhaseState) : Set where
  constructor phaseNode
  field
    {idx} : Nat
    {description} : String
    phaseId : PhaseId idx description
    phaseItems : List (Membership phaseId)

data Roadmap : Set where
  progressing :
    List (PhaseNode finished) →
    PhaseNode active →
    List (PhaseNode future) →
    Roadmap
  complete :
    List (PhaseNode finished) →
    Roadmap

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

  _and_ : Bool → Bool → Bool
  true and right = right
  false and right = false

  not : Bool → Bool
  not true = false
  not false = true

  equalNat : Nat → Nat → Bool
  equalNat zero zero = true
  equalNat zero (suc right) = false
  equalNat (suc left) zero = false
  equalNat (suc left) (suc right) = equalNat left right

  lessNat : Nat → Nat → Bool
  lessNat zero zero = false
  lessNat zero (suc right) = true
  lessNat (suc left) zero = false
  lessNat (suc left) (suc right) = lessNat left right

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
  uniqueNats (x ∷ xs) = not (containsNat x xs) and uniqueNats xs

  strictlyIncreasing : List Nat → Bool
  strictlyIncreasing [] = true
  strictlyIncreasing (x ∷ []) = true
  strictlyIncreasing (x ∷ y ∷ rest) =
    lessNat x y and strictlyIncreasing (y ∷ rest)

attach :
  {phaseIdx : Nat} {phaseDescription : String} →
  (phase : PhaseId phaseIdx phaseDescription) →
  List GovernanceSpec →
  List (Membership phase)
attach phase [] = []
attach phase (governanceSpec governanceId governanceState ∷ rest) =
  membership governanceId governanceState belongs ∷ attach phase rest

data ChainShape : Set where
  finishedOnly activeAndFuture futureOnly progressingShape invalidShape : ChainShape

data RoadmapChain : ChainShape → Set where
  finishedChain : List (PhaseNode finished) → RoadmapChain finishedOnly
  activeChain : PhaseNode active → List (PhaseNode future) → RoadmapChain activeAndFuture
  futureChain : List (PhaseNode future) → RoadmapChain futureOnly
  progressingChain :
    List (PhaseNode finished) →
    PhaseNode active →
    List (PhaseNode future) →
    RoadmapChain progressingShape
  invalidChain : RoadmapChain invalidShape

private
  membershipIndices :
    {phaseIdx : Nat} {phaseDescription : String}
    {phase : PhaseId phaseIdx phaseDescription} →
    List (Membership phase) → List Nat
  membershipIndices [] = []
  membershipIndices (membership governanceId state relation ∷ rest) =
    indexOf governanceId ∷ membershipIndices rest

  phaseIndex : {state : PhaseState} → PhaseNode state → Nat
  phaseIndex (phaseNode phaseId items) = indexOf phaseId

  phaseIndices : {state : PhaseState} → List (PhaseNode state) → List Nat
  phaseIndices [] = []
  phaseIndices (phase ∷ rest) = phaseIndex phase ∷ phaseIndices rest

  phaseGovernanceIndices :
    {state : PhaseState} → List (PhaseNode state) → List Nat
  phaseGovernanceIndices [] = []
  phaseGovernanceIndices (phaseNode phaseId items ∷ rest) =
    membershipIndices items ++ phaseGovernanceIndices rest

  itemsDone :
    {phaseIdx : Nat} {phaseDescription : String}
    {phase : PhaseId phaseIdx phaseDescription} →
    List (Membership phase) → Bool
  itemsDone [] = true
  itemsDone (membership governanceId done relation ∷ rest) = itemsDone rest
  itemsDone (membership governanceId todo relation ∷ rest) = false
  itemsDone (membership governanceId cancelled relation ∷ rest) = itemsDone rest
  itemsDone (membership governanceId (superseded replacement) relation ∷ rest) =
    itemsDone rest

  finishedPhasesDone : List (PhaseNode finished) → Bool
  finishedPhasesDone [] = true
  finishedPhasesDone (phaseNode phaseId items ∷ rest) =
    itemsDone items and finishedPhasesDone rest

  doneItemsAssured :
    {Legacy : Nat → Set}
    {phaseIdx : Nat} {phaseDescription : String}
    {phase : PhaseId phaseIdx phaseDescription} →
    List (AssuranceSpec Legacy) → List (Membership phase) → Bool
  doneItemsAssured assurances [] = true
  doneItemsAssured assurances
    (membership governanceId done relation ∷ rest) =
      containsAssurance (indexOf governanceId) assurances and
      doneItemsAssured assurances rest
  doneItemsAssured assurances
    (membership governanceId todo relation ∷ rest) =
      doneItemsAssured assurances rest
  doneItemsAssured assurances
    (membership governanceId cancelled relation ∷ rest) =
      doneItemsAssured assurances rest
  doneItemsAssured assurances
    (membership governanceId (superseded replacement) relation ∷ rest) =
      doneItemsAssured assurances rest

  phasesDoneAssured :
    {Legacy : Nat → Set} {state : PhaseState} →
    List (AssuranceSpec Legacy) → List (PhaseNode state) → Bool
  phasesDoneAssured assurances [] = true
  phasesDoneAssured assurances (phaseNode phaseId items ∷ rest) =
    doneItemsAssured assurances items and phasesDoneAssured assurances rest

  chainPhaseIndices : {shape : ChainShape} → RoadmapChain shape → List Nat
  chainPhaseIndices (finishedChain phases) = phaseIndices phases
  chainPhaseIndices (activeChain current futures) =
    phaseIndex current ∷ phaseIndices futures
  chainPhaseIndices (futureChain futures) = phaseIndices futures
  chainPhaseIndices (progressingChain finishedPhases current futures) =
    phaseIndices finishedPhases ++ (phaseIndex current ∷ phaseIndices futures)
  chainPhaseIndices invalidChain = []

  chainGovernanceIndices :
    {shape : ChainShape} → RoadmapChain shape → List Nat
  chainGovernanceIndices (finishedChain phases) =
    phaseGovernanceIndices phases
  chainGovernanceIndices (activeChain current futures) =
    phaseGovernanceIndices (current ∷ []) ++ phaseGovernanceIndices futures
  chainGovernanceIndices (futureChain futures) =
    phaseGovernanceIndices futures
  chainGovernanceIndices (progressingChain finishedPhases current futures) =
    phaseGovernanceIndices finishedPhases ++
    (phaseGovernanceIndices (current ∷ []) ++
     phaseGovernanceIndices futures)
  chainGovernanceIndices invalidChain = []

  chainFinishedPhasesDone :
    {shape : ChainShape} → RoadmapChain shape → Bool
  chainFinishedPhasesDone (finishedChain phases) = finishedPhasesDone phases
  chainFinishedPhasesDone (activeChain current futures) = true
  chainFinishedPhasesDone (futureChain futures) = true
  chainFinishedPhasesDone (progressingChain finishedPhases current futures) =
    finishedPhasesDone finishedPhases
  chainFinishedPhasesDone invalidChain = false

  chainDoneAssured :
    {Legacy : Nat → Set} {shape : ChainShape} →
    List (AssuranceSpec Legacy) → RoadmapChain shape → Bool
  chainDoneAssured assurances (finishedChain phases) =
    phasesDoneAssured assurances phases
  chainDoneAssured assurances (activeChain current futures) =
    phasesDoneAssured assurances (current ∷ []) and
    phasesDoneAssured assurances futures
  chainDoneAssured assurances (futureChain futures) =
    phasesDoneAssured assurances futures
  chainDoneAssured assurances
    (progressingChain finishedPhases current futures) =
      phasesDoneAssured assurances finishedPhases and
      (phasesDoneAssured assurances (current ∷ []) and
       phasesDoneAssured assurances futures)
  chainDoneAssured assurances invalidChain = false

  supersessionsValidItems :
    {phaseIdx : Nat} {phaseDescription : String}
    {phase : PhaseId phaseIdx phaseDescription} →
    List Nat → List (Membership phase) → Bool
  supersessionsValidItems allIndices [] = true
  supersessionsValidItems allIndices
    (membership governanceId done relation ∷ rest) =
      supersessionsValidItems allIndices rest
  supersessionsValidItems allIndices
    (membership governanceId todo relation ∷ rest) =
      supersessionsValidItems allIndices rest
  supersessionsValidItems allIndices
    (membership governanceId cancelled relation ∷ rest) =
      supersessionsValidItems allIndices rest
  supersessionsValidItems allIndices
    (membership governanceId (superseded replacement) relation ∷ rest) =
      (lessNat (indexOf governanceId) (IdentifierRef.referenceIndex replacement) and
       containsNat (IdentifierRef.referenceIndex replacement) allIndices) and
      supersessionsValidItems allIndices rest

  supersessionsValidPhases :
    {state : PhaseState} →
    List Nat → List (PhaseNode state) → Bool
  supersessionsValidPhases allIndices [] = true
  supersessionsValidPhases allIndices (phaseNode phaseId items ∷ rest) =
    supersessionsValidItems allIndices items and
    supersessionsValidPhases allIndices rest

  chainSupersessionsValid :
    {shape : ChainShape} → RoadmapChain shape → Bool
  chainSupersessionsValid chain@(finishedChain phases) =
    supersessionsValidPhases (chainGovernanceIndices chain) phases
  chainSupersessionsValid chain@(activeChain current futures) =
    supersessionsValidPhases (chainGovernanceIndices chain) (current ∷ []) and
    supersessionsValidPhases (chainGovernanceIndices chain) futures
  chainSupersessionsValid chain@(futureChain futures) =
    supersessionsValidPhases (chainGovernanceIndices chain) futures
  chainSupersessionsValid chain@(progressingChain finishedPhases current futures) =
    supersessionsValidPhases (chainGovernanceIndices chain) finishedPhases and
    (supersessionsValidPhases (chainGovernanceIndices chain) (current ∷ []) and
     supersessionsValidPhases (chainGovernanceIndices chain) futures)
  chainSupersessionsValid invalidChain = false

  integrity :
    {Legacy : Nat → Set} {shape : ChainShape} →
    List (AssuranceSpec Legacy) → RoadmapChain shape → Bool
  integrity assurances chain =
    uniqueNats (assuranceIndices assurances) and
    (strictlyIncreasing (chainPhaseIndices chain) and
     (uniqueNats (chainGovernanceIndices chain) and
      (chainFinishedPhasesDone chain and
       (chainSupersessionsValid chain and chainDoneAssured assurances chain))))

  appendShape : ChainShape → ChainShape → ChainShape
  appendShape finishedOnly finishedOnly = finishedOnly
  appendShape finishedOnly activeAndFuture = progressingShape
  appendShape finishedOnly progressingShape = progressingShape
  appendShape activeAndFuture futureOnly = activeAndFuture
  appendShape futureOnly futureOnly = futureOnly
  appendShape progressingShape futureOnly = progressingShape
  appendShape _ _ = invalidShape

completionCoverage :
  {Legacy : Nat → Set} {shape : ChainShape} →
  List (AssuranceSpec Legacy) → RoadmapChain shape → Bool
completionCoverage = chainDoneAssured

infixr 5 _├_
infixr 4 _┬_
infixr 2 _╟_
infix 8 _✓ _◇ _×
infix 8 _↪_
infix 7 _■ _▣ _□

_├_ : {A : Set} → Forest A → Forest A → Forest A
forest xs ├ forest ys = forest (xs ++ ys)

_┬_ : {A B : Set} → (A → B) → A → B
f ┬ x = f x

_╟_ :
  {left right : ChainShape} →
  RoadmapChain left →
  RoadmapChain right →
  RoadmapChain (appendShape left right)
finishedChain xs ╟ finishedChain ys = finishedChain (xs ++ ys)
finishedChain xs ╟ activeChain current futures =
  progressingChain xs current futures
finishedChain xs ╟ progressingChain ys current futures =
  progressingChain (xs ++ ys) current futures
activeChain current xs ╟ futureChain ys = activeChain current (xs ++ ys)
futureChain xs ╟ futureChain ys = futureChain (xs ++ ys)
progressingChain finishedPhases current xs ╟ futureChain ys =
  progressingChain finishedPhases current (xs ++ ys)
finishedChain _ ╟ futureChain _ = invalidChain
finishedChain _ ╟ invalidChain = invalidChain
activeChain _ _ ╟ finishedChain _ = invalidChain
activeChain _ _ ╟ activeChain _ _ = invalidChain
activeChain _ _ ╟ progressingChain _ _ _ = invalidChain
activeChain _ _ ╟ invalidChain = invalidChain
futureChain _ ╟ finishedChain _ = invalidChain
futureChain _ ╟ activeChain _ _ = invalidChain
futureChain _ ╟ progressingChain _ _ _ = invalidChain
futureChain _ ╟ invalidChain = invalidChain
progressingChain _ _ _ ╟ finishedChain _ = invalidChain
progressingChain _ _ _ ╟ activeChain _ _ = invalidChain
progressingChain _ _ _ ╟ progressingChain _ _ _ = invalidChain
progressingChain _ _ _ ╟ invalidChain = invalidChain
invalidChain ╟ _ = invalidChain

_✓ :
  {idx : Nat} {description : String} →
  GovernanceId idx description →
  Forest GovernanceSpec
_✓ governanceId = singleton (governanceSpec governanceId done)

_◇ :
  {idx : Nat} {description : String} →
  GovernanceId idx description →
  Forest GovernanceSpec
_◇ governanceId = singleton (governanceSpec governanceId todo)

_× :
  {idx : Nat} {description : String} →
  GovernanceId idx description →
  Forest GovernanceSpec
_× governanceId = singleton (governanceSpec governanceId cancelled)

_↪_ :
  {idx : Nat} {description : String} →
  GovernanceId idx description →
  GovernanceRef →
  Forest GovernanceSpec
governanceId ↪ replacement =
  singleton (governanceSpec governanceId (superseded replacement))

private
  makePhase :
    {idx : Nat} {description : String} →
    (state : PhaseState) →
    PhaseId idx description →
    Forest GovernanceSpec →
    PhaseNode state
  makePhase state phaseId (forest items) =
    phaseNode phaseId (attach phaseId items)

_■ :
  {idx : Nat} {description : String} →
  PhaseId idx description →
  Forest GovernanceSpec →
  RoadmapChain finishedOnly
_■ phaseId items = finishedChain (makePhase finished phaseId items ∷ [])

_▣ :
  {idx : Nat} {description : String} →
  PhaseId idx description →
  Forest GovernanceSpec →
  RoadmapChain activeAndFuture
_▣ phaseId items = activeChain (makePhase active phaseId items) []

_□ :
  {idx : Nat} {description : String} →
  PhaseId idx description →
  Forest GovernanceSpec →
  RoadmapChain futureOnly
_□ phaseId items = futureChain (makePhase future phaseId items ∷ [])

IntegrityResult : Bool → Set
IntegrityResult true = Roadmap
IntegrityResult false = RoadmapChain invalidShape

RoadmapResult :
  {Legacy : Nat → Set} {shape : ChainShape} →
  List (AssuranceSpec Legacy) → RoadmapChain shape → Set
RoadmapResult {shape = finishedOnly} assurances chain =
  IntegrityResult (integrity assurances chain)
RoadmapResult {shape = activeAndFuture} assurances chain =
  IntegrityResult (integrity assurances chain)
RoadmapResult {shape = progressingShape} assurances chain =
  IntegrityResult (integrity assurances chain)
RoadmapResult {shape = futureOnly} assurances chain = RoadmapChain futureOnly
RoadmapResult {shape = invalidShape} assurances chain = RoadmapChain invalidShape

roadmapOf :
  {Legacy : Nat → Set} {shape : ChainShape} →
  (assurances : List (AssuranceSpec Legacy)) →
  (chain : RoadmapChain shape) →
  RoadmapResult assurances chain
roadmapOf assurances chain@(finishedChain phases) with integrity assurances chain
... | true = complete phases
... | false = invalidChain
roadmapOf assurances chain@(activeChain current futures) with integrity assurances chain
... | true = progressing [] current futures
... | false = invalidChain
roadmapOf assurances chain@(progressingChain phases current futures)
  with integrity assurances chain
... | true = progressing phases current futures
... | false = invalidChain
roadmapOf assurances chain@(futureChain _) = chain
roadmapOf assurances invalidChain = invalidChain
