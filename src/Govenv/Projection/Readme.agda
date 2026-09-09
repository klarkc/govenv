{-# OPTIONS --safe #-}

module Govenv.Projection.Readme where

open import Agda.Builtin.List
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String
open import Govenv.Kernel.Readme
open Readme
open import Govenv.Kernel.Roadmap
open import Govenv.Projection.Project using (projectName; projectDescription)
open import Govenv.Readme using (readme)
open import Govenv.Roadmap using (PhaseId; P0; P1; P2; P3; P4; P5; P6)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderPhaseId : PhaseId → String
renderPhaseId P0 = "P0"
renderPhaseId P1 = "P1"
renderPhaseId P2 = "P2"
renderPhaseId P3 = "P3"
renderPhaseId P4 = "P4"
renderPhaseId P5 = "P5"
renderPhaseId P6 = "P6"

checkbox : ItemState → String
checkbox done = "[x]"
checkbox todo = "[ ]"

phaseMark : PhaseState → String
phaseMark finished = "☑"
phaseMark active = "☐"
phaseMark future = "☐"

openAttribute : PhaseState → String
openAttribute active = " open"
openAttribute _ = ""

currentMark : PhaseState → String
currentMark active = " ← current"
currentMark _ = ""

renderItem : {owner : PhaseId} → Item PhaseId owner → String
renderItem {owner} (item number title state) =
  "- " ++ checkbox state ++ " **GV" ++ primShowNat number ++ "** " ++ title ++ "\n"

renderItems : {owner : PhaseId} → List (Item PhaseId owner) → String
renderItems [] = ""
renderItems (x ∷ xs) = renderItem x ++ renderItems xs

renderPhase : Phase PhaseId → String
renderPhase (phase identifier title state items) =
  "<details" ++ openAttribute state ++ ">\n" ++
  "<summary>" ++ phaseMark state ++ " <strong>" ++ renderPhaseId identifier ++ " — " ++ title ++ "</strong>" ++ currentMark state ++ "</summary>\n\n" ++
  renderItems items ++ "\n</details>\n\n"

renderPhases : Roadmap PhaseId → String
renderPhases [] = ""
renderPhases (x ∷ xs) = renderPhase x ++ renderPhases xs

renderCurrent : String → Roadmap PhaseId → String
renderCurrent summary [] = ""
renderCurrent summary (phase identifier title active items ∷ xs) =
  "**Current:** " ++ renderPhaseId identifier ++ " — " ++ title ++ ". " ++ summary ++ "\n\n"
renderCurrent summary (_ ∷ xs) = renderCurrent summary xs

renderHeader : Readme PhaseId → String
renderHeader specification =
  "<!-- Generated from Govenv.Readme. Do not edit manually. -->\n\n" ++
  "<h1 align=\"center\">" ++ projectName ++ "</h1>\n\n" ++
  "<p align=\"center\">\n  <strong>" ++ projectDescription ++ "</strong>\n</p>\n\n" ++
  "<p align=\"center\">\n" ++
  "  <a href=\"" ++ docsUrl specification ++ "\"><img src=\"https://img.shields.io/badge/docs-pages-brightgreen\" alt=\"Docs\" /></a>\n" ++
  "  <img src=\"https://img.shields.io/badge/agda-" ++ agdaVersion specification ++ "-blueviolet\" alt=\"Agda " ++ agdaVersion specification ++ "\" />\n" ++
  "  <a href=\"" ++ releaseUrl specification ++ "\"><img src=\"https://img.shields.io/github/v/release/klarkc/govenv?display_name=tag&sort=semver\" alt=\"Release\" /></a>\n" ++
  "  <img src=\"https://img.shields.io/badge/license-Apache--2.0-blue\" alt=\"" ++ licenseName specification ++ "\" />\n" ++
  "</p>\n\n"

renderRoadmap : Readme PhaseId → String
renderRoadmap specification =
  "## Roadmap\n\n" ++
  renderCurrent (currentSummary specification) (roadmap specification) ++
  "> " ++ roadmapNote specification ++ "\n\n" ++
  renderPhases (roadmap specification)

renderGettingStarted : Readme PhaseId → String
renderGettingStarted specification =
  "## " ++ gettingStartedTitle specification ++ "\n\n" ++
  bootstrapSummary specification ++ "\n\n" ++
  bootstrapPin specification ++ "\n\n" ++
  "### " ++ materializeTitle specification ++ "\n\n" ++
  "Materialize governed repository artifacts with:\n\n```bash\n" ++ materializeCommand specification ++ "\n```\n\n" ++
  materializeSummary specification ++ "\n\n" ++
  "### " ++ administrationTitle specification ++ "\n\n" ++
  administrationSummary specification ++ " [Read the governed setup guide](" ++ administrationUrl specification ++ ").\n\n" ++
  "### " ++ testTitle specification ++ "\n\n" ++
  "Run the test suite with the pinned devenv tag:\n\n```bash\n" ++ testCommand specification ++ "\n```\n\n" ++
  testSummary specification ++ "\n\n" ++
  "### " ++ docsTitle specification ++ "\n\n" ++
  "Build the literate Agda documentation locally with:\n\n```bash\n" ++ docsCommand specification ++ "\n```\n\n" ++
  docsSummary specification ++ "\n"

renderReadme : String
renderReadme =
  renderHeader readme ++
  renderRoadmap readme ++
  renderGettingStarted readme
