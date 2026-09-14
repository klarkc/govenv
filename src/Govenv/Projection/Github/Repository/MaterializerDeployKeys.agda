{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.MaterializerDeployKeys where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization.Github.Repository.MaterializerDeployKeys using (state)
open import Govenv.Projection.Github.Repository.DeployKeys using (renderDeployKeySet)

renderPlan : String
renderPlan = renderDeployKeySet state
