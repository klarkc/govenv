# Learning snapshot materialization

The versioned learning snapshot exposes the machine-decidable state needed by
candidate and release enforcement: current debt closure, candidate eligibility,
and the explicit candidate-learning assessment. The assessment remains a
Protocol judgment; materialization preserves it for freshness and auditability
without claiming the classification or human understanding is objectively
proven.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.LearningSnapshot where

open import Govenv.Kernel.Learning using
  (LearningSnapshot; learningSnapshot; debtClear)
open import Govenv.Learning using
  (assessment; candidateAllowed; outstanding)
open import Govenv.Materialization

snapshot : LearningSnapshot
snapshot =
  learningSnapshot
    (debtClear outstanding)
    candidateAllowed
    assessment

materialization : Materialization LearningSnapshot
materialization = materialized
  (repositoryFile ".govenv/learning.snapshot")
  versionedApplication
  versionedPrivilege
  versionedAuthority
  trackedEquality
  snapshot
```
