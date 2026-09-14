# GitHub Pages deployment environment

The Pages deployment environment admits only `main`. It carries no repository credential; its branch policy prevents publication from an untrusted candidate ref.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Actions.PagesEnvironment where

open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Administration using (pagesEnvironment; authorizedBranch)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Actions.Environment

state : EnvironmentBoundaryState
state = environmentBoundaryState
  pagesEnvironment
  (customBranches (authorizedBranch ∷ []))
  noDeploymentReview
  []
  []

materialization : Materialization EnvironmentBoundaryState
materialization = materialized
  (githubActionsEnvironment pagesEnvironment)
  adminApplication
  adminPrivilege
  adminAuthority
  environmentBoundaryReadBackEquality
  state
```
