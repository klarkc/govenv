# Authorized materializer environment

The materializer credential boundary admits only `main`. Its repository credential is provisioned by the governed administrative setup. Governance owns the credential identity, placement, and access policy rather than manually supplied runtime values.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Actions.MaterializerEnvironment where

open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Administration using
  (materializerEnvironment; materializerBranch; materializerCredentialName)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Actions.Environment

state : EnvironmentBoundaryState
state = environmentBoundaryState
  materializerEnvironment
  (customBranches (materializerBranch ∷ []))
  noDeploymentReview
  (materializerCredentialName ∷ [])
  []

materialization : Materialization EnvironmentBoundaryState
materialization = materialized
  (githubActionsEnvironment materializerEnvironment)
  adminApplication
  adminPrivilege
  adminAuthority
  environmentBoundaryReadBackEquality
  state
```
