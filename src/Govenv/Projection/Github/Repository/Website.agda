{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.Website where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.Github.Repository.Website using (materialization)

renderWebsite : String
renderWebsite = state materialization
