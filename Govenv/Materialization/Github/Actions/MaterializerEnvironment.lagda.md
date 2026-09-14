# Authorized materializer environment

The materializer credential boundary admits only `main`. The App private-key and public client-ID values remain external; governance owns the required credential names and access policy, never the credential values themselves.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Actions.MaterializerEnvironment where

open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Administration using
  (materializerEnvironment; materializerBranch; materializerPrivateKeySecret; materializerClientIdVariable)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Actions.Environment

state : EnvironmentBoundaryState
state = environmentBoundaryState
  materializerEnvironment
  (customBranches (materializerBranch ∷ []))
  noDeploymentReview
  (materializerPrivateKeySecret ∷ [])
  (materializerClientIdVariable ∷ [])

materialization : Materialization EnvironmentBoundaryState
materialization = materialized
  (githubActionsEnvironment materializerEnvironment)
  adminApplication
  adminPrivilege
  adminAuthority
  environmentBoundaryReadBackEquality
  state
```
