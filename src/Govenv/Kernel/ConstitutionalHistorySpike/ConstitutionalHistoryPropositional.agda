{-# OPTIONS --safe #-}

module Govenv.Kernel.ConstitutionalHistorySpike.ConstitutionalHistoryPropositional where

open import Agda.Builtin.Equality using (_≡_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Level using (Lift; lift; lower; zero; suc)
open import Data.Bool.Base using (Bool; true; false)
open import Data.Bool.ListAction using (all; any)
open import Data.Empty using (⊥)
open import Data.Product.Base using (_×_; _,_)
open import Data.Sum.Base using (_⊎_)
open import Data.Nat.Properties using (_≟_)
open import Data.List.Base using (List; []; _∷_; _++_; map; filterᵇ)
open import Data.List.Membership.Propositional using (_∈_)
open import Data.List.Membership.DecPropositional _≟_ using (_∈?_)
open import Data.List.Relation.Binary.Subset.Propositional using (_⊆_)
open import Data.List.Relation.Binary.Subset.DecPropositional _≟_ using (_⊆?_)
open import Data.List.Relation.Unary.All using (All; all?)
open import Data.List.Relation.Unary.Any using (Any; any?)
open import Data.List.Relation.Unary.Unique.Propositional using (Unique)
open import Data.List.Relation.Unary.Unique.DecPropositional _≟_
  using (unique?)
import Data.Maybe.Properties as MaybeProperties
open import Relation.Nullary using (Dec; ¬_; no; map′)
open import Relation.Nullary.Decidable
  using (does; _×-dec_; _⊎-dec_; ¬?)

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

Declared : History → Nat → Set
Declared h p = p ∈ allPropositions h

EverEstablished : History → Nat → Set
EverEstablished h p = p ∈ allEstablished h

WasAbandoned : History → Nat → Set
WasAbandoned h p = p ∈ allAbandoned h

WasWithdrawn : History → Nat → Set
WasWithdrawn h p = p ∈ allWithdrawn h

WasReformulated : History → Nat → Set
WasReformulated h p = p ∈ allReformulated h

Terminated : History → Nat → Set
Terminated h p =
  WasAbandoned h p ⊎ (WasWithdrawn h p ⊎ WasReformulated h p)

Live : History → Nat → Set
Live h p = Declared h p × ¬ Terminated h p

Pending : History → Nat → Set
Pending h p = Live h p × ¬ EverEstablished h p

Active : History → Nat → Set
Active h p = Live h p × EverEstablished h p

declared? : (h : History) → (p : Nat) → Dec (Declared h p)
declared? h p = p ∈? allPropositions h

everEstablished? : (h : History) → (p : Nat) → Dec (EverEstablished h p)
everEstablished? h p = p ∈? allEstablished h

wasAbandoned? : (h : History) → (p : Nat) → Dec (WasAbandoned h p)
wasAbandoned? h p = p ∈? allAbandoned h

wasWithdrawn? : (h : History) → (p : Nat) → Dec (WasWithdrawn h p)
wasWithdrawn? h p = p ∈? allWithdrawn h

wasReformulated? : (h : History) → (p : Nat) → Dec (WasReformulated h p)
wasReformulated? h p = p ∈? allReformulated h

terminated? : (h : History) → (p : Nat) → Dec (Terminated h p)
terminated? h p =
  wasAbandoned? h p ⊎-dec (wasWithdrawn? h p ⊎-dec wasReformulated? h p)

live? : (h : History) → (p : Nat) → Dec (Live h p)
live? h p = declared? h p ×-dec ¬? (terminated? h p)

pending? : (h : History) → (p : Nat) → Dec (Pending h p)
pending? h p = live? h p ×-dec ¬? (everEstablished? h p)

active? : (h : History) → (p : Nat) → Dec (Active h p)
active? h p = live? h p ×-dec everEstablished? h p

private
  pendingᵇ : History → Nat → Bool
  pendingᵇ h p = does (pending? h p)

  everEstablishedᵇ : History → Nat → Bool
  everEstablishedᵇ h p = does (everEstablished? h p)

  wasAbandonedᵇ : History → Nat → Bool
  wasAbandonedᵇ h p = does (wasAbandoned? h p)
origin : History → Nat → Maybe Nat
origin ε _ = nothing
origin (h ▻ declare d) p with origin h p
... | just g = just g
... | nothing with declaredHere p d
...   | true = just (GovernanceDeclaration.governance d)
...   | false = nothing
origin (h ▻ _) p = origin h p

private
  currentResponsibilityMaybe : History → Nat → Maybe Nat
  currentResponsibilityMaybe ε _ = nothing
  currentResponsibilityMaybe (h ▻ declare d) p with declaredHere p d
  ... | true = just (GovernanceDeclaration.governance d)
  ... | false = currentResponsibilityMaybe h p
  currentResponsibilityMaybe (h ▻ abandon q) p with sameNat p q
  ... | true = nothing
  ... | false = currentResponsibilityMaybe h p
  currentResponsibilityMaybe (h ▻ supersede s) p
    with dispositionFor p (Supersession.dispositions s)
  ... | just preserved = just (Supersession.successor s)
  ... | just abandoned = nothing
  ... | just withdrawn = nothing
  ... | just (reformulated _) = nothing
  ... | nothing = currentResponsibilityMaybe h p
  currentResponsibilityMaybe (h ▻ _) p = currentResponsibilityMaybe h p

ResponsibleTo : History → Nat → Nat → Set
ResponsibleTo h g p = currentResponsibilityMaybe h p ≡ just g

responsibleTo? : (h : History) → (g p : Nat) → Dec (ResponsibleTo h g p)
responsibleTo? h g p =
  MaybeProperties.≡-dec _≟_ (currentResponsibilityMaybe h p) (just g)

private
  filterOutgoing : History → Nat → List Nat → List Nat
  filterOutgoing h g =
    filterᵇ (λ p → does (responsibleTo? h g p))

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
resolution h p with everEstablishedᵇ h p
... | true = establishedResolution
... | false with wasAbandonedᵇ h p
...   | true = abandonedResolution
...   | false = pendingResolution

data GovernanceGlyph : Set where
  diamond check mixed cross : GovernanceGlyph
private
  anyPending : History → List Nat → Bool
  anyPending h = any (pendingᵇ h)

  anyEstablished : History → List Nat → Bool
  anyEstablished h = any (everEstablishedᵇ h)

  anyAbandoned : History → List Nat → Bool
  anyAbandoned h = any (wasAbandonedᵇ h)

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

Fresh : History → Nat → Set
Fresh h p = ¬ Declared h p

fresh? : (h : History) → (p : Nat) → Dec (Fresh h p)
fresh? h p = ¬? (declared? h p)

DeclarationValid : History → GovernanceDeclaration → Set
DeclarationValid h d =
  All (Fresh h) (declarationIndices d) × Unique (declarationIndices d)

declarationValid? :
  (h : History) → (d : GovernanceDeclaration) → Dec (DeclarationValid h d)
declarationValid? h d =
  all? (fresh? h) (declarationIndices d) ×-dec
  unique? (declarationIndices d)

EstablishmentValid : History → Establishment → Set
EstablishmentValid h e = Pending h (establishmentIndex e)

establishmentValid? :
  (h : History) → (e : Establishment) → Dec (EstablishmentValid h e)
establishmentValid? h e = pending? h (establishmentIndex e)

AbandonmentValid : History → Nat → Set
AbandonmentValid h p = Pending h p

abandonmentValid? : (h : History) → (p : Nat) → Dec (AbandonmentValid h p)
abandonmentValid? = pending?

private
  TargetOf : Nat → PropositionDisposition → Set
  TargetOf p d with PropositionDisposition.disposition d
  ... | preserved = ⊥
  ... | abandoned = ⊥
  ... | withdrawn = ⊥
  ... | reformulated targets = p ∈ targets

  targetOf? : (p : Nat) → (d : PropositionDisposition) → Dec (TargetOf p d)
  targetOf? p d with PropositionDisposition.disposition d
  ... | preserved = no (λ ())
  ... | abandoned = no (λ ())
  ... | withdrawn = no (λ ())
  ... | reformulated targets = p ∈? targets

  TargetUsed : Nat → List PropositionDisposition → Set
  TargetUsed p ds = Any (TargetOf p) ds

  targetUsed? :
    (p : Nat) → (ds : List PropositionDisposition) → Dec (TargetUsed p ds)
  targetUsed? p = any? (targetOf? p)

  EstablishmentUsed : List PropositionDisposition → Establishment → Set
  EstablishmentUsed ds e = TargetUsed (establishmentIndex e) ds

  AllEstablishmentsUsed : Supersession → Set₁
  AllEstablishmentsUsed s =
    All
      (EstablishmentUsed (Supersession.dispositions s))
      (Supersession.establishments s)

  allEstablishmentsUsed? :
    (s : Supersession) → Dec (AllEstablishmentsUsed s)
  allEstablishmentsUsed? s =
    all?
      (λ e → targetUsed? (establishmentIndex e) (Supersession.dispositions s))
      (Supersession.establishments s)

  EmbeddedEstablishmentsValid : History → Supersession → Set₁
  EmbeddedEstablishmentsValid h s =
    All (EstablishmentValid h) (Supersession.establishments s) ×
    Unique (establishmentIndices (Supersession.establishments s))

  embeddedEstablishmentsValid? :
    (h : History) → (s : Supersession) →
    Dec (EmbeddedEstablishmentsValid h s)
  embeddedEstablishmentsValid? h s =
    all? (establishmentValid? h) (Supersession.establishments s) ×-dec
    unique? (establishmentIndices (Supersession.establishments s))

  ReplacementReady : History → Supersession → Nat → Set
  ReplacementReady h s p =
    (Active h p ⊎ p ∈ establishmentIndices (Supersession.establishments s)) ×
    ResponsibleTo h (Supersession.successor s) p

  replacementReady? :
    (h : History) → (s : Supersession) → (p : Nat) →
    Dec (ReplacementReady h s p)
  replacementReady? h s p =
    (active? h p ⊎-dec
      (p ∈? establishmentIndices (Supersession.establishments s))) ×-dec
    responsibleTo? h (Supersession.successor s) p

  AllTargetsReady : History → Supersession → List Nat → Set
  AllTargetsReady h s = All (ReplacementReady h s)

  allTargetsReady? :
    (h : History) → (s : Supersession) → (targets : List Nat) →
    Dec (AllTargetsReady h s targets)
  allTargetsReady? h s = all? (replacementReady? h s)

  DispositionValid :
    History → Supersession → PropositionDisposition → Set
  DispositionValid h s d with PropositionDisposition.disposition d
  ... | preserved = Live h (PropositionDisposition.propositionIndex d)
  ... | abandoned = Pending h (PropositionDisposition.propositionIndex d)
  ... | withdrawn = Active h (PropositionDisposition.propositionIndex d)
  ... | reformulated targets =
    Active h (PropositionDisposition.propositionIndex d) ×
    AllTargetsReady h s targets

  dispositionValid? :
    (h : History) → (s : Supersession) → (d : PropositionDisposition) →
    Dec (DispositionValid h s d)
  dispositionValid? h s d with PropositionDisposition.disposition d
  ... | preserved = live? h (PropositionDisposition.propositionIndex d)
  ... | abandoned = pending? h (PropositionDisposition.propositionIndex d)
  ... | withdrawn = active? h (PropositionDisposition.propositionIndex d)
  ... | reformulated targets =
    active? h (PropositionDisposition.propositionIndex d) ×-dec
    allTargetsReady? h s targets

  AllDispositionsValid : History → Supersession → Set
  AllDispositionsValid h s =
    All (DispositionValid h s) (Supersession.dispositions s)

  allDispositionsValid? :
    (h : History) → (s : Supersession) → Dec (AllDispositionsValid h s)
  allDispositionsValid? h s =
    all? (dispositionValid? h s) (Supersession.dispositions s)

  SupersessionCoverage : History → Supersession → Set
  SupersessionCoverage h s =
    dispositionSubjects (Supersession.dispositions s) ⊆
      outgoing h (Supersession.previous s)
    × outgoing h (Supersession.previous s) ⊆
      dispositionSubjects (Supersession.dispositions s)
    × Unique (dispositionSubjects (Supersession.dispositions s))

  supersessionCoverage? :
    (h : History) → (s : Supersession) → Dec (SupersessionCoverage h s)
  supersessionCoverage? h s =
    dispositionSubjects (Supersession.dispositions s) ⊆?
      outgoing h (Supersession.previous s)
    ×-dec outgoing h (Supersession.previous s) ⊆?
      dispositionSubjects (Supersession.dispositions s)
    ×-dec unique? (dispositionSubjects (Supersession.dispositions s))

SupersessionValid : History → Supersession → Set₁
SupersessionValid h s =
  SupersessionCoverage h s ×
  AllDispositionsValid h s ×
  EmbeddedEstablishmentsValid h s ×
  AllEstablishmentsUsed s

supersessionValid? :
  (h : History) → (s : Supersession) → Dec (SupersessionValid h s)
supersessionValid? h s =
  supersessionCoverage? h s ×-dec
  allDispositionsValid? h s ×-dec
  embeddedEstablishmentsValid? h s ×-dec
  allEstablishmentsUsed? s

ValidEntry : History → HistoryEntry → Set₁
ValidEntry h (declare d) = Lift (suc zero) (DeclarationValid h d)
ValidEntry h (establish e) = Lift (suc zero) (EstablishmentValid h e)
ValidEntry h (abandon p) = Lift (suc zero) (AbandonmentValid h p)
ValidEntry h (supersede s) = SupersessionValid h s

validEntry? :
  (h : History) → (entry : HistoryEntry) → Dec (ValidEntry h entry)
validEntry? h (declare d) =
  map′ lift lower (declarationValid? h d)
validEntry? h (establish e) =
  map′ lift lower (establishmentValid? h e)
validEntry? h (abandon p) =
  map′ lift lower (abandonmentValid? h p)
validEntry? h (supersede s) = supersessionValid? h s

data ValidHistory : History → Set₁ where
  empty : ValidHistory ε
  extend : {h : History} → ValidHistory h → (entry : HistoryEntry) →
           ValidEntry h entry → ValidHistory (h ▻ entry)