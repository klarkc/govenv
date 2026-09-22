# Governance

Governance is Govenv's constitutional normative domain. It describes repository
or system states, transitions, effects, and semantic properties whose validity
is independent of which contributor or agent produced them.

Governance is distinct from protocol: two contributors may follow
different valid processes and still produce the same constitutionally valid
state. Operational guidance therefore does not become governance merely because
Govenv publishes it.

The governed roadmap is the canonical typed inventory of governance decisions.

Project concerns are partitioned by semantic authority rather than by implementation
location. A constitutional subject is always Governance; contributor or agent
process is Protocol; and the irreducible outer boundary is limited to observing,
applying, or verifying effects. The effect boundary has no constructor for
semantic policy or authority.

This taxonomy classifies kinds of concerns. GV98 separately classifies concrete
Agda declarations by reflected identity and must not derive architecture from
this classification.

```agda
{-# OPTIONS --safe #-}

module Govenv.Governance where

open import Govenv.Kernel.Roadmap using (Roadmap)
open import Govenv.Roadmap using (roadmap)

data ConstitutionalSubject : Set where
  repositoryState : ConstitutionalSubject
  repositoryTransition : ConstitutionalSubject
  persistentEffect : ConstitutionalSubject
  authorization : ConstitutionalSubject
  semanticOutput : ConstitutionalSubject

data ProcessSubject : Set where
  contributorProcess : ProcessSubject
  agentProcess : ProcessSubject

data BoundaryOperation : Set where
  observe : BoundaryOperation
  apply : BoundaryOperation
  verify : BoundaryOperation

data Domain : Set where
  governanceDomain : Domain
  protocolDomain : Domain
  effectBoundaryDomain : Domain

data Concern : Set where
  constitutional : ConstitutionalSubject → Concern
  process : ProcessSubject → Concern
  boundary : BoundaryOperation → Concern

domainOf : Concern → Domain
domainOf (constitutional subject) = governanceDomain
domainOf (process subject) = protocolDomain
domainOf (boundary operation) = effectBoundaryDomain

governance : Roadmap
governance = roadmap
```
