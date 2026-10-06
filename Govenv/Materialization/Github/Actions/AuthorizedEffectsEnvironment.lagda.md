# Authorized external-effects environment

Privileged publication jobs that need no persistent credential still require an execution boundary: they may run only from `main`, after human authorization. This environment carries no secret material; its branch policy is the capability gate.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Actions.AuthorizedEffectsEnvironment where

open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Administration using
  (authorizedEffectsEnvironment; authorizedBranch)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Actions.Environment

state : EnvironmentBoundaryState
state = environmentBoundaryState
  authorizedEffectsEnvironment
  (customBranches (authorizedBranch ∷ []))
  noDeploymentReview
  []
  []

materialization : Materialization EnvironmentBoundaryState
materialization = materialized
  (githubActionsEnvironment authorizedEffectsEnvironment)
  adminApplication
  adminPrivilege
  adminAuthority
  environmentBoundaryReadBackEquality
  state
```
