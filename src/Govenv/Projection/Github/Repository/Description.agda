{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.Description where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.Github.Repository.Description using (materialization)

renderDescription : String
renderDescription = state materialization
