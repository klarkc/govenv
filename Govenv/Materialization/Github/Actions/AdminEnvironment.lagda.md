# Administrative materialization environment

The administrative credential boundary admits only `main`. It exposes only the governed administrative token name; the token value itself remains external.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Actions.AdminEnvironment where

open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Administration using
  (adminEnvironment; adminTokenSecret; authorizedBranch)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Actions.Environment

state : EnvironmentBoundaryState
state = environmentBoundaryState
  adminEnvironment
  (customBranches (authorizedBranch ∷ []))
  noDeploymentReview
  (adminTokenSecret ∷ [])
  []

materialization : Materialization EnvironmentBoundaryState
materialization = materialized
  (githubActionsEnvironment adminEnvironment)
  adminApplication
  adminPrivilege
  adminAuthority
  environmentBoundaryReadBackEquality
  state
```
