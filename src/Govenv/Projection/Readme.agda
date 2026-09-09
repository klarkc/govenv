{-# OPTIONS --safe #-}

module Govenv.Projection.Readme where

open import Agda.Builtin.List
open import Agda.Builtin.String
open import Govenv.Kernel.Readme
open Readme
open import Govenv.Kernel.Roadmap
open import Govenv.Projection.Project using (projectName; projectDescription)
open import Govenv.Readme using (readme)
open import Govenv.Roadmap using (PhaseId; P0; P1; P2; P3; P4; P5; P6; GovernanceId; GV0; GV1; GV2; GV3; GV4; GV5; GV6; GV7; GV8; GV9; GV10; GV11; GV12; GV13; GV14; GV15; GV16; GV17; GV18; GV19; GV20; GV21; GV22; GV23; GV24; GV25; GV26; GV27; GV28; GV29; GV30; GV31; GV32; GV33; GV34; GV35; GV36; GV37; GV38; GV39; GV40; GV41; GV42; GV43; GV44; GV45; GV46; GV47; GV48; GV49; GV50)

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

renderGovernanceId : {owner : PhaseId} → GovernanceId owner → String
renderGovernanceId GV0 = "GV0"
renderGovernanceId GV1 = "GV1"
renderGovernanceId GV2 = "GV2"
renderGovernanceId GV3 = "GV3"
renderGovernanceId GV4 = "GV4"
renderGovernanceId GV5 = "GV5"
renderGovernanceId GV6 = "GV6"
renderGovernanceId GV7 = "GV7"
renderGovernanceId GV8 = "GV8"
renderGovernanceId GV9 = "GV9"
renderGovernanceId GV10 = "GV10"
renderGovernanceId GV11 = "GV11"
renderGovernanceId GV12 = "GV12"
renderGovernanceId GV13 = "GV13"
renderGovernanceId GV14 = "GV14"
renderGovernanceId GV15 = "GV15"
renderGovernanceId GV16 = "GV16"
renderGovernanceId GV17 = "GV17"
renderGovernanceId GV18 = "GV18"
renderGovernanceId GV19 = "GV19"
renderGovernanceId GV20 = "GV20"
renderGovernanceId GV21 = "GV21"
renderGovernanceId GV22 = "GV22"
renderGovernanceId GV23 = "GV23"
renderGovernanceId GV24 = "GV24"
renderGovernanceId GV25 = "GV25"
renderGovernanceId GV26 = "GV26"
renderGovernanceId GV27 = "GV27"
renderGovernanceId GV28 = "GV28"
renderGovernanceId GV29 = "GV29"
renderGovernanceId GV30 = "GV30"
renderGovernanceId GV31 = "GV31"
renderGovernanceId GV32 = "GV32"
renderGovernanceId GV33 = "GV33"
renderGovernanceId GV34 = "GV34"
renderGovernanceId GV35 = "GV35"
renderGovernanceId GV36 = "GV36"
renderGovernanceId GV37 = "GV37"
renderGovernanceId GV38 = "GV38"
renderGovernanceId GV39 = "GV39"
renderGovernanceId GV40 = "GV40"
renderGovernanceId GV41 = "GV41"
renderGovernanceId GV42 = "GV42"
renderGovernanceId GV43 = "GV43"
renderGovernanceId GV44 = "GV44"
renderGovernanceId GV45 = "GV45"
renderGovernanceId GV46 = "GV46"
renderGovernanceId GV47 = "GV47"
renderGovernanceId GV48 = "GV48"
renderGovernanceId GV49 = "GV49"
renderGovernanceId GV50 = "GV50"

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
