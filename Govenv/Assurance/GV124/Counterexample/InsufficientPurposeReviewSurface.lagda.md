# GV124 insufficient purpose review-surface counterexample

An independent catch-up test of PR #64 exercised the `purpose` lesson exactly as
a human reviewer would. The declared review surface was not sufficient to answer
the lesson's own code and assurance probes. The tutor had to leave the bound
contract and inspect `Govenv.Kernel.Protocol`,
`Govenv.Adapter.PurposeVigilance`, the roadmap-evolution adapter, and the
concrete README materialization equality check before the principal could
correctly interpret the vigilance booleans and distinguish compiler proof from
Adapter/CI observation.

This is a Protocol/pedagogy counterexample rather than a proof that Agda can
decide review-surface quality. The machine-checkable closure is narrower: the
observed insufficient contract is preserved as a fixture, the current lesson
contract is changed to include the missing load-bearing path, and evidence bound
to the observed insufficient contract becomes stale.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV124.Counterexample.InsufficientPurposeReviewSurface where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Learning using
  ( BootstrapLesson; bootstrapLesson; lessonEvidenced; purposeLesson
  ; purposeRequirement; reviewContract )
open import Govenv.LearningEvidence using
  ( DemonstratedLearning; claimedHumanPrincipal; demonstratedLearning )

insufficientPurposeLesson : BootstrapLesson
insufficientPurposeLesson =
  bootstrapLesson
    "purpose"
    "1. Purpose and human authority"
    "Start with why Govenv exists. The current purpose is the compressed result of the project's early repository-validity work and the later realization that fast agents must not silently outrun the human principal."
    "Govenv.Project; Govenv.DirectionReview; GV109-GV112; GV119"
    "Govenv.Project.purpose; Govenv.Project.purposeReviewIndex/purposeReviewRationale; Govenv.DirectionReview; Govenv.Assurance.GV110; Govenv.Materialization.Readme"
    "In your own words: what failure is Govenv preventing, and why is human authority part of the product rather than merely a team convention?"
    "Locate the canonical purpose, trace one projection of it, and identify the code that makes a mechanical purpose-review counter bump insufficient."
    "If README or a review counter changed while the governed purpose/review evidence did not, explain which checks should reject the candidate and what they do not prove."
    purposeRequirement

evidenceUnderInsufficientContract : DemonstratedLearning
evidenceUnderInsufficientContract =
  demonstratedLearning
    purposeRequirement
    (claimedHumanPrincipal "independent-catch-up-principal")
    (reviewContract insufficientPurposeLesson)
    "Human-produced response recorded under the insufficient purpose review surface."

insufficientContractCouldCloseItsOwnLesson :
  lessonEvidenced
    insufficientPurposeLesson
    (evidenceUnderInsufficientContract ∷ []) ≡ true
insufficientContractCouldCloseItsOwnLesson = refl

currentPurposeLessonRejectsInsufficientContract :
  lessonEvidenced
    purposeLesson
    (evidenceUnderInsufficientContract ∷ []) ≡ false
currentPurposeLessonRejectsInsufficientContract = refl
```

[executed on device: solo098 (ee17d3e4-8041-4f18-9fe7-4f36099458e3)]