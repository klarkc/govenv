# Constitutional snapshot materialization

This module defines the repository boundary for the constitutional snapshot v3.
The proof-carrying `HistorySnapshot` remains inside Agda in `Set₁`; only its
audit observation `ConstitutionSnapshot : Set` may cross the materialization
boundary. The target intentionally remains `.govenv/roadmap.snapshot` so the
eventual cutover replaces snapshot v2 in place rather than creating two competing
release boundaries.

This module defines the materialization function only. Govenv's real project
snapshot is not instantiated here; that happens only after the real constitutional
genesis is frozen at a human-authorized revision.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.ConstitutionSnapshot where

open import Govenv.Kernel.Constitution.Snapshot using (ConstitutionSnapshot)
open import Govenv.Materialization

materializationFor :
  ConstitutionSnapshot →
  Materialization ConstitutionSnapshot
materializationFor snapshot =
  materialized
    (repositoryFile ".govenv/roadmap.snapshot")
    versionedApplication
    versionedPrivilege
    versionedAuthority
    trackedEquality
    snapshot
```
