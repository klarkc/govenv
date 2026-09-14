# GitHub repository ruleset vocabulary

This module defines the governed semantic vocabulary shared by repository ruleset materializations. API-specific identifiers and JSON encoding remain projection/adapter concerns.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.Ruleset where

open import Agda.Builtin.Bool using (Bool)
open import Agda.Builtin.List using (List)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)

data Enforcement : Set where
  active : Enforcement

data BranchTarget : Set where
  defaultBranch : BranchTarget

data BypassMode : Set where
  always pullRequestOnly : BypassMode

data MergeMethod : Set where
  rebase : MergeMethod

record DeployKeyBypass : Set where
  constructor deployKeyBypass
  field
    mode : BypassMode

record GithubUserBypass : Set where
  constructor githubUserBypass
  field
    login : String
    mode : BypassMode

record UpdateRestriction : Set where
  constructor updateRestriction
  field
    allowFetchAndMerge : Bool

record PullRequestRequirement : Set where
  constructor pullRequestRequirement
  field
    allowedMergeMethods : List MergeMethod
    dismissStaleReviewsOnPush : Bool
    requireCodeOwnerReview : Bool
    requireLastPushApproval : Bool
    requiredApprovingReviewCount : Nat
    requiredReviewThreadResolution : Bool

record RequiredStatusCheck : Set where
  constructor requiredStatusCheck
  field
    context : String
    sourceApp : String

record StatusChecksRequirement : Set where
  constructor statusChecksRequirement
  field
    checks : List RequiredStatusCheck
    strict : Bool
    doNotEnforceOnCreate : Bool
```
