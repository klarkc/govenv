# README

The repository README is governed project data. Rendering and materialization belong to implementation layers outside the constitution.

```agda
{-# OPTIONS --safe #-}

module Govenv.Readme where

open import Govenv.Kernel.Readme
open import Govenv.Roadmap

readme : Readme PhaseId
readme = record
  { docsUrl = "https://klarkc.github.io/govenv/"
  ; agdaVersion = "2.8.0"
  ; releaseUrl = "https://github.com/klarkc/govenv/releases"
  ; licenseName = "Apache-2.0"
  ; currentSummary = "`Verdict`, typed `Fact`, and the current `Rule` model are in place; dependency-indexed rules and the first self-governing rule are next."
  ; roadmapNote = "This roadmap is subject to change as Govenv's architecture evolves. IDs are intended to remain stable references whenever practical."
  ; roadmap = roadmap
  ; gettingStartedTitle = "Getting started"
  ; bootstrapSummary = "Govenv currently uses devenv only as its Stage 0 bootstrap environment."
  ; bootstrapPin = "The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`."
  ; materializeTitle = "Materialization"
  ; materializeCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:materialize"
  ; materializeSummary = "Versioned materializations are committed immediately after their governing source change, using a subsequent `chore(materialize)` commit."
  ; testTitle = "Test"
  ; testCommand = "nix run github:cachix/devenv/v2.3 -- test"
  ; testSummary = "This type-checks the literate Agda entrypoint `Govenv.lagda.md`, its imported Govenv modules, and verifies governed generated artifacts such as `README.md`."
  ; docsTitle = "Documentation"
  ; docsCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs"
  ; docsSummary = "The static site is written to `_site/` and deployed to GitHub Pages from `main`."
  }
```
