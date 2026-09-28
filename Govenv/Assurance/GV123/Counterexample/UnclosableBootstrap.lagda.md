# GV123 unclosable-bootstrap counterexample

During human review of PR #53, Govenv already had a governed from-zero
curriculum and could render every bootstrap challenge, but the shell only told
the principal to preserve a response later in a pull request. There was no
governed operation that captured the exact human response into canonical
learning evidence, so the newly introduced gate was not operationally reachable
from zero.

GV123 closes that hole with `govenv-learning answer <key>`, a dedicated
`Govenv.LearningEvidence` authority, and an evidence-only candidate path whose
only substantive source change may be that evidence authority and whose governed
debt count must strictly decrease.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV123.Counterexample.UnclosableBootstrap where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Govenv.Kernel.Learning using (learningEvidenceCandidateAllowed)

renderingWithoutEvidenceProgressCannotCloseDebt :
  learningEvidenceCandidateAllowed true 12 12 ≡ false
renderingWithoutEvidenceProgressCannotCloseDebt = refl

unrelatedSemanticChangeCannotUseEvidencePath :
  learningEvidenceCandidateAllowed false 12 11 ≡ false
unrelatedSemanticChangeCannotUseEvidencePath = refl
```
