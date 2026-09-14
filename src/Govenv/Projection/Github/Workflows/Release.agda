{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Workflows.Release where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization.Github.Workflows.Release using (state)
open import Govenv.Projection.Github.Workflows.Workflow using (renderWorkflow)

render : String
render = renderWorkflow state
