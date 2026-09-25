# Project purpose snapshot materialization

This materialization preserves the canonical project purpose together with its
explicit Protocol-review rationale and vigilance index. The snapshot exists only
to validate future transitions without parsing literate source: it does not
become a second authority for those values.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.ProjectPurposeSnapshot where

open import Govenv.Kernel.ProjectPurpose using
  (ProjectPurposeSnapshot; projectPurposeSnapshot)
open import Govenv.Materialization
open import Govenv.Project using
  (purpose; purposeReviewRationale; purposeReviewIndex)

snapshot : ProjectPurposeSnapshot
snapshot =
  projectPurposeSnapshot purpose purposeReviewRationale purposeReviewIndex

materialization : Materialization ProjectPurposeSnapshot
materialization = materialized
  (repositoryFile ".govenv/project-purpose.snapshot")
  versionedApplication
  versionedPrivilege
  versionedAuthority
  trackedEquality
  snapshot
```
