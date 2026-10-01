# GV125 stacked pull-request hard-gate counterexample

PRs #61, #62, and #63 exposed an implicit assumption in GV122's first
candidate-boundary implementation. PR #61 targeted `main`; PR #62 targeted
PR #61's candidate branch; PR #63 targeted PR #62's candidate branch. The Test
workflow supplied each immediate pull-request base SHA to the learning gate, so
the same authorization hard gate was applied to both `authorized → candidate`
and `candidate → candidate` edges.

That behavior matched the old Protocol text, but once candidate composition is
distinguished from semantic authorization it is a counterexample: unresolved
learning must prevent a candidate from becoming authoritative, not prevent an
unmerged child candidate from being composed and tested while its unsatisfied
requirements remain preserved.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV125.Counterexample.StackedPullRequestHardGate where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Govenv.Kernel.Learning

openDebt : LearningDebt
openDebt =
  learningRequirement
    "Explain stacked candidate learning."
    "unmerged-parent"
  ∷ []

oldHardGateBlocksChild :
  candidateLearningAllowed
    feature expands true false true openDebt noBypass ≡ false
oldHardGateBlocksChild = refl

candidateCompositionKeepsChildTestable :
  candidateCompositionAllowed
    feature expands true false true noBypass ≡ true
candidateCompositionKeepsChildTestable = refl

candidateCompositionCannotLoseRequirement :
  candidateCompositionAllowed
    feature expands true false false noBypass ≡ false
candidateCompositionCannotLoseRequirement = refl

compositionBoundaryUsesCompositionDecision :
  candidateBoundaryAllowed
    candidateComposition
    true
    false ≡ true
compositionBoundaryUsesCompositionDecision = refl

authorizationBoundaryStillRejectsOpenDebt :
  candidateBoundaryAllowed
    authorizationBoundary
    true
    false ≡ false
authorizationBoundaryStillRejectsOpenDebt = refl
```
