# Administrative setup plan

The administrative setup is modeled as the single future human-facing operation. Its ordered plan is governed state: adapters may interpret these steps, but they may not choose, omit, reorder, or introduce administrative effects independently.

The current plan prepares every prerequisite that is sound before main-ruleset activation. GV91 intentionally keeps the three main rulesets out of this revision's setup plan until the authorized Stage B execution path exists. This plan is governed preparatory state; the legacy multi-target workflow remains materialized until a complete adapter can interpret the plan without introducing manual credential provisioning.

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
  ∷ []
```
