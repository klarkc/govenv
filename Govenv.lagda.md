# Govenv

Govenv is the canonical project entrypoint and formal closure root.

```agda
module Govenv where

open import Govenv.Architecture
open import Govenv.SourceLayout
open import Govenv.Governance
open import Govenv.Protocol
open import Govenv.Authorization
open import Govenv.Github.Authorization
open import Govenv.Administration
open import Govenv.Assurance
open import Govenv.Consolidation
open import Govenv.DirectionReview
open import Govenv.Materialization
open import Govenv.Materialization.Agents
open import Govenv.Materialization.Readme
open import Govenv.Materialization.ProjectPurposeSnapshot
open import Govenv.Materialization.DirectionReviewSnapshot
open import Govenv.Materialization.RoadmapSnapshot
open import Govenv.Materialization.ReleaseGovernance
open import Govenv.Materialization.Github.Repository.Description
open import Govenv.Materialization.Github.Repository.Topics
open import Govenv.Materialization.Github.Repository.Website
open import Govenv.Materialization.Github.Repository.MaterializerDeployKeys
open import Govenv.Materialization.Github.Repository.MainAuthorization
open import Govenv.Materialization.Github.Repository.MainAuthorityBoundary
open import Govenv.Materialization.Github.Repository.MainIntegrity
open import Govenv.Materialization.Github.Administration.Setup
open import Govenv.Materialization.Github.Workflows.Materialize
open import Govenv.Materialization.Github.Workflows.Test
open import Govenv.Materialization.Github.Workflows.Release
open import Govenv.Materialization.Github.Workflows.Pages
open import Govenv.Materialization.Github.Workflows.AdminMaterialize
open import Govenv.Materialization.Github.Actions.AdminEnvironment
open import Govenv.Materialization.Github.Actions.AuthorizedEffectsEnvironment
open import Govenv.Materialization.Github.Actions.MaterializerEnvironment
open import Govenv.Materialization.Github.Actions.PagesEnvironment
open import Govenv.Project
open import Govenv.Roadmap
open import Govenv.Readme
open import Govenv.Release
open import Govenv.Kernel.Fact
open import Govenv.Kernel.Verdict
open import Govenv.Kernel.Rule
```
