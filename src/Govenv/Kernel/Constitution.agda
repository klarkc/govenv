{-# OPTIONS --safe #-}

module Govenv.Kernel.Constitution where

-- Append-only constitutional history. Raw History is descriptive data;
-- Constitution is the authoritative boundary because it carries a proof that
-- every extension is structurally ready and supplies the required formal evidence.

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤; tt)
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
open import Relation.Nullary using (Dec; ¬_; yes; no)
open import Relation.Nullary.Decidable
  using (does; _×-dec_; _⊎-dec_; ¬?)
open import Govenv.Kernel.Identifier using
  (GovernanceId; GovernanceRef; PhaseId; IdentifierRef; indexOf)
open import Govenv.Kernel.Constitution.Genesis using
  ( Genesis; GenesisState; GenesisGovernance
  ; pendingAtCutover; completedAtCutover; abandonedAtCutover; supersededAtCutover
  ; governanceItems; governanceIndices; supersededIndices
  ; phaseIndices; currentPhaseIndex; owningPhaseIndex
  ; stateFor; successorFor; successorIndex; genesisGovernanceIndex
  )

Contract : Set
Contract = String

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

Evidence : {idx : Nat} → Proposition idx → Set
Evidence = Proposition.Statement

record GovernanceDeclaration : Set₁ where
  constructor governanceDeclaration
  field
    {governanceIndex} : Nat
    {contract} : Contract
    governance : GovernanceId governanceIndex contract
    {phaseIndex} : Nat
    {phaseDescription} : String
    phase : PhaseId phaseIndex phaseDescription
    propositions : List SomeProposition

-- Formal truth may be introduced after the human GovernanceId contract. This is
-- essential for migrating legacy pending contracts without inventing Statements.
-- Validation below permits late propositions only while the owning governance
-- lifecycle remains pending and the owner has not been superseded.
record PropositionDeclaration : Set₁ where
  constructor propositionDeclaration
  field
    owner : GovernanceRef
    subject : SomeProposition

record Establishment : Set where
  constructor establishment
  field
    propositionIndex : Nat

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
    previous       : GovernanceRef
    successor      : GovernanceRef
    establishments : List Establishment
    dispositions   : List PropositionDisposition

data HistoryEntry : Set₁ where
  bootstrap : Genesis → HistoryEntry
  declare   : GovernanceDeclaration → HistoryEntry
  propose   : PropositionDeclaration → HistoryEntry
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
  establishmentIndex = Establishment.propositionIndex

  governanceIndexOf : GovernanceDeclaration → Nat
  governanceIndexOf d = indexOf (GovernanceDeclaration.governance d)

  governanceRefIndex : GovernanceRef → Nat
  governanceRefIndex = IdentifierRef.referenceIndex

  declarationIndices : GovernanceDeclaration → List Nat
  declarationIndices d =
    map propositionIndexOf (GovernanceDeclaration.propositions d)

  proposedIndex : PropositionDeclaration → Nat
  proposedIndex p = propositionIndexOf (PropositionDeclaration.subject p)

  propositionOwnerIndex : PropositionDeclaration → Nat
  propositionOwnerIndex p = governanceRefIndex (PropositionDeclaration.owner p)

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
  lookupProposition : Nat → List SomeProposition → Maybe SomeProposition
  lookupProposition p [] = nothing
  lookupProposition p (candidate ∷ rest)
    with sameNat p (propositionIndexOf candidate)
  ... | true = just candidate
  ... | false = lookupProposition p rest

declaredProposition : History → Nat → Maybe SomeProposition
declaredProposition ε p = nothing
declaredProposition (h ▻ declare d) p with declaredProposition h p
... | just declared = just declared
... | nothing = lookupProposition p (GovernanceDeclaration.propositions d)
declaredProposition (h ▻ propose d) p with declaredProposition h p
... | just declared = just declared
... | nothing with sameNat p (proposedIndex d)
...   | true = just (PropositionDeclaration.subject d)
...   | false = nothing
declaredProposition (h ▻ _) p = declaredProposition h p

EvidenceAt : History → Nat → Set
EvidenceAt h p with declaredProposition h p
... | nothing = ⊥
... | just (someProposition subject) = Evidence subject

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
  allPropositions (h ▻ propose d) =
    allPropositions h ++ (proposedIndex d ∷ [])
  allPropositions (h ▻ _) = allPropositions h

  allGovernanceIndices : History → List Nat
  allGovernanceIndices ε = []
  allGovernanceIndices (h ▻ bootstrap genesis) =
    allGovernanceIndices h ++ governanceIndices genesis
  allGovernanceIndices (h ▻ declare d) =
    allGovernanceIndices h ++ (governanceIndexOf d ∷ [])
  allGovernanceIndices (h ▻ _) = allGovernanceIndices h

  allSupersededGovernance : History → List Nat
  allSupersededGovernance ε = []
  allSupersededGovernance (h ▻ bootstrap genesis) =
    allSupersededGovernance h ++ supersededIndices genesis
  allSupersededGovernance (h ▻ supersede s) =
    allSupersededGovernance h ++
    (governanceRefIndex (Supersession.previous s) ∷ [])
  allSupersededGovernance (h ▻ _) = allSupersededGovernance h

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
...   | true = just (governanceIndexOf d)
...   | false = nothing
origin (h ▻ propose d) p with origin h p
... | just g = just g
... | nothing with sameNat p (proposedIndex d)
...   | true = just (propositionOwnerIndex d)
...   | false = nothing
origin (h ▻ _) p = origin h p

private
  currentResponsibilityMaybe : History → Nat → Maybe Nat
  currentResponsibilityMaybe ε _ = nothing
  currentResponsibilityMaybe (h ▻ declare d) p with declaredHere p d
  ... | true = just (governanceIndexOf d)
  ... | false = currentResponsibilityMaybe h p
  currentResponsibilityMaybe (h ▻ propose d) p with sameNat p (proposedIndex d)
  ... | true = just (propositionOwnerIndex d)
  ... | false = currentResponsibilityMaybe h p
  currentResponsibilityMaybe (h ▻ abandon q) p with sameNat p q
  ... | true = nothing
  ... | false = currentResponsibilityMaybe h p
  currentResponsibilityMaybe (h ▻ supersede s) p
    with dispositionFor p (Supersession.dispositions s)
  ... | just preserved = just (governanceRefIndex (Supersession.successor s))
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
GovernanceSubjects (h ▻ declare d) g with sameNat g (governanceIndexOf d)
... | true = GovernanceSubjects h g ++ declarationIndices d
... | false = GovernanceSubjects h g
GovernanceSubjects (h ▻ propose d) g with sameNat g (propositionOwnerIndex d)
... | true = GovernanceSubjects h g ++ (proposedIndex d ∷ [])
... | false = GovernanceSubjects h g
GovernanceSubjects (h ▻ supersede s) g with sameNat g (governanceRefIndex (Supersession.successor s))
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

data GovernanceLifecycle : Set where
  pending completed mixedCompleted abandoned : GovernanceLifecycle

data GovernanceGlyph : Set where
  diamond check mixed cross : GovernanceGlyph

genesisState : History → Nat → Maybe GenesisState
genesisState ε g = nothing
genesisState (h ▻ bootstrap genesis) g with genesisState h g
... | just inherited = just inherited
... | nothing = stateFor genesis g
genesisState (h ▻ _) g = genesisState h g

private
  anyPending : History → List Nat → Bool
  anyPending h = any (pendingᵇ h)

  anyEstablished : History → List Nat → Bool
  anyEstablished h = any (everEstablishedᵇ h)

  anyAbandoned : History → List Nat → Bool
  anyAbandoned h = any (wasAbandonedᵇ h)

  lifecycleFor : Bool → Bool → Bool → GovernanceLifecycle
  lifecycleFor true _ _ = pending
  lifecycleFor false true true = mixedCompleted
  lifecycleFor false true false = completed
  lifecycleFor false false _ = abandoned

  glyphForLifecycle : GovernanceLifecycle → GovernanceGlyph
  glyphForLifecycle pending = diamond
  glyphForLifecycle completed = check
  glyphForLifecycle mixedCompleted = mixed
  glyphForLifecycle abandoned = cross

  inheritedLifecycle : Maybe GenesisState → GovernanceLifecycle
  inheritedLifecycle nothing = pending
  inheritedLifecycle (just pendingAtCutover) = pending
  inheritedLifecycle (just completedAtCutover) = completed
  inheritedLifecycle (just abandonedAtCutover) = abandoned
  inheritedLifecycle (just (supersededAtCutover _)) = pending

governanceLifecycle : History → Nat → GovernanceLifecycle
governanceLifecycle h g with GovernanceSubjects h g
... | [] = inheritedLifecycle (genesisState h g)
... | subjects =
  lifecycleFor
    (anyPending h subjects)
    (anyEstablished h subjects)
    (anyAbandoned h subjects)

governanceGlyph : History → Nat → GovernanceGlyph
governanceGlyph h g = glyphForLifecycle (governanceLifecycle h g)

GovernanceDeclared : History → Nat → Set
GovernanceDeclared h g = g ∈ allGovernanceIndices h

governanceDeclared? : (h : History) → (g : Nat) → Dec (GovernanceDeclared h g)
governanceDeclared? h g = g ∈? allGovernanceIndices h

GovernanceSuperseded : History → Nat → Set
GovernanceSuperseded h g = g ∈ allSupersededGovernance h

governanceSuperseded? :
  (h : History) → (g : Nat) → Dec (GovernanceSuperseded h g)
governanceSuperseded? h g = g ∈? allSupersededGovernance h

GovernanceOpenForPropositions : History → Nat → Set
GovernanceOpenForPropositions h g = governanceLifecycle h g ≡ pending

governanceOpenForPropositions? :
  (h : History) → (g : Nat) → Dec (GovernanceOpenForPropositions h g)
governanceOpenForPropositions? h g with governanceLifecycle h g
... | pending = yes refl
... | completed = no (λ ())
... | mixedCompleted = no (λ ())
... | abandoned = no (λ ())

successorOf : History → Nat → Maybe GovernanceRef
successorOf ε g = nothing
successorOf (h ▻ bootstrap genesis) g with successorOf h g
... | just inherited = just inherited
... | nothing = successorFor genesis g
successorOf (h ▻ supersede s) g with successorOf h g
... | just successor = just successor
... | nothing with sameNat g (governanceRefIndex (Supersession.previous s))
...   | true = just (Supersession.successor s)
...   | false = nothing
successorOf (h ▻ _) g = successorOf h g

private
  GenesisPhaseValid : Genesis → GenesisGovernance → Set
  GenesisPhaseValid genesis item =
    owningPhaseIndex item ∈ phaseIndices genesis

  genesisPhaseValid? :
    (genesis : Genesis) → (item : GenesisGovernance) →
    Dec (GenesisPhaseValid genesis item)
  genesisPhaseValid? genesis item =
    owningPhaseIndex item ∈? phaseIndices genesis

  GenesisSuccessorValid : Genesis → GenesisGovernance → Set
  GenesisSuccessorValid genesis item with successorIndex item
  ... | nothing = ⊤
  ... | just target =
    target ∈ governanceIndices genesis × ¬ (genesisGovernanceIndex item ≡ target)

  genesisSuccessorValid? :
    (genesis : Genesis) → (item : GenesisGovernance) →
    Dec (GenesisSuccessorValid genesis item)
  genesisSuccessorValid? genesis item with successorIndex item
  ... | nothing = yes tt
  ... | just target =
    target ∈? governanceIndices genesis ×-dec
    ¬? (genesisGovernanceIndex item ≟ target)

GenesisValid : Genesis → Set
GenesisValid genesis =
  Unique (phaseIndices genesis) ×
  currentPhaseIndex genesis ∈ phaseIndices genesis ×
  Unique (governanceIndices genesis) ×
  All (GenesisPhaseValid genesis) (governanceItems genesis) ×
  All (GenesisSuccessorValid genesis) (governanceItems genesis)

genesisValid? : (genesis : Genesis) → Dec (GenesisValid genesis)
genesisValid? genesis =
  unique? (phaseIndices genesis) ×-dec
  currentPhaseIndex genesis ∈? phaseIndices genesis ×-dec
  unique? (governanceIndices genesis) ×-dec
  all? (genesisPhaseValid? genesis) (governanceItems genesis) ×-dec
  all? (genesisSuccessorValid? genesis) (governanceItems genesis)

data BootstrapAllowed : History → Set where
  atBeginning : BootstrapAllowed ε

bootstrapAllowed? : (h : History) → Dec (BootstrapAllowed h)
bootstrapAllowed? ε = yes atBeginning
bootstrapAllowed? (_ ▻ _) = no (λ ())

BootstrapValid : History → Genesis → Set
BootstrapValid h genesis = BootstrapAllowed h × GenesisValid genesis

bootstrapValid? : (h : History) → (genesis : Genesis) → Dec (BootstrapValid h genesis)
bootstrapValid? h genesis = bootstrapAllowed? h ×-dec genesisValid? genesis

Fresh : History → Nat → Set
Fresh h p = ¬ Declared h p

fresh? : (h : History) → (p : Nat) → Dec (Fresh h p)
fresh? h p = ¬? (declared? h p)

GovernanceFresh : History → GovernanceDeclaration → Set
GovernanceFresh h d = ¬ GovernanceDeclared h (governanceIndexOf d)

governanceFresh? :
  (h : History) → (d : GovernanceDeclaration) → Dec (GovernanceFresh h d)
governanceFresh? h d = ¬? (governanceDeclared? h (governanceIndexOf d))

DeclarationValid : History → GovernanceDeclaration → Set
DeclarationValid h d =
  GovernanceFresh h d ×
  All (Fresh h) (declarationIndices d) ×
  Unique (declarationIndices d)

declarationValid? :
  (h : History) → (d : GovernanceDeclaration) → Dec (DeclarationValid h d)
declarationValid? h d =
  governanceFresh? h d ×-dec
  all? (fresh? h) (declarationIndices d) ×-dec
  unique? (declarationIndices d)

PropositionDeclarationValid : History → PropositionDeclaration → Set
PropositionDeclarationValid h d =
  GovernanceDeclared h (propositionOwnerIndex d) ×
  ¬ GovernanceSuperseded h (propositionOwnerIndex d) ×
  GovernanceOpenForPropositions h (propositionOwnerIndex d) ×
  Fresh h (proposedIndex d)

propositionDeclarationValid? :
  (h : History) → (d : PropositionDeclaration) →
  Dec (PropositionDeclarationValid h d)
propositionDeclarationValid? h d =
  governanceDeclared? h (propositionOwnerIndex d) ×-dec
  ¬? (governanceSuperseded? h (propositionOwnerIndex d)) ×-dec
  governanceOpenForPropositions? h (propositionOwnerIndex d) ×-dec
  fresh? h (proposedIndex d)

EstablishmentReady : History → Establishment → Set
EstablishmentReady h e = Pending h (establishmentIndex e)

establishmentReady? :
  (h : History) → (e : Establishment) → Dec (EstablishmentReady h e)
establishmentReady? h e = pending? h (establishmentIndex e)

EstablishmentValid : History → Establishment → Set
EstablishmentValid h e =
  EstablishmentReady h e × EvidenceAt h (establishmentIndex e)

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

  AllEstablishmentsUsed : Supersession → Set
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

  EmbeddedEstablishmentsReady : History → Supersession → Set
  EmbeddedEstablishmentsReady h s =
    All (EstablishmentReady h) (Supersession.establishments s) ×
    Unique (establishmentIndices (Supersession.establishments s))

  embeddedEstablishmentsReady? :
    (h : History) → (s : Supersession) →
    Dec (EmbeddedEstablishmentsReady h s)
  embeddedEstablishmentsReady? h s =
    all? (establishmentReady? h) (Supersession.establishments s) ×-dec
    unique? (establishmentIndices (Supersession.establishments s))

  EmbeddedEstablishmentEvidence : History → Supersession → Set
  EmbeddedEstablishmentEvidence h s =
    All
      (λ e → EvidenceAt h (establishmentIndex e))
      (Supersession.establishments s)

  ReplacementReady : History → Supersession → Nat → Set
  ReplacementReady h s p =
    (Active h p ⊎ p ∈ establishmentIndices (Supersession.establishments s)) ×
    ResponsibleTo h (governanceRefIndex (Supersession.successor s)) p

  replacementReady? :
    (h : History) → (s : Supersession) → (p : Nat) →
    Dec (ReplacementReady h s p)
  replacementReady? h s p =
    (active? h p ⊎-dec
      (p ∈? establishmentIndices (Supersession.establishments s))) ×-dec
    responsibleTo? h (governanceRefIndex (Supersession.successor s)) p

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
  ... | reformulated [] = ⊥
  ... | reformulated targets@(_ ∷ _) =
    Active h (PropositionDisposition.propositionIndex d) ×
    Unique targets ×
    AllTargetsReady h s targets

  dispositionValid? :
    (h : History) → (s : Supersession) → (d : PropositionDisposition) →
    Dec (DispositionValid h s d)
  dispositionValid? h s d with PropositionDisposition.disposition d
  ... | preserved = live? h (PropositionDisposition.propositionIndex d)
  ... | abandoned = pending? h (PropositionDisposition.propositionIndex d)
  ... | withdrawn = active? h (PropositionDisposition.propositionIndex d)
  ... | reformulated [] = no (λ ())
  ... | reformulated targets@(_ ∷ _) =
    active? h (PropositionDisposition.propositionIndex d) ×-dec
    unique? targets ×-dec
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
      outgoing h (governanceRefIndex (Supersession.previous s))
    × outgoing h (governanceRefIndex (Supersession.previous s)) ⊆
      dispositionSubjects (Supersession.dispositions s)
    × Unique (dispositionSubjects (Supersession.dispositions s))

  supersessionCoverage? :
    (h : History) → (s : Supersession) → Dec (SupersessionCoverage h s)
  supersessionCoverage? h s =
    dispositionSubjects (Supersession.dispositions s) ⊆?
      outgoing h (governanceRefIndex (Supersession.previous s))
    ×-dec outgoing h (governanceRefIndex (Supersession.previous s)) ⊆?
      dispositionSubjects (Supersession.dispositions s)
    ×-dec unique? (dispositionSubjects (Supersession.dispositions s))

SupersessionEndpointsValid : History → Supersession → Set
SupersessionEndpointsValid h s =
  GovernanceDeclared h (governanceRefIndex (Supersession.previous s)) ×
  GovernanceDeclared h (governanceRefIndex (Supersession.successor s)) ×
  ¬ GovernanceSuperseded h (governanceRefIndex (Supersession.previous s)) ×
  ¬ (governanceRefIndex (Supersession.previous s) ≡
     governanceRefIndex (Supersession.successor s))

supersessionEndpointsValid? :
  (h : History) → (s : Supersession) → Dec (SupersessionEndpointsValid h s)
supersessionEndpointsValid? h s =
  governanceDeclared? h (governanceRefIndex (Supersession.previous s)) ×-dec
  governanceDeclared? h (governanceRefIndex (Supersession.successor s)) ×-dec
  ¬? (governanceSuperseded? h (governanceRefIndex (Supersession.previous s))) ×-dec
  ¬? (governanceRefIndex (Supersession.previous s) ≟
      governanceRefIndex (Supersession.successor s))

SupersessionReady : History → Supersession → Set
SupersessionReady h s =
  SupersessionEndpointsValid h s ×
  SupersessionCoverage h s ×
  AllDispositionsValid h s ×
  EmbeddedEstablishmentsReady h s ×
  AllEstablishmentsUsed s

supersessionReady? :
  (h : History) → (s : Supersession) → Dec (SupersessionReady h s)
supersessionReady? h s =
  supersessionEndpointsValid? h s ×-dec
  supersessionCoverage? h s ×-dec
  allDispositionsValid? h s ×-dec
  embeddedEstablishmentsReady? h s ×-dec
  allEstablishmentsUsed? s

EntryReady : History → HistoryEntry → Set
EntryReady h (bootstrap genesis) = BootstrapValid h genesis
EntryReady h (declare d) = DeclarationValid h d
EntryReady h (propose d) = PropositionDeclarationValid h d
EntryReady h (establish e) = EstablishmentReady h e
EntryReady h (abandon p) = AbandonmentValid h p
EntryReady h (supersede s) = SupersessionReady h s

entryReady? :
  (h : History) → (entry : HistoryEntry) → Dec (EntryReady h entry)
entryReady? h (bootstrap genesis) = bootstrapValid? h genesis
entryReady? h (declare d) = declarationValid? h d
entryReady? h (propose d) = propositionDeclarationValid? h d
entryReady? h (establish e) = establishmentReady? h e
entryReady? h (abandon p) = abandonmentValid? h p
entryReady? h (supersede s) = supersessionReady? h s

EntryEvidence : History → HistoryEntry → Set
EntryEvidence h (bootstrap genesis) = ⊤
EntryEvidence h (declare d) = ⊤
EntryEvidence h (propose d) = ⊤
EntryEvidence h (establish e) = EvidenceAt h (establishmentIndex e)
EntryEvidence h (abandon p) = ⊤
EntryEvidence h (supersede s) = EmbeddedEstablishmentEvidence h s

ValidEntry : History → HistoryEntry → Set
ValidEntry h entry = EntryReady h entry × EntryEvidence h entry

data ValidHistory : History → Set₁ where
  empty : ValidHistory ε
  extend : {h : History} → ValidHistory h → (entry : HistoryEntry) →
           ValidEntry h entry → ValidHistory (h ▻ entry)

record Constitution : Set₁ where
  constructor constitution
  field
    history : History
    validHistory : ValidHistory history

Obligation : Constitution → Nat → Set
Obligation c p = Active (Constitution.history c) p

constitutionLifecycle : Constitution → Nat → GovernanceLifecycle
constitutionLifecycle c g = governanceLifecycle (Constitution.history c) g

constitutionSuccessor : Constitution → Nat → Maybe GovernanceRef
constitutionSuccessor c g = successorOf (Constitution.history c) g

constitutionGlyph : Constitution → Nat → GovernanceGlyph
constitutionGlyph c g = glyphForLifecycle (constitutionLifecycle c g)
