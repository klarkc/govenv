{-# OPTIONS --safe #-}

module Govenv.Projection.Readme where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String
open import Govenv.Kernel.Identifier
open import Govenv.Kernel.Roadmap
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.Readme
open Badge

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

renderInline : Inline → String
renderInline (text value) = value
renderInline (strong value) = "<strong>" ++ value ++ "</strong>"
renderInline (code value) = "`" ++ value ++ "`"
renderInline (link label url) = "[" ++ label ++ "](" ++ url ++ ")"

renderInlines : List Inline → String
renderInlines [] = ""
renderInlines (x ∷ xs) = renderInline x ++ renderInlines xs

renderBadge : Badge → String
renderBadge specification with targetUrl specification
... | nothing =
  "<img src=\"" ++ imageUrl specification ++ "\" alt=\"" ++ alt specification ++ "\" />"
... | just url =
  "<a href=\"" ++ url ++ "\"><img src=\"" ++ imageUrl specification ++
  "\" alt=\"" ++ alt specification ++ "\" /></a>"

renderBadges : List Badge → String
renderBadges [] = ""
renderBadges (x ∷ xs) = "  " ++ renderBadge x ++ "\n" ++ renderBadges xs

renderCurrent : Current → String
renderCurrent (activeCurrent label (someIdentifier phaseId) summary) =
  "**" ++ label ++ ":** ▣ " ++ renderPhaseId phaseId ++ " — " ++
  descriptionOf phaseId ++ ". " ++ summary ++ "\n\n"
renderCurrent (roadmapComplete label message) =
  "**" ++ label ++ ":** ■ " ++ message ++ "\n\n"

renderHeading : HeadingLevel → Alignment → String → String
renderHeading title centered value = "<h1 align=\"center\">" ++ value ++ "</h1>\n\n"
renderHeading title normal value = "# " ++ value ++ "\n\n"
renderHeading section centered value = "<h2 align=\"center\">" ++ value ++ "</h2>\n\n"
renderHeading section normal value = "## " ++ value ++ "\n\n"
renderHeading subsection centered value = "<h3 align=\"center\">" ++ value ++ "</h3>\n\n"
renderHeading subsection normal value = "### " ++ value ++ "\n\n"

renderParagraph : Alignment → List Inline → String
renderParagraph normal content = renderInlines content ++ "\n\n"
renderParagraph centered content =
  "<p align=\"center\">\n  " ++ renderInlines content ++ "\n</p>\n\n"

renderBlock : Block → String
renderBlock (comment value) = "<!-- " ++ value ++ " -->\n\n"
renderBlock (heading level alignment value) = renderHeading level alignment value
renderBlock (paragraph alignment content) = renderParagraph alignment content
renderBlock (badges specifications) =
  "<p align=\"center\">\n" ++ renderBadges specifications ++ "</p>\n\n"
renderBlock (current value) = renderCurrent value
renderBlock (blockQuote value) = "> " ++ value ++ "\n\n"
renderBlock (roadmapTree value) = renderPhases value
renderBlock (codeBlock language value) =
  "```" ++ language ++ "\n" ++ value ++ "\n```\n\n"

renderFinalBlock : Block → String
renderFinalBlock (paragraph normal content) = renderInlines content ++ "\n"
renderFinalBlock block = renderBlock block

renderDocument : Document → String
renderDocument [] = ""
renderDocument (x ∷ []) = renderFinalBlock x
renderDocument (x ∷ xs) = renderBlock x ++ renderDocument xs

renderReadme : String
renderReadme = renderDocument (state materialization)
