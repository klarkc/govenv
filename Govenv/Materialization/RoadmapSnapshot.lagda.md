# Roadmap snapshot materialization

This materialization preserves immutable governance identity and release-relevant roadmap state in a stable versioned artifact. Snapshot v2 records each `GovernanceId` with its exact definition, owning phase, and lifecycle state, including cancellation or an explicit supersession target. It is derived from the typed roadmap so evolution can be validated without interpreting a human-facing projection.

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
