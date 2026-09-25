{-# OPTIONS --safe #-}

module Govenv.Projection.ProjectPurposeSnapshot where

open import Agda.Builtin.String using
  (String; primShowNat; primShowString; primStringAppend)
open import Govenv.Kernel.ProjectPurpose using
  (ProjectPurposeSnapshot; projectPurposeSnapshot)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.ProjectPurposeSnapshot using
  (materialization)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderProjectPurposeSnapshot : ProjectPurposeSnapshot → String
renderProjectPurposeSnapshot
  (projectPurposeSnapshot purpose reviewRationale reviewIndex) =
  "govenv-project-purpose-snapshot-v2\n" ++
  "review-index " ++ primShowNat reviewIndex ++ "\n" ++
  "review-rationale " ++ primShowString reviewRationale ++ "\n" ++
  "purpose " ++ primShowString purpose ++ "\n"

renderSnapshot : String
renderSnapshot = renderProjectPurposeSnapshot (state materialization)
