# README

This module contains governed source data used by the repository README. `Govenv.Materialization.Readme` is the canonical semantic README definition; projections only encode it and adapters only apply or verify effects.

```agda
{-# OPTIONS --safe #-}

module Govenv.Readme where

open import Govenv.Kernel.Readme
open import Govenv.Project using (website)
open import Govenv.Roadmap using (roadmap)

readme : Readme
readme = record
  { docsUrl = website
  ; agdaVersion = "2.8.0"
  ; releaseUrl = "https://github.com/klarkc/govenv/releases"
  ; licenseName = "Apache-2.0"
  ; roadmapNote = "Governance IDs are immutable historical references. Definitions and owning phases never change after introduction; abandoned work is cancelled, while corrections or changed intent require a newer GV and explicit supersession."
  ; roadmap = roadmap
  ; gettingStartedTitle = "Getting started"
  ; bootstrapSummary = "Govenv currently uses devenv only as its Stage 0 bootstrap environment."
  ; bootstrapPin = "The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`."
  ; materializeTitle = "Materialization"
  ; materializeCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:materialize"
  ; materializeSummary = "On `main`, the Materialize workflow applies versioned non-admin projections automatically and commits any tracked drift as a subsequent `chore(materialize)` commit. The command above remains available for local materialization."
  ; administrationTitle = "Administrative materialization"
  ; administrationUrl = "https://klarkc.github.io/govenv/Govenv.Administration.html"
  ; administrationSummary = "Stage 0 administrative bootstrap, recovery, and credential rotation, including the `admin-materialization` environment and `GOVENV_ADMIN_TOKEN`, are documented as governed literate Agda rather than duplicated here. Ordinary project-state effects reconcile automatically after authorization."
  ; testTitle = "Test"
  ; testCommand = "nix run github:cachix/devenv/v2.3 -- test"
  ; testSummary = "This type-checks the literate Agda entrypoint `Govenv.lagda.md`, its imported Govenv modules, and verifies governed generated artifacts such as `README.md`."
  ; docsTitle = "Documentation"
  ; docsCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs"
  ; docsSummary = "The static site is written to `_site/` and deployed to GitHub Pages from `main`."
  }
```
