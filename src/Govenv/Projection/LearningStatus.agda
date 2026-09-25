{-# OPTIONS --safe #-}

module Govenv.Projection.LearningStatus where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Kernel.Learning using
  (LearningRequirement; LearningDebt; learningRequirement)
open import Govenv.Learning using (outstanding)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderRequirements : LearningDebt → String
renderRequirements [] = "Learning debt: clear\n"
renderRequirements (learningRequirement claim revision ∷ rest) =
  "Learning debt: open\n- " ++ claim ++ " @ " ++ revision ++ "\n" ++
  renderRequirements rest

renderStatus : String
renderStatus = renderRequirements outstanding
