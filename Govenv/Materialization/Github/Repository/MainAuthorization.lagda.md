# GitHub main authorization ruleset

The default-branch authorization ruleset projects the AuthorizedRevision boundary into GitHub. Normal principals must update the default branch through a pull request; only the dedicated materializer App may bypass this authorization ruleset to apply deterministic effects already authorized by a human merge.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.MainAuthorization where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Nat using (zero)
open import Agda.Builtin.String using (String)
open import Govenv.Administration using (materializerAppSlug)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Repository.Ruleset

record MainAuthorizationRuleset : Set where
  constructor mainAuthorizationRuleset
  field
    name : String
    enforcement : Enforcement
    target : BranchTarget
    bypass : GithubAppBypass
    pullRequest : PullRequestRequirement
    statusChecks : StatusChecksRequirement

rulesetName : String
rulesetName = "govenv-main-authorization"

testCheck : String
testCheck = "test"

testSourceApp : String
testSourceApp = "github-actions"

state : MainAuthorizationRuleset
state = mainAuthorizationRuleset
  rulesetName
  active
  defaultBranch
  (githubAppBypass materializerAppSlug always)
  (pullRequestRequirement
    (rebase ∷ [])
    false
    false
    false
    zero
    false)
  (statusChecksRequirement
    (requiredStatusCheck testCheck testSourceApp ∷ [])
    true
    false)

materialization : Materialization MainAuthorizationRuleset
materialization = materialized
  (githubRepositoryRuleset rulesetName)
  adminApplication
  adminPrivilege
  adminAuthority
  rulesetReadBackEquality
  state
```
