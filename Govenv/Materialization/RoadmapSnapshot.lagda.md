# Roadmap snapshot materialization

This materialization preserves the release-relevant semantic roadmap state in a stable versioned artifact. It is derived from the typed roadmap and exists so future releases can compare governance state without interpreting a human-facing projection.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.RoadmapSnapshot where

open import Govenv.Kernel.Release using
  (RoadmapSnapshot; snapshotRoadmap)
open import Govenv.Materialization
open import Govenv.Roadmap using (roadmap)

snapshot : RoadmapSnapshot
snapshot = snapshotRoadmap roadmap

materialization : Materialization RoadmapSnapshot
materialization = materialized
  (repositoryFile ".govenv/roadmap.snapshot")
  versionedApplication
  versionedPrivilege
  trackedEquality
  snapshot
```
