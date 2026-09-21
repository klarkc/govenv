{-# OPTIONS --safe #-}

module Govenv.Projection.Agents where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.Agents using (materialization)

renderAgents : String
renderAgents = state materialization
