# Administrative setup plan

The administrative setup is modeled as the single future human-facing operation. Its ordered plan is governed state: adapters may interpret these steps, but they may not choose, omit, reorder, or introduce administrative effects independently.

This Stage C plan extends the prerequisite setup only after the Stage B execution path is present in an `AuthorizedRevision`. It activates the main rulesets monotonically in the GV91 order: integrity first, authorization second, authority last. Each step must reach read-back equality before the following step may execute. The plan remains governed preparatory state until the single `setup` adapter can interpret it without introducing manual credential provisioning.

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
  ∷ []
```
