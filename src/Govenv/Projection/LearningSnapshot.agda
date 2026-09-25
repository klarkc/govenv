{-# OPTIONS --safe #-}

module Govenv.Projection.LearningSnapshot where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using
  (String; primShowNat; primShowString; primStringAppend)
open import Govenv.Kernel.Learning
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.LearningSnapshot using (materialization)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderBool : Bool → String
renderBool true = "true"
renderBool false = "false"

renderKind : CandidateKind → String
renderKind corrective = "corrective"
renderKind feature = "feature"
renderKind refactor = "refactor"
renderKind other = "other"

renderImpact : LearningImpact → String
renderImpact none = "none"
renderImpact reinforces = "reinforces"
renderImpact expands = "expands"

renderBypass : LearningBypass → String
renderBypass noBypass = "none"
renderBypass urgentCorrective = "urgent-corrective"

renderRequirements : LearningDebt → String
renderRequirements [] = ""
renderRequirements (learningRequirement claim sourceRevision ∷ rest) =
  "requirement " ++ primShowString claim ++ " " ++
  primShowString sourceRevision ++ "\n" ++
  renderRequirements rest

renderAssessment : CandidateLearningAssessment → String
renderAssessment
  (candidateLearningAssessment kind impact rationale requirements bypass reviewIndex) =
  "assessment-kind " ++ renderKind kind ++ "\n" ++
  "assessment-impact " ++ renderImpact impact ++ "\n" ++
  "assessment-bypass " ++ renderBypass bypass ++ "\n" ++
  "review-index " ++ primShowNat reviewIndex ++ "\n" ++
  "review-rationale " ++ primShowString rationale ++ "\n" ++
  renderRequirements requirements

renderLearningSnapshot : LearningSnapshot → String
renderLearningSnapshot
  (learningSnapshot debtClear candidateAllowed assessment) =
  "govenv-learning-snapshot-v2\n" ++
  "debt-clear " ++ renderBool debtClear ++ "\n" ++
  "candidate-allowed " ++ renderBool candidateAllowed ++ "\n" ++
  renderAssessment assessment

renderSnapshot : String
renderSnapshot = renderLearningSnapshot (state materialization)
