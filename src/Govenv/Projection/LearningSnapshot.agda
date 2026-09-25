{-# OPTIONS --safe #-}

module Govenv.Projection.LearningSnapshot where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.LearningSnapshot using (materialization)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderBool : Bool → String
renderBool true = "true"
renderBool false = "false"

renderSnapshot : String
renderSnapshot =
  "govenv-learning-snapshot-v1\n" ++
  "debt-clear " ++ renderBool (state materialization) ++ "\n"
