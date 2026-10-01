# Authorization

Authorization models the trust boundary between candidate repository states and governed effects. Human review may compose one candidate into another candidate, but only a human pull-request merge into the governed authorization target creates semantic authority. Later repository revisions and external effects may retain that authority only as derived outcomes with causal provenance to the accepted authorized revision.

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

data PullRequestTarget : Set where
  candidateTarget authorizedTarget : PullRequestTarget

record HumanPullRequestMerge : Set where
  constructor humanPullRequestMerge
  field
    pullRequest : Nat
    principal : HumanPrincipal
    acceptedRevision : Revision
    target : PullRequestTarget

record AuthorizedRevision : Set where
  constructor authorizedRevision
  field
    authorization : HumanPullRequestMerge
    targetIsAuthorized :
      HumanPullRequestMerge.target authorization ≡ authorizedTarget

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
