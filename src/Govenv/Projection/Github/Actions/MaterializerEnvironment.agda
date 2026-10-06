{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Actions.MaterializerEnvironment where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization.Github.Actions.MaterializerEnvironment using (state)
open import Govenv.Projection.Github.Actions.Environment using (EnvironmentProjection; projectEnvironment; renderEnvironmentPlan)

renderPlan : String
renderPlan = renderEnvironmentPlan state

plan : EnvironmentProjection
plan = projectEnvironment state
