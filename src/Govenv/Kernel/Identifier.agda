{-# OPTIONS --safe #-}

module Govenv.Kernel.Identifier where

open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)

data IdentifierKind : Set where
  Phase Governance : IdentifierKind

data Identifier (kind : IdentifierKind) : Nat → String → Set where
  identifier :
    (idx : Nat) →
    (description : String) →
    Identifier kind idx description

PhaseId : Nat → String → Set
PhaseId = Identifier Phase

GovernanceId : Nat → String → Set
GovernanceId = Identifier Governance
P : (idx : Nat) → (description : String) → PhaseId idx description
P = identifier

GV : (idx : Nat) → (description : String) → GovernanceId idx description
GV = identifier

indexOf :
  {kind : IdentifierKind} {idx : Nat} {description : String} →
  Identifier kind idx description → Nat
indexOf {idx = idx} _ = idx

descriptionOf :
  {kind : IdentifierKind} {idx : Nat} {description : String} →
  Identifier kind idx description → String
descriptionOf {description = description} _ = description

record SomeIdentifier (kind : IdentifierKind) : Set where
  constructor someIdentifier
  field
    {idx} : Nat
    {description} : String
    value : Identifier kind idx description

SomePhaseId : Set
SomePhaseId = SomeIdentifier Phase

SomeGovernanceId : Set
SomeGovernanceId = SomeIdentifier Governance

record IdentifierRef (kind : IdentifierKind) : Set where
  constructor identifierRef
  field
    referenceIndex : Nat

GovernanceRef : Set
GovernanceRef = IdentifierRef Governance

GVR : Nat → GovernanceRef
GVR = identifierRef
