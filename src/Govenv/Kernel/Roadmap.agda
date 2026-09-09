{-# OPTIONS --safe #-}

module Govenv.Kernel.Roadmap where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Identifier

data ItemState : Set where
  done todo : ItemState

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
  appendShape : ChainShape → ChainShape → ChainShape
  appendShape finishedOnly finishedOnly = finishedOnly
  appendShape finishedOnly activeAndFuture = progressingShape
  appendShape finishedOnly progressingShape = progressingShape
  appendShape activeAndFuture futureOnly = activeAndFuture
  appendShape futureOnly futureOnly = futureOnly
  appendShape progressingShape futureOnly = progressingShape
  appendShape _ _ = invalidShape

infixr 5 _├_
infixr 4 _┬_
infixr 2 _╟_
infix 8 _✓ _◇
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

RoadmapResult : ChainShape → Set
RoadmapResult finishedOnly = Roadmap
RoadmapResult activeAndFuture = Roadmap
RoadmapResult progressingShape = Roadmap
RoadmapResult futureOnly = RoadmapChain futureOnly
RoadmapResult invalidShape = RoadmapChain invalidShape

roadmapOf : {shape : ChainShape} → RoadmapChain shape → RoadmapResult shape
roadmapOf (finishedChain phases) = complete phases
roadmapOf (activeChain current futures) = progressing [] current futures
roadmapOf (progressingChain phases current futures) = progressing phases current futures
roadmapOf chain@(futureChain _) = chain
roadmapOf invalidChain = invalidChain
