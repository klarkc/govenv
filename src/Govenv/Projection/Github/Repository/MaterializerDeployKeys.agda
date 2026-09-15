{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.MaterializerDeployKeys where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.String using (String)
open import Govenv.Materialization.Github.Repository.DeployKeys using (DeployKeyState; title; writable)
open import Govenv.Materialization.Github.Repository.MaterializerDeployKeys using (materializerKey; state)
open import Govenv.Projection.Github.Repository.DeployKeys using (renderDeployKeySet)

renderPlan : String
renderPlan = renderDeployKeySet state

materializerTitle : String
materializerTitle = DeployKeyState.title materializerKey

materializerReadOnly : String
materializerReadOnly with DeployKeyState.writable materializerKey
... | true = "false"
... | false = "true"
