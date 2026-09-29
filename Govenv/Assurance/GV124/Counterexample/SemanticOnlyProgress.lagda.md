# GV124 semantic-only learning progress counterexample

During the first real from-zero catch-up after GV123, the principal answered the
`purpose` semantic challenge and the candidate learning state moved from 12 to
11 outstanding lessons without reviewing the semantically load-bearing code or
the assurance carrying that guarantee. The recorded response was legitimate
human evidence under the old mechanism, but the mechanism matched only the
learning requirement (`claim` plus source revision), so it could report progress
before the principal had exercised code-review literacy.

GV124 preserves that observation as an assurance counterexample. Requirement-
only matching still demonstrates why the old path accepted the evidence, while
the current lesson-aware boundary rejects the same evidence because its review
contract does not match the lesson's current review surface and semantic, code,
and assurance probes.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV124.Counterexample.SemanticOnlyProgress where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Govenv.Kernel.Learning using (LearningRequirement)
open import Govenv.Learning using
  (lessonEvidenced; purposeLesson; purposeRequirement; reviewContract; sameRequirement)
open import Govenv.LearningEvidence using
  (DemonstratedLearning; demonstratedLearning; claimedHumanPrincipal)

semanticOnlyEvidence : DemonstratedLearning
semanticOnlyEvidence =
  demonstratedLearning
    purposeRequirement
    (claimedHumanPrincipal "counterexample-principal")
    "Semantic-only purpose challenge; no code or assurance review contract."
    "A human-produced semantic answer."

legacyRequirementEvidenced :
  LearningRequirement →
  List DemonstratedLearning →
  Bool
legacyRequirementEvidenced requirement [] = false
legacyRequirementEvidenced requirement (candidate ∷ rest)
  with sameRequirement requirement (DemonstratedLearning.requirement candidate)
... | true = true
... | false = legacyRequirementEvidenced requirement rest

legacyRequirementOnlyAccepted :
  legacyRequirementEvidenced purposeRequirement (semanticOnlyEvidence ∷ []) ≡ true
legacyRequirementOnlyAccepted = refl

reviewContractBoundaryRejectsSemanticOnly :
  lessonEvidenced purposeLesson (semanticOnlyEvidence ∷ []) ≡ false
reviewContractBoundaryRejectsSemanticOnly = refl

contractMatchedEvidence : DemonstratedLearning
contractMatchedEvidence =
  demonstratedLearning
    purposeRequirement
    (claimedHumanPrincipal "counterexample-principal")
    (reviewContract purposeLesson)
    "A human-produced response under the exact current review contract."

exactReviewContractRemainsReachable :
  lessonEvidenced purposeLesson (contractMatchedEvidence ∷ []) ≡ true
exactReviewContractRemainsReachable = refl
```

[executed on device: solo098 (ee17d3e4-8041-4f18-9fe7-4f36099458e3)]