{-# OPTIONS --safe #-}

module Govenv.Experiment.ConstitutionalHistory.Baseline where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; _==_)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤; tt)

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
  not : Bool → Bool
  not true = false
  not false = true

  infixr 6 _and_
  infixr 5 _or_

  _and_ : Bool → Bool → Bool
  true and b = b
  false and _ = false

  _or_ : Bool → Bool → Bool
  true or _ = true
  false or b = b

  containsNat : Nat → List Nat → Bool
  containsNat _ [] = false
  containsNat n (x ∷ xs) with n == x
  ... | true = true
  ... | false = containsNat n xs

  propositionIndexOf : SomeProposition → Nat
  propositionIndexOf (someProposition {idx = idx} _) = idx
  declaredHere : Nat → GovernanceDeclaration → Bool
  declaredHere n d = containsNat n (indices (GovernanceDeclaration.propositions d))
    where
    indices : List SomeProposition → List Nat
    indices [] = []
    indices (p ∷ ps) = propositionIndexOf p ∷ indices ps

  establishedHere : Nat → Establishment → Bool
  establishedHere n (establishment {idx = idx} _ _) = n == idx

  establishedIn : Nat → List Establishment → Bool
  establishedIn _ [] = false
  establishedIn n (e ∷ es) = establishedHere n e or establishedIn n es

  dispositionFor : Nat → List PropositionDisposition → Maybe Disposition
  dispositionFor _ [] = nothing
  dispositionFor n (d ∷ ds) with n == PropositionDisposition.propositionIndex d
  ... | true = just (PropositionDisposition.disposition d)
  ... | false = dispositionFor n ds

data PropositionState : Set where
  unseen pending active abandonedState retired : PropositionState

applyDisposition : PropositionState → Maybe Disposition → PropositionState
applyDisposition s nothing = s
applyDisposition s (just preserved) = s
applyDisposition _ (just abandoned) = abandonedState
applyDisposition _ (just withdrawn) = retired
applyDisposition _ (just (reformulated _)) = retired

propositionState : History → Nat → PropositionState
propositionState ε _ = unseen
propositionState (h ▻ declare d) n with declaredHere n d
... | true = pending
... | false = propositionState h n
propositionState (h ▻ establish e) n with establishedHere n e
... | true = active
... | false = propositionState h n
propositionState (h ▻ abandon p) n with n == p
... | true = abandonedState
... | false = propositionState h n
propositionState (h ▻ supersede s) n =
  applyDisposition established (dispositionFor n (Supersession.dispositions s))
  where
  before : PropositionState
  before = propositionState h n

  established : PropositionState
  established with establishedIn n (Supersession.establishments s)
  ... | true = active
  ... | false = before

Declared : History → Nat → Bool
Declared h p with propositionState h p
... | unseen = false
... | _ = true

EverEstablished : History → Nat → Bool
EverEstablished ε _ = false
EverEstablished (h ▻ establish e) p = establishedHere p e or EverEstablished h p
EverEstablished (h ▻ supersede s) p = establishedIn p (Supersession.establishments s) or EverEstablished h p
EverEstablished (h ▻ _) p = EverEstablished h p

WasAbandoned : History → Nat → Bool
WasAbandoned ε _ = false
WasAbandoned (h ▻ abandon q) p = (p == q) or WasAbandoned h p
WasAbandoned (h ▻ supersede s) p with dispositionFor p (Supersession.dispositions s)
... | just abandoned = true
... | _ = WasAbandoned h p
WasAbandoned (h ▻ _) p = WasAbandoned h p

Live : History → Nat → Bool
Live h p with propositionState h p
... | pending = true
... | active = true
... | _ = false

Pending : History → Nat → Bool
Pending h p with propositionState h p
... | pending = true
... | _ = false

Active : History → Nat → Bool
Active h p with propositionState h p
... | active = true
... | _ = false
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
currentResponsibility (h ▻ abandon q) p with p == q
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
  establishmentIndex : Establishment → Nat
  establishmentIndex (establishment {idx = idx} _ _) = idx

  declarationIndices : GovernanceDeclaration → List Nat
  declarationIndices d = go (GovernanceDeclaration.propositions d)
    where
    go : List SomeProposition → List Nat
    go [] = []
    go (p ∷ ps) = propositionIndexOf p ∷ go ps

  dispositionSubjects : List PropositionDisposition → List Nat
  dispositionSubjects [] = []
  dispositionSubjects (d ∷ ds) =
    PropositionDisposition.propositionIndex d ∷ dispositionSubjects ds
  _++_ : {A : Set} → List A → List A → List A
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

  allPropositions : History → List Nat
  allPropositions ε = []
  allPropositions (h ▻ declare d) = allPropositions h ++ declarationIndices d
  allPropositions (h ▻ _) = allPropositions h

  ownedBy : Nat → Maybe Nat → Bool
  ownedBy _ nothing = false
  ownedBy g (just owner) = g == owner

  filterOutgoing : History → Nat → List Nat → List Nat
  filterOutgoing _ _ [] = []
  filterOutgoing h g (p ∷ ps) with ownedBy g (currentResponsibility h p)
  ... | true = p ∷ filterOutgoing h g ps
  ... | false = filterOutgoing h g ps

outgoing : History → Nat → List Nat
outgoing h g = filterOutgoing h g (allPropositions h)

GovernanceSubjects : History → Nat → List Nat
GovernanceSubjects ε _ = []
GovernanceSubjects (h ▻ declare d) g with g == GovernanceDeclaration.governance d
... | true = GovernanceSubjects h g ++ declarationIndices d
... | false = GovernanceSubjects h g
GovernanceSubjects (h ▻ supersede s) g with g == Supersession.successor s
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
  anyPending _ [] = false
  anyPending h (p ∷ ps) = Pending h p or anyPending h ps

  anyEstablished : History → List Nat → Bool
  anyEstablished _ [] = false
  anyEstablished h (p ∷ ps) = EverEstablished h p or anyEstablished h ps

  anyAbandoned : History → List Nat → Bool
  anyAbandoned _ [] = false
  anyAbandoned h (p ∷ ps) = WasAbandoned h p or anyAbandoned h ps

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
  listNatEqual : List Nat → List Nat → Bool
  listNatEqual [] [] = true
  listNatEqual [] (_ ∷ _) = false
  listNatEqual (_ ∷ _) [] = false
  listNatEqual (x ∷ xs) (y ∷ ys) = (x == y) and listNatEqual xs ys

  allFresh : History → List Nat → Bool
  allFresh _ [] = true
  allFresh h (p ∷ ps) = not (Declared h p) and allFresh h ps

  targetUsed : Nat → List PropositionDisposition → Bool
  targetUsed _ [] = false
  targetUsed n (d ∷ ds) with PropositionDisposition.disposition d
  ... | reformulated targets = containsNat n targets or targetUsed n ds
  ... | _ = targetUsed n ds

  allEstablishmentsUsed : List Establishment → List PropositionDisposition → Bool
  allEstablishmentsUsed [] _ = true
  allEstablishmentsUsed (e ∷ es) ds =
    targetUsed (establishmentIndex e) ds and allEstablishmentsUsed es ds
  replacementReady : History → Supersession → Nat → Bool
  replacementReady h s p =
    (Active h p or establishedIn p (Supersession.establishments s)) and
    ownedBy (Supersession.successor s) (currentResponsibility h p)

  allTargetsReady : History → Supersession → List Nat → Bool
  allTargetsReady _ _ [] = true
  allTargetsReady h s (p ∷ ps) =
    replacementReady h s p and allTargetsReady h s ps

  dispositionValid : History → Supersession → PropositionDisposition → Bool
  dispositionValid h s d with PropositionDisposition.disposition d
  ... | preserved = Live h (PropositionDisposition.propositionIndex d)
  ... | abandoned = Pending h (PropositionDisposition.propositionIndex d)
  ... | withdrawn = Active h (PropositionDisposition.propositionIndex d)
  ... | reformulated targets =
    Active h (PropositionDisposition.propositionIndex d) and allTargetsReady h s targets

  allDispositionsValid : History → Supersession → List PropositionDisposition → Bool
  allDispositionsValid _ _ [] = true
  allDispositionsValid h s (d ∷ ds) =
    dispositionValid h s d and allDispositionsValid h s ds

  supersessionValid : History → Supersession → Bool
  supersessionValid h s =
    (listNatEqual
      (dispositionSubjects (Supersession.dispositions s))
      (outgoing h (Supersession.previous s)))
    and (allDispositionsValid h s (Supersession.dispositions s))
    and (allEstablishmentsUsed
      (Supersession.establishments s)
      (Supersession.dispositions s))

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