# GitHub Actions environment boundary

GitHub Actions environments are privileged execution boundaries. Governance owns their observable access policy and the exact names of credentials visible through the boundary; secret values remain irreducibly external and are never constitutional data.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Actions.Environment where

open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)

data DeploymentBranchPolicy : Set where
  customBranches : List String → DeploymentBranchPolicy

data DeploymentReviewPolicy : Set where
  noDeploymentReview : DeploymentReviewPolicy

record EnvironmentBoundaryState : Set where
  constructor environmentBoundaryState
  field
    name : String
    branchPolicy : DeploymentBranchPolicy
    reviewPolicy : DeploymentReviewPolicy
    secretNames : List String
    variableNames : List String
```
