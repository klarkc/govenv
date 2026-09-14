# Administrative setup plan

The administrative setup is modeled as the single future human-facing operation. Its ordered plan is governed state: adapters may interpret these steps, but they may not choose, omit, reorder, or introduce administrative effects independently.

This Stage D plan preserves the GV91 order established by Stage C: integrity first, authorization second, authority last. Only after those boundaries reach read-back equality may setup enable the repository Actions policy required by platform-issued candidate authorship. Candidate automation therefore becomes available only after `github-actions` is already unable to create semantic authority on `main`. The plan remains governed preparatory state until the single `setup` adapter can interpret it without introducing manual credential provisioning.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Administration.Setup where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)

data AdminSetupStep : Set where
  repositoryDescriptionStep : AdminSetupStep
  adminEnvironmentStep : AdminSetupStep
  materializerCredentialStep : AdminSetupStep
  materializerEnvironmentStep : AdminSetupStep
  authorizedEffectsEnvironmentStep : AdminSetupStep
  pagesEnvironmentStep : AdminSetupStep
  mainIntegrityRulesetStep : AdminSetupStep
  mainAuthorizationRulesetStep : AdminSetupStep
  mainAuthorityRulesetStep : AdminSetupStep
  actionsWorkflowPermissionsStep : AdminSetupStep

setupTarget : String
setupTarget = "setup"

plan : List AdminSetupStep
plan =
  adminEnvironmentStep
  ∷ repositoryDescriptionStep
  ∷ materializerCredentialStep
  ∷ materializerEnvironmentStep
  ∷ authorizedEffectsEnvironmentStep
  ∷ pagesEnvironmentStep
  ∷ mainIntegrityRulesetStep
  ∷ mainAuthorizationRulesetStep
  ∷ mainAuthorityRulesetStep
  ∷ actionsWorkflowPermissionsStep
  ∷ []
```
