# GitHub main authority boundary

The authority-boundary ruleset prevents machine credentials with generic repository write access from creating new semantic authority. The governed human principal may update the default branch only through a pull request; the governed materializer credential class may update it directly only for derived materialization effects. GV93 closes that class to the single materializer credential.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.MainAuthorityBoundary where

open import Agda.Builtin.Bool using (false)
open import Agda.Builtin.String using (String)
open import Govenv.Administration using
  (authorizationHumanLogin)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Repository.Ruleset

record MainAuthorityBoundaryRuleset : Set where
  constructor mainAuthorityBoundaryRuleset
  field
    name : String
    enforcement : Enforcement
    target : BranchTarget
    humanBypass : GithubUserBypass
    materializerBypass : DeployKeyBypass
    update : UpdateRestriction

rulesetName : String
rulesetName = "govenv-main-authority"

state : MainAuthorityBoundaryRuleset
state = mainAuthorityBoundaryRuleset
  rulesetName
  active
  defaultBranch
  (githubUserBypass authorizationHumanLogin pullRequestOnly)
  (deployKeyBypass always)
  (updateRestriction false)

materialization : Materialization MainAuthorityBoundaryRuleset
materialization = materialized
  (githubRepositoryRuleset rulesetName)
  adminApplication
  adminPrivilege
  adminAuthority
  rulesetReadBackEquality
  state
```
