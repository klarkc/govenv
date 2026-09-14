# GitHub main integrity ruleset

The default-branch integrity ruleset protects properties that even the materializer must not bypass. It has no bypass actor: both human merges and deterministic materialization pushes must remain non-destructive fast-forward updates.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.MainIntegrity where

open import Agda.Builtin.Bool using (Bool; true)
open import Agda.Builtin.String using (String)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Repository.Ruleset

record MainIntegrityRuleset : Set where
  constructor mainIntegrityRuleset
  field
    name : String
    enforcement : Enforcement
    target : BranchTarget
    blockDeletion : Bool
    blockForcePush : Bool

rulesetName : String
rulesetName = "govenv-main-integrity"

state : MainIntegrityRuleset
state = mainIntegrityRuleset
  rulesetName
  active
  defaultBranch
  true
  true

materialization : Materialization MainIntegrityRuleset
materialization = materialized
  (githubRepositoryRuleset rulesetName)
  adminApplication
  adminPrivilege
  adminAuthority
  rulesetReadBackEquality
  state
```
