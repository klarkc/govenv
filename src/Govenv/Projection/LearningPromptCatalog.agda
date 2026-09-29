{-# OPTIONS --safe #-}

module Govenv.Projection.LearningPromptCatalog where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Kernel.Learning using (LearningRequirement)
open import Govenv.Learning using
  (BootstrapLesson; bootstrapLesson; allLearningPrompts; reviewContract)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderPrompt : BootstrapLesson → String
renderPrompt lesson@(bootstrapLesson key title context sources reviewSurface semanticProbe codeProbe assuranceProbe requirement) =
  key ++ "\t" ++
  LearningRequirement.claim requirement ++ "\t" ++
  LearningRequirement.sourceRevision requirement ++ "\t" ++
  reviewSurface ++ "\t" ++
  semanticProbe ++ "\t" ++
  codeProbe ++ "\t" ++
  assuranceProbe ++ "\t" ++
  reviewContract lesson ++ "\n"

renderPrompts : List BootstrapLesson → String
renderPrompts [] = ""
renderPrompts (prompt ∷ rest) =
  renderPrompt prompt ++ renderPrompts rest

renderCatalog : String
renderCatalog = renderPrompts allLearningPrompts
