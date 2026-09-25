# Learning debt snapshot materialization

The versioned snapshot exposes only the machine-decidable fact needed by outer
release enforcement: whether governed learning debt is empty. It does not
encode or infer human understanding.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.LearningSnapshot where

open import Agda.Builtin.Bool using (Bool)
open import Govenv.Kernel.Learning using (debtClear)
open import Govenv.Learning using (outstanding)
open import Govenv.Materialization

snapshot : Bool
snapshot = debtClear outstanding

materialization : Materialization Bool
materialization = materialized
  (repositoryFile ".govenv/learning.snapshot")
  versionedApplication
  versionedPrivilege
  versionedAuthority
  trackedEquality
  snapshot
```
