{-# OPTIONS --safe #-}

module Govenv.Projection.LearningBootstrap where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Kernel.Learning using (LearningRequirement; debtClear)
open import Govenv.Learning using
  ( BootstrapLesson; bootstrapLesson; bootstrapLessons; carriedLessons
  ; evidence; requirementEvidenced; bootstrapComplete; outstanding )

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderBool : Bool → String
renderBool true = "complete"
renderBool false = "pending"

renderLesson : BootstrapLesson → String
renderLesson (bootstrapLesson key title context sources challenge requirement) =
  "\n" ++ title ++ "\n" ++
  "Key: " ++ key ++ "\n" ++
  "Status: " ++
    renderBool (requirementEvidenced requirement evidence) ++ "\n" ++
  "How we got here: " ++ context ++ "\n" ++
  "Sources: " ++ sources ++ "\n" ++
  "Challenge: " ++ challenge ++ "\n"

renderLessons : List BootstrapLesson → String
renderLessons [] = ""
renderLessons (lesson ∷ rest) =
  renderLesson lesson ++ renderLessons rest

renderBootstrap : String
renderBootstrap =
  "Govenv learning bootstrap\n" ++
  "Baseline: pre-GV122 governed frontier\n" ++
  "Historical baseline: " ++ renderBool bootstrapComplete ++ "\n" ++
  "Current learning frontier: " ++ renderBool (debtClear outstanding) ++ "\n" ++
  "Work in order. A tutor/agent may explain and ask the challenge, but only the human principal answers it.\n" ++
  "Record an answer with: govenv-learning answer <key>\n" ++
  "The command preserves the exact governed challenge and exact human response in Govenv.LearningEvidence; a normal reviewed PR is still required for authority.\n" ++
  "\nHistorical baseline\n" ++
  renderLessons bootstrapLessons ++
  "\nProspective catch-up\n" ++
  renderLessons carriedLessons
