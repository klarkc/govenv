{-# OPTIONS --safe #-}

module Govenv.Projection.DirectionReviewSnapshot where

open import Agda.Builtin.String using
  (String; primShowNat; primShowString; primStringAppend)
open import Govenv.Kernel.DirectionReview using
  (DirectionReviewSnapshot; directionReviewSnapshot)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.DirectionReviewSnapshot using (materialization)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderDirectionReviewSnapshot : DirectionReviewSnapshot → String
renderDirectionReviewSnapshot
  (directionReviewSnapshot reviewIndex reviewRationale current next) =
  "govenv-direction-review-snapshot-v2\n" ++
  "review-index " ++ primShowNat reviewIndex ++ "\n" ++
  "review-rationale " ++ primShowString reviewRationale ++ "\n" ++
  "current " ++ primShowString current ++ "\n" ++
  "next " ++ primShowString next ++ "\n"

renderSnapshot : String
renderSnapshot = renderDirectionReviewSnapshot (state materialization)
