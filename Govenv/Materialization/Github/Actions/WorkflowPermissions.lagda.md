# GitHub Actions workflow permissions

Candidate authoring uses no manually provisioned credential. GitHub emits its `GITHUB_TOKEN`, while repository Actions policy controls whether that token may create pull requests. GitHub couples pull-request creation and review approval in one repository setting; enabling that platform capability does not create Govenv authorization. Under GV90, only an explicit human merge creates an `AuthorizedRevision`, and Stage C prevents the `github-actions` principal from updating `main`.

The repository default remains read-only. Individual governed jobs must request any write capability explicitly. Pull requests created or updated by `GITHUB_TOKEN` enter GitHub's approval-required validation state; allowing those unprivileged validation runs is distinct from the human merge that creates an `AuthorizedRevision`.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Actions.WorkflowPermissions where

open import Agda.Builtin.Bool using (Bool; true)
open import Govenv.Materialization

data DefaultWorkflowPermission : Set where
  readDefault : DefaultWorkflowPermission

record WorkflowPermissionsState : Set where
  constructor workflowPermissionsState
  field
    defaultPermission : DefaultWorkflowPermission
    allowPullRequestCreationAndApproval : Bool

state : WorkflowPermissionsState
state = workflowPermissionsState readDefault true

materialization : Materialization WorkflowPermissionsState
materialization = materialized
  githubActionsWorkflowPermissions
  adminApplication
  adminPrivilege
  adminAuthority
  actionsWorkflowPermissionsReadBackEquality
  state
```
