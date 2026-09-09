{-# OPTIONS --safe #-}

module Govenv.Projection.Readme where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String
open import Govenv.Kernel.Identifier
open import Govenv.Kernel.Readme
open Readme
open import Govenv.Kernel.Roadmap
open import Govenv.Projection.Project using (projectName; projectDescription)
open import Govenv.Readme using (readme)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderPhaseId :
  {idx : Nat} {description : String} →
  PhaseId idx description → String
renderPhaseId phaseId = "P" ++ primShowNat (indexOf phaseId)

renderGovernanceId :
  {idx : Nat} {description : String} →
  GovernanceId idx description → String
renderGovernanceId governanceId = "GV" ++ primShowNat (indexOf governanceId)

itemMark : ItemState → String
itemMark done = "✓"
itemMark todo = "◇"

renderMembership :
  {phaseIdx : Nat} {phaseDescription : String}
  {phase : PhaseId phaseIdx phaseDescription} →
  Membership phase → String
renderMembership (membership governanceId state relation) =
  "- " ++ itemMark state ++
  " **" ++ renderGovernanceId governanceId ++ "** " ++
  descriptionOf governanceId ++ "\n"

renderItems :
  {phaseIdx : Nat} {phaseDescription : String}
  {phase : PhaseId phaseIdx phaseDescription} →
  List (Membership phase) → String
renderItems [] = ""
renderItems (x ∷ xs) = renderMembership x ++ renderItems xs

renderPhase :
  {state : PhaseState} →
  String → String → PhaseNode state → String
renderPhase mark attribute (phaseNode phaseId items) =
  "<details" ++ attribute ++ ">\n" ++
  "<summary>" ++ mark ++ " <strong>" ++ renderPhaseId phaseId ++
  " — " ++ descriptionOf phaseId ++ "</strong></summary>\n\n" ++
  renderItems items ++ "\n</details>\n\n"
renderFinished : PhaseNode finished → String
renderFinished = renderPhase "■" ""

renderActive : PhaseNode active → String
renderActive = renderPhase "▣" " open"

renderFuture : PhaseNode future → String
renderFuture = renderPhase "□" ""

renderPhaseList :
  {state : PhaseState} →
  (PhaseNode state → String) →
  List (PhaseNode state) → String
renderPhaseList render [] = ""
renderPhaseList render (x ∷ xs) = render x ++ renderPhaseList render xs

renderPhases : Roadmap → String
renderPhases (progressing finishedPhases currentPhase futurePhases) =
  renderPhaseList renderFinished finishedPhases ++
  renderActive currentPhase ++
  renderPhaseList renderFuture futurePhases
renderPhases (complete finishedPhases) =
  renderPhaseList renderFinished finishedPhases

renderCurrent : String → Roadmap → String
renderCurrent summary (progressing finishedPhases (phaseNode phaseId items) futurePhases) =
  "**Current:** ▣ " ++ renderPhaseId phaseId ++ " — " ++
  descriptionOf phaseId ++ ". " ++ summary ++ "\n\n"
renderCurrent summary (complete finishedPhases) =
  "**Current:** ■ Roadmap complete.\n\n"

renderHeader : Readme → String
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

renderRoadmap : Readme → String
renderRoadmap specification =
  "## Roadmap\n\n" ++
  renderCurrent (currentSummary specification) (roadmap specification) ++
  "> " ++ roadmapNote specification ++ "\n\n" ++
  renderPhases (roadmap specification)

renderGettingStarted : Readme → String
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
