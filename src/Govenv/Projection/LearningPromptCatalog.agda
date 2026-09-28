{-# OPTIONS --safe #-}

module Govenv.Projection.LearningPromptCatalog where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Kernel.Learning using (LearningRequirement)
open import Govenv.Learning using
  (BootstrapLesson; bootstrapLesson; allLearningPrompts)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderPrompt : BootstrapLesson → String
renderPrompt (bootstrapLesson key title context sources challenge requirement) =
  key ++ "\t" ++
  LearningRequirement.claim requirement ++ "\t" ++
  LearningRequirement.sourceRevision requirement ++ "\t" ++
  challenge ++ "\n"

renderPrompts : List BootstrapLesson → String
renderPrompts [] = ""
renderPrompts (prompt ∷ rest) =
  renderPrompt prompt ++ renderPrompts rest

renderCatalog : String
renderCatalog = renderPrompts allLearningPrompts
