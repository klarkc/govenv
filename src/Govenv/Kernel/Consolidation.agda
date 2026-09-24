{-# OPTIONS --safe #-}

module Govenv.Kernel.Consolidation where

open import Agda.Builtin.List using (List)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Roadmap using (Roadmap; GovernanceTarget)

record SourceArtifact : Set where
  constructor sourceArtifact
  field
    path : String
    sha256 : String
    note : String

record Corpus (Observation : Set) : Set where
  constructor corpus
  field
    corpusId : String
    recoveryRevision : String
    sources : List SourceArtifact
    describe : Observation → String

data Representation (roadmap : Roadmap) : Set where
  governance :
    GovernanceTarget roadmap →
    String →
    Representation roadmap
  protocol :
    String →
    String →
    Representation roadmap
  architecture :
    String →
    String →
    Representation roadmap
  assurance :
    Nat →
    String →
    Representation roadmap

data Disposition (roadmap : Roadmap) : Set where
  representedBy :
    Representation roadmap →
    Disposition roadmap
  supersededBy :
    GovernanceTarget roadmap →
    String →
    Disposition roadmap
  rejectedBecause :
    String →
    Disposition roadmap
  irrelevantBecause :
    String →
    Disposition roadmap

record Consolidation
  (Observation : Set)
  (roadmap : Roadmap)
  (declared : Corpus Observation)
  : Set where
  constructor consolidated
  field
    disposition : Observation → Disposition roadmap

record DeclaredConsolidation (roadmap : Roadmap) : Set₁ where
  constructor declaredConsolidation
  field
    Observation : Set
    declared : Corpus Observation
    closure : Consolidation Observation roadmap declared
