{-# OPTIONS --safe #-}

module Govenv.Projection.LearningBootstrap where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Kernel.Learning using (debtClear)
open import Govenv.Learning using
  ( BootstrapLesson; bootstrapLesson; bootstrapLessons; carriedLessons
  ; evidence; lessonEvidenced; bootstrapComplete; outstanding )

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderBool : Bool → String
renderBool true = "complete"
renderBool false = "pending"

renderLesson : BootstrapLesson → String
renderLesson lesson@(bootstrapLesson key title context sources reviewSurface semanticProbe codeProbe assuranceProbe requirement) =
  "\n" ++ title ++ "\n" ++
  "Key: " ++ key ++ "\n" ++
  "Status: " ++ renderBool (lessonEvidenced lesson evidence) ++ "\n" ++
  "How we got here: " ++ context ++ "\n" ++
  "Sources: " ++ sources ++ "\n" ++
  "Review surface: " ++ reviewSurface ++ "\n" ++
  "Semantic probe: " ++ semanticProbe ++ "\n" ++
  "Code probe: " ++ codeProbe ++ "\n" ++
  "Assurance probe: " ++ assuranceProbe ++ "\n"

renderLessons : List BootstrapLesson → String
renderLessons [] = ""
renderLessons (lesson ∷ rest) =
  renderLesson lesson ++ renderLessons rest

renderBootstrap : String
renderBootstrap =
  "Govenv learning bootstrap\n" ++
  "Baseline: pre-GV122 governed frontier plus prospective carried lessons\n" ++
  "Historical baseline: " ++ renderBool bootstrapComplete ++ "\n" ++
  "Current learning frontier: " ++ renderBool (debtClear outstanding) ++ "\n" ++
  "Work in order. Review the semantically load-bearing code and assurance surface before answering. A tutor or agent may explain and ask probes, but only the human principal answers them.\n" ++
  "Record an answer with: govenv-learning answer <key>\n" ++
  "Evidence is bound to the current review contract (surface + semantic/code/assurance probes); changing that contract makes older evidence stale. A normal reviewed PR is still required for authority.\n" ++
  "\nHistorical baseline\n" ++
  renderLessons bootstrapLessons ++
  "\nProspective catch-up\n" ++
  renderLessons carriedLessons
