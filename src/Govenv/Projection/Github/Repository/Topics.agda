{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.Topics where

open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.Github.Repository.Topics using (materialization)

renderTopics : List String
renderTopics = state materialization
