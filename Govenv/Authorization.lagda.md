# Authorization

Authorization models the trust boundary between candidate repository states and governed effects. A candidate becomes authoritative only through an explicit human pull-request merge; later repository revisions and external effects may retain that authority only as derived outcomes with causal provenance to the accepted revision.

```agda
{-# OPTIONS --safe #-}

module Govenv.Authorization where

open import Agda.Builtin.Equality using (_≡_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)

record Revision : Set where
  constructor identifiedRevision
  field
    identifier : String

data PrincipalKind : Set where
  human machine : PrincipalKind

record Principal : Set where
  constructor observedPrincipal
  field
    identity : String
    kind : PrincipalKind

record HumanPrincipal : Set where
  constructor humanPrincipal
  field
    principal : Principal
    isHuman : Principal.kind principal ≡ human

record HumanPullRequestMerge : Set where
  constructor humanPullRequestMerge
  field
    pullRequest : Nat
    principal : HumanPrincipal
    acceptedRevision : Revision

record AuthorizedRevision : Set where
  constructor authorizedRevision
  field
    authorization : HumanPullRequestMerge

revisionOf : AuthorizedRevision → Revision
revisionOf authorized =
  HumanPullRequestMerge.acceptedRevision
    (AuthorizedRevision.authorization authorized)

record DerivedRevision : Set where
  constructor derivedRevision
  field
    revision : Revision
    authorizedBy : AuthorizedRevision

record DerivedEffect (Effect : Set) : Set where
  constructor derivedEffect
  field
    effect : Effect
    authorizedBy : AuthorizedRevision
```
