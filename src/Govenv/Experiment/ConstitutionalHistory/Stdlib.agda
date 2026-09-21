{-# OPTIONS --safe #-}

module Govenv.Experiment.ConstitutionalHistory.Stdlib where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Bool.Base using (Bool; true; false; not; _∧_; _∨_)
open import Data.Bool.ListAction using (all; any)
open import Data.Nat.Properties using (_≟_)
open import Data.List.Base using (List; []; _∷_; _++_; map; filterᵇ)
open import Data.List.Membership.DecPropositional _≟_ using (_∈?_; _∉?_)
open import Data.List.Relation.Binary.Subset.DecPropositional _≟_ using (_⊆?_)
open import Data.List.Relation.Unary.Unique.DecPropositional _≟_
  using (unique?)
open import Relation.Nullary.Decidable using (does)

data PropositionId : Nat → Set where
  Prop : (idx : Nat) → PropositionId idx

record Proposition (idx : Nat) : Set₁ where
  constructor proposition
  field
    propositionId : PropositionId idx
    Statement     : Set

record SomeProposition : Set₁ where
  constructor someProposition
  field
    {idx} : Nat
    value : Proposition idx

record Evidence {idx : Nat} (p : Proposition idx) : Set₁ where
  constructor evidence
  field
    proof : Proposition.Statement p
record GovernanceDeclaration : Set₁ where
  constructor governanceDeclaration
  field
    governance   : Nat
    contract     : String
    phase        : Nat
    propositions : List SomeProposition

record Establishment : Set₁ where
  constructor establishment
  field
    {idx}      : Nat
    subject    : Proposition idx
    evidenceOf : Evidence subject

data Disposition : Set where
  preserved abandoned withdrawn : Disposition
  reformulated : List Nat → Disposition

record PropositionDisposition : Set where
  constructor dispositionOf
  field
    propositionIndex : Nat
    disposition       : Disposition

record Supersession : Set₁ where
  constructor supersession
  field
    previous       : Nat
    successor      : Nat
    establishments : List Establishment
    dispositions   : List PropositionDisposition
data HistoryEntry : Set₁ where
  declare   : GovernanceDeclaration → HistoryEntry
  establish : Establishment → HistoryEntry
  abandon   : Nat → HistoryEntry
  supersede : Supersession → HistoryEntry

data History : Set₁ where
  ε   : History
  _▻_ : History → HistoryEntry → History

infixl 5 _▻_

private
  sameNat : Nat → Nat → Bool
  sameNat x y = does (x ≟ y)

  containsNat : Nat → List Nat → Bool
  containsNat n xs = does (n ∈? xs)

  propositionIndexOf : SomeProposition → Nat
  propositionIndexOf (someProposition {idx = idx} _) = idx

  establishmentIndex : Establishment → Nat
  establishmentIndex (establishment {idx = idx} _ _) = idx

  declarationIndices : GovernanceDeclaration → List Nat
  declarationIndices d =
    map propositionIndexOf (GovernanceDeclaration.propositions d)

  establishmentIndices : List Establishment → List Nat
  establishmentIndices = map establishmentIndex

  dispositionSubjects : List PropositionDisposition → List Nat
  dispositionSubjects =
    map PropositionDisposition.propositionIndex

  declaredHere : Nat → GovernanceDeclaration → Bool
  declaredHere n d = containsNat n (declarationIndices d)

  establishedHere : Nat → Establishment → Bool
  establishedHere n e = sameNat n (establishmentIndex e)

  establishedIn : Nat → List Establishment → Bool
  establishedIn n es = containsNat n (establishmentIndices es)

  dispositionFor : Nat → List PropositionDisposition → Maybe Disposition
  dispositionFor _ [] = nothing
  dispositionFor n (d ∷ ds)
    with sameNat n (PropositionDisposition.propositionIndex d)
  ... | true = just (PropositionDisposition.disposition d)
  ... | false = dispositionFor n ds

private
  abandonedSubjects : List PropositionDisposition → List Nat
  abandonedSubjects [] = []
  abandonedSubjects (d ∷ ds) with PropositionDisposition.disposition d
  ... | abandoned =
    PropositionDisposition.propositionIndex d ∷ abandonedSubjects ds
  ... | _ = abandonedSubjects ds

  withdrawnSubjects : List PropositionDisposition → List Nat
  withdrawnSubjects [] = []
  withdrawnSubjects (d ∷ ds) with PropositionDisposition.disposition d
  ... | withdrawn =
    PropositionDisposition.propositionIndex d ∷ withdrawnSubjects ds
  ... | _ = withdrawnSubjects ds

  reformulatedSubjects : List PropositionDisposition → List Nat
  reformulatedSubjects [] = []
  reformulatedSubjects (d ∷ ds) with PropositionDisposition.disposition d
  ... | reformulated _ =
    PropositionDisposition.propositionIndex d ∷ reformulatedSubjects ds
  ... | _ = reformulatedSubjects ds

  allPropositions : History → List Nat
  allPropositions ε = []
  allPropositions (h ▻ declare d) =
    allPropositions h ++ declarationIndices d
  allPropositions (h ▻ _) = allPropositions h

  allEstablished : History → List Nat
  allEstablished ε = []
  allEstablished (h ▻ establish e) =
    allEstablished h ++ (establishmentIndex e ∷ [])
  allEstablished (h ▻ supersede s) =
    allEstablished h ++ establishmentIndices (Supersession.establishments s)
  allEstablished (h ▻ _) = allEstablished h

  allAbandoned : History → List Nat
  allAbandoned ε = []
  allAbandoned (h ▻ abandon p) =
    allAbandoned h ++ (p ∷ [])
  allAbandoned (h ▻ supersede s) =
    allAbandoned h ++ abandonedSubjects (Supersession.dispositions s)
  allAbandoned (h ▻ _) = allAbandoned h

  allWithdrawn : History → List Nat
  allWithdrawn ε = []
  allWithdrawn (h ▻ supersede s) =
    allWithdrawn h ++ withdrawnSubjects (Supersession.dispositions s)
  allWithdrawn (h ▻ _) = allWithdrawn h

  allReformulated : History → List Nat
  allReformulated ε = []
  allReformulated (h ▻ supersede s) =
    allReformulated h ++ reformulatedSubjects (Supersession.dispositions s)
  allReformulated (h ▻ _) = allReformulated h

Declared : History → Nat → Bool
Declared h p = containsNat p (allPropositions h)

EverEstablished : History → Nat → Bool
EverEstablished h p = containsNat p (allEstablished h)

WasAbandoned : History → Nat → Bool
WasAbandoned h p = containsNat p (allAbandoned h)

WasWithdrawn : History → Nat → Bool
WasWithdrawn h p = containsNat p (allWithdrawn h)

WasReformulated : History → Nat → Bool
WasReformulated h p = containsNat p (allReformulated h)

Terminated : History → Nat → Bool
Terminated h p =
  WasAbandoned h p ∨ WasWithdrawn h p ∨ WasReformulated h p

Live : History → Nat → Bool
Live h p = Declared h p ∧ not (Terminated h p)

Pending : History → Nat → Bool
Pending h p = Live h p ∧ not (EverEstablished h p)

Active : History → Nat → Bool
Active h p = Live h p ∧ EverEstablished h p
origin : History → Nat → Maybe Nat
origin ε _ = nothing
origin (h ▻ declare d) p with origin h p
... | just g = just g
... | nothing with declaredHere p d
...   | true = just (GovernanceDeclaration.governance d)
...   | false = nothing
origin (h ▻ _) p = origin h p

currentResponsibility : History → Nat → Maybe Nat
currentResponsibility ε _ = nothing
currentResponsibility (h ▻ declare d) p with declaredHere p d
... | true = just (GovernanceDeclaration.governance d)
... | false = currentResponsibility h p
currentResponsibility (h ▻ abandon q) p with sameNat p q
... | true = nothing
... | false = currentResponsibility h p
currentResponsibility (h ▻ supersede s) p with dispositionFor p (Supersession.dispositions s)
... | just preserved = just (Supersession.successor s)
... | just abandoned = nothing
... | just withdrawn = nothing
... | just (reformulated _) = nothing
... | nothing = currentResponsibility h p
currentResponsibility (h ▻ _) p = currentResponsibility h p

private
  ownedBy : Nat → Maybe Nat → Bool
  ownedBy _ nothing = false
  ownedBy g (just owner) = sameNat g owner

  filterOutgoing : History → Nat → List Nat → List Nat
  filterOutgoing h g =
    filterᵇ (λ p → ownedBy g (currentResponsibility h p))

outgoing : History → Nat → List Nat
outgoing h g = filterOutgoing h g (allPropositions h)

GovernanceSubjects : History → Nat → List Nat
GovernanceSubjects ε _ = []
GovernanceSubjects (h ▻ declare d) g with sameNat g (GovernanceDeclaration.governance d)
... | true = GovernanceSubjects h g ++ declarationIndices d
... | false = GovernanceSubjects h g
GovernanceSubjects (h ▻ supersede s) g with sameNat g (Supersession.successor s)
... | true = GovernanceSubjects h g ++ dispositionSubjects (Supersession.dispositions s)
... | false = GovernanceSubjects h g
GovernanceSubjects (h ▻ _) g = GovernanceSubjects h g

data PropositionResolution : Set where
  pendingResolution establishedResolution abandonedResolution : PropositionResolution

resolution : History → Nat → PropositionResolution
resolution h p with EverEstablished h p
... | true = establishedResolution
... | false with WasAbandoned h p
...   | true = abandonedResolution
...   | false = pendingResolution

data GovernanceGlyph : Set where
  diamond check mixed cross : GovernanceGlyph
private
  anyPending : History → List Nat → Bool
  anyPending h = any (Pending h)

  anyEstablished : History → List Nat → Bool
  anyEstablished h = any (EverEstablished h)

  anyAbandoned : History → List Nat → Bool
  anyAbandoned h = any (WasAbandoned h)

private
  glyphFor : Bool → Bool → Bool → GovernanceGlyph
  glyphFor true _ _ = diamond
  glyphFor false true true = mixed
  glyphFor false true false = check
  glyphFor false false _ = cross

governanceGlyph : History → Nat → GovernanceGlyph
governanceGlyph h g with GovernanceSubjects h g
... | [] = diamond
... | subjects =
  glyphFor
    (anyPending h subjects)
    (anyEstablished h subjects)
    (anyAbandoned h subjects)

private
  sameSubjects : List Nat → List Nat → Bool
  sameSubjects xs ys =
    does (xs ⊆? ys) ∧ does (ys ⊆? xs) ∧ does (unique? xs)

  allFresh : History → List Nat → Bool
  allFresh h ps =
    all (λ p → not (Declared h p)) ps ∧ does (unique? ps)

  targetUsed : Nat → List PropositionDisposition → Bool
  targetUsed _ [] = false
  targetUsed n (d ∷ ds) with PropositionDisposition.disposition d
  ... | reformulated targets = containsNat n targets ∨ targetUsed n ds
  ... | _ = targetUsed n ds

  allEstablishmentsUsed :
    List Establishment → List PropositionDisposition → Bool
  allEstablishmentsUsed es ds =
    all (λ e → targetUsed (establishmentIndex e) ds) es

  replacementReady : History → Supersession → Nat → Bool
  replacementReady h s p =
    (Active h p ∨ establishedIn p (Supersession.establishments s)) ∧
    ownedBy (Supersession.successor s) (currentResponsibility h p)

  allTargetsReady : History → Supersession → List Nat → Bool
  allTargetsReady h s = all (replacementReady h s)

  dispositionValid : History → Supersession → PropositionDisposition → Bool
  dispositionValid h s d with PropositionDisposition.disposition d
  ... | preserved = Live h (PropositionDisposition.propositionIndex d)
  ... | abandoned = Pending h (PropositionDisposition.propositionIndex d)
  ... | withdrawn = Active h (PropositionDisposition.propositionIndex d)
  ... | reformulated targets =
    Active h (PropositionDisposition.propositionIndex d) ∧
    allTargetsReady h s targets

  allDispositionsValid :
    History → Supersession → List PropositionDisposition → Bool
  allDispositionsValid h s = all (dispositionValid h s)

  supersessionValid : History → Supersession → Bool
  supersessionValid h s =
    sameSubjects
      (dispositionSubjects (Supersession.dispositions s))
      (outgoing h (Supersession.previous s))
    ∧ allDispositionsValid h s (Supersession.dispositions s)
    ∧ allEstablishmentsUsed
      (Supersession.establishments s)
      (Supersession.dispositions s)

data Valid : Bool → Set where
  valid : Valid true

ValidEntry : History → HistoryEntry → Set
ValidEntry h (declare d) = Valid (allFresh h (declarationIndices d))
ValidEntry h (establish e) = Valid (Pending h (establishmentIndex e))
ValidEntry h (abandon p) = Valid (Pending h p)
ValidEntry h (supersede s) = Valid (supersessionValid h s)

data ValidHistory : History → Set₁ where
  empty : ValidHistory ε
  extend : {h : History} → ValidHistory h → (entry : HistoryEntry) →
           ValidEntry h entry → ValidHistory (h ▻ entry)