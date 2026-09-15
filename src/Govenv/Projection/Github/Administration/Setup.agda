{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Administration.Setup where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)
open import Govenv.Materialization.Github.Administration.Setup

projectStep : AdminSetupStep → String
projectStep repositoryDescriptionStep = ".govenv/admin-apply-build/DescriptionApplication"
projectStep adminEnvironmentStep = ".govenv/admin-apply-build/AdminEnvironment"
projectStep materializerEnvironmentBoundaryStep =
  ".govenv/admin-apply-build/MaterializerEnvironmentBoundary"
projectStep materializerCredentialStep =
  ".govenv/admin-apply-build/MaterializerCredential"
projectStep materializerEnvironmentStep =
  ".govenv/admin-apply-build/MaterializerEnvironment"
projectStep authorizedEffectsEnvironmentStep =
  ".govenv/admin-apply-build/AuthorizedEffectsEnvironment"
projectStep pagesEnvironmentStep =
  ".govenv/admin-apply-build/PagesEnvironment"

projectPlan : List AdminSetupStep → List String
projectPlan [] = []
projectPlan (step ∷ rest) = projectStep step ∷ projectPlan rest

steps : List String
steps = projectPlan plan
