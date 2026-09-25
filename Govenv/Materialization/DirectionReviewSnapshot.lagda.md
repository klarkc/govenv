# Direction review snapshot materialization

This versioned snapshot preserves the review witness, explicit review rationale,
and human-facing Current / Next text needed to verify Protocol vigilance against
predecessor project state.
The exact Purpose and Roadmap sources remain owned by their existing canonical
project and roadmap snapshots.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.DirectionReviewSnapshot where

open import Govenv.DirectionReview using (review)
open import Govenv.Kernel.DirectionReview using
  (DirectionReviewSnapshot; snapshotDirectionReview)
open import Govenv.Materialization

snapshot : DirectionReviewSnapshot
snapshot = snapshotDirectionReview review

materialization : Materialization DirectionReviewSnapshot
materialization = materialized
  (repositoryFile ".govenv/direction-review.snapshot")
  versionedApplication
  versionedPrivilege
  versionedAuthority
  trackedEquality
  snapshot
```
