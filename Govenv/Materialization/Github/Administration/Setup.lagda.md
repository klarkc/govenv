# Administrative setup plan

The administrative setup is the single human-facing bootstrap/recovery operation. Its ordered plan is governed authority state: adapters may interpret these steps, but they may not choose, omit, reorder, or introduce administrative effects independently. Ordinary project-state materializations, including repository metadata, do not belong to this setup.

The current plan prepares every prerequisite that is sound before main-ruleset activation. GV91 intentionally keeps the three main rulesets out of this revision's setup plan until the authorized Stage B execution path exists. The materializer environment boundary is applied before cryptographic material is provisioned, so the private key is never introduced into an unrestricted environment. The final materializer-environment step performs complete read-back after credential provisioning.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Administration.Setup where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)

data AdminSetupStep : Set where
  adminEnvironmentStep : AdminSetupStep
  materializerEnvironmentBoundaryStep : AdminSetupStep
  materializerCredentialStep : AdminSetupStep
  materializerEnvironmentStep : AdminSetupStep
  authorizedEffectsEnvironmentStep : AdminSetupStep
  pagesEnvironmentStep : AdminSetupStep

setupTarget : String
setupTarget = "setup"

plan : List AdminSetupStep
plan =
  adminEnvironmentStep
  ∷ materializerEnvironmentBoundaryStep
  ∷ materializerCredentialStep
  ∷ materializerEnvironmentStep
  ∷ authorizedEffectsEnvironmentStep
  ∷ pagesEnvironmentStep
  ∷ []
```
