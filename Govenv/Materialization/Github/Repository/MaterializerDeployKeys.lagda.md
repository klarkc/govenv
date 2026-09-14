# Materializer deploy-key set

GV93 closes the repository deploy-key class to one governed materializer credential. Any additional repository deploy key is therefore drift, not an independent authority source.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.MaterializerDeployKeys where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Administration using (materializerDeployKeyTitle)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Repository.DeployKeys

materializerKey : DeployKeyState
materializerKey = deployKeyState materializerDeployKeyTitle true

state : DeployKeySet
state = deployKeySet (materializerKey ∷ [])

materialization : Materialization DeployKeySet
materialization = materialized
  githubRepositoryDeployKeys
  adminApplication
  adminPrivilege
  adminAuthority
  deployKeySetReadBackEquality
  state
```
