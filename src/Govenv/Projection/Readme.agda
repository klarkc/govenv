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
open import Govenv.Roadmap using (PhaseId; P0; P1; P2; P3; P4; P5; P6; GovernanceId; GV)

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

itemMark : ItemState → String
itemMark done = "✓"
itemMark todo = "◇"

renderGovernanceId : GovernanceId → String
renderGovernanceId (GV number) = "GV" ++ primShowNat number

renderItem : {owner : PhaseId} → Item PhaseId GovernanceId owner → String
renderItem {owner} (item identifier title state) =
  "- " ++ itemMark state ++ " **" ++ renderGovernanceId identifier ++ "** " ++ title ++ "\n"

renderItems : {owner : PhaseId} → List (Item PhaseId GovernanceId owner) → String
renderItems [] = ""
renderItems (x ∷ xs) = renderItem x ++ renderItems xs

renderPhase : {state : PhaseState} → String → String → Phase PhaseId GovernanceId state → String
renderPhase mark attribute (phase identifier title items) =
  "<details" ++ attribute ++ ">\n" ++
  "<summary>" ++ mark ++ " <strong>" ++ renderPhaseId identifier ++ " — " ++ title ++ "</strong></summary>\n\n" ++
  renderItems items ++ "\n</details>\n\n"

renderFinished : Phase PhaseId GovernanceId finished → String
renderFinished = renderPhase "■" ""

renderActive : Phase PhaseId GovernanceId active → String
renderActive = renderPhase "▣" " open"

renderFuture : Phase PhaseId GovernanceId future → String
renderFuture = renderPhase "□" ""

renderPhaseList : {state : PhaseState} → (Phase PhaseId GovernanceId state → String) → List (Phase PhaseId GovernanceId state) → String
renderPhaseList render [] = ""
renderPhaseList render (x ∷ xs) = render x ++ renderPhaseList render xs

renderPhases : Roadmap PhaseId GovernanceId → String
renderPhases (progressing finishedPhases currentPhase futurePhases) =
  renderPhaseList renderFinished finishedPhases ++
  renderActive currentPhase ++
  renderPhaseList renderFuture futurePhases
renderPhases (complete finishedPhases) = renderPhaseList renderFinished finishedPhases

renderCurrent : String → Roadmap PhaseId GovernanceId → String
renderCurrent summary (progressing finishedPhases (phase identifier title items) futurePhases) =
  "**Current:** ▣ " ++ renderPhaseId identifier ++ " — " ++ title ++ ". " ++ summary ++ "\n\n"
renderCurrent summary (complete finishedPhases) = "**Current:** ■ Roadmap complete.\n\n"

renderHeader : Readme PhaseId GovernanceId → String
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

renderRoadmap : Readme PhaseId GovernanceId → String
renderRoadmap specification =
  "## Roadmap\n\n" ++
  renderCurrent (currentSummary specification) (roadmap specification) ++
  "> " ++ roadmapNote specification ++ "\n\n" ++
  renderPhases (roadmap specification)

renderGettingStarted : Readme PhaseId GovernanceId → String
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
