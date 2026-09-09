# README

The repository README is a canonical projection of governed project data. It is generated, not authored independently.

```agda
{-# OPTIONS --safe #-}

module Govenv.Readme where

open import Agda.Builtin.String
open import Govenv.Roadmap using (renderRoadmap)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

header : String
header =
  "<!-- Generated from Govenv.Readme. Do not edit manually. -->\n\n" ++
  "<h1 align=\"center\">Govenv</h1>\n\n" ++
  "<p align=\"center\">\n" ++
  "  <strong>Compile formally governed projects into reproducible development runtimes. A type system for your repository.</strong>\n" ++
  "</p>\n\n" ++
  "<p align=\"center\">\n" ++
  "  <a href=\"https://klarkc.github.io/govenv/\"><img src=\"https://img.shields.io/badge/docs-pages-brightgreen\" alt=\"Docs\" /></a>\n" ++
  "  <img src=\"https://img.shields.io/badge/agda-2.8.0-blueviolet\" alt=\"Agda 2.8.0\" />\n" ++
  "  <a href=\"https://github.com/klarkc/govenv/releases\"><img src=\"https://img.shields.io/github/v/release/klarkc/govenv?display_name=tag&sort=semver\" alt=\"Release\" /></a>\n" ++
  "  <img src=\"https://img.shields.io/badge/license-Apache--2.0-blue\" alt=\"License\" />\n" ++
  "</p>\n\n"

gettingStarted : String
gettingStarted =
  "## Getting started\n\n" ++
  "Govenv currently uses devenv only as its Stage 0 bootstrap environment.\n\n" ++
  "The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`.\n\n" ++
  "### Test\n\n" ++
  "Run the test suite with the pinned devenv tag:\n\n" ++
  "```bash\n" ++
  "nix run github:cachix/devenv/v2.3 -- test\n" ++
  "```\n\n" ++
  "This type-checks the literate Agda entrypoint `Govenv.lagda.md`, its imported Govenv modules, and verifies governed generated artifacts such as `README.md`.\n\n" ++
  "### Documentation\n\n" ++
  "Build the literate Agda documentation locally with:\n\n" ++
  "```bash\n" ++
  "nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs\n" ++
  "```\n\n" ++
  "The static site is written to `_site/` and deployed to GitHub Pages from `main`.\n"

readme : String
readme = header ++ renderRoadmap ++ gettingStarted
```
