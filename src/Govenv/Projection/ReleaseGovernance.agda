{-# OPTIONS --safe #-}

module Govenv.Projection.ReleaseGovernance where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using
  (String; primShowNat; primStringAppend)
open import Govenv.Kernel.Identifier
open import Govenv.Kernel.Release
open GovernanceDelta
open ItemImpact
open import Govenv.Kernel.Roadmap using
  (ItemState; done; todo; cancelled; superseded)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.ReleaseGovernance
open ImpactGroup
open ImpactLine
open ReleaseDocument

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderPhaseId : SomePhaseId → String
renderPhaseId (someIdentifier phaseId) =
  "P" ++ primShowNat (indexOf phaseId)

renderGovernanceId : SomeGovernanceId → String
renderGovernanceId (someIdentifier governanceId) =
  "GV" ++ primShowNat (indexOf governanceId)

renderGovernanceRef : GovernanceRef → String
renderGovernanceRef replacement =
  "GV" ++ primShowNat (IdentifierRef.referenceIndex replacement)

renderDescription : SomeGovernanceId → String
renderDescription (someIdentifier governanceId) = descriptionOf governanceId

renderItemMark : ItemState → String
renderItemMark done = "✓"
renderItemMark todo = "◇"
renderItemMark cancelled = "×"
renderItemMark (superseded replacement) = "↪"

renderStateTransition : ItemState → String
renderStateTransition done = ""
renderStateTransition todo = ""
renderStateTransition cancelled = ""
renderStateTransition (superseded replacement) =
  " → **" ++ renderGovernanceRef replacement ++ "**"

renderChangeMark : ItemProgress → String
renderChangeMark completed = ""
renderChangeMark advanced = "↑ "
renderChangeMark introduced = "+ "
renderChangeMark cancelledProgress = ""
renderChangeMark (supersededProgress replacement) = ""

renderPhase : ReleaseDocument → String
renderPhase document with phase document
... | phaseIntroduced current =
  "+ ▣ " ++ renderPhaseId current ++ " — " ++ introducedPhaseLabel document
... | phaseUnchanged current =
  "▣ " ++ renderPhaseId current ++ " — " ++ unchangedPhaseLabel document
... | phaseAdvanced previous current =
  "■ " ++ renderPhaseId previous ++ " → ▣ " ++ renderPhaseId current
... | roadmapCompleted previous =
  "■ " ++ renderPhaseId previous ++ " → ■ " ++ roadmapCompleteLabel document

renderCount : ImpactGroup → String
renderCount group = primShowNat (count group) ++ " " ++ label group

renderSummary : ReleaseDocument → String
renderSummary document =
  renderCount (completedGroup document) ++ " · " ++
  renderCount (advancedGroup document) ++ " · " ++
  renderCount (introducedGroup document) ++ " · " ++
  renderCount (cancelledGroup document) ++ " · " ++
  renderCount (supersededGroup document)

renderImpact : ImpactLine → String
renderImpact line with impactValue line
... | impact itemId itemState progress =
  renderItemMark itemState ++ " **" ++ renderGovernanceId itemId ++ "**" ++
  renderStateTransition itemState ++ " · " ++ renderChangeMark progress ++
  progressLabel line ++ "\n\n> " ++ renderDescription itemId ++ "\n\n"

renderImpacts : List ImpactLine → String
renderImpacts [] = ""
renderImpacts (line ∷ rest) = renderImpact line ++ renderImpacts rest

renderGroup : String → String → ImpactGroup → String
renderGroup headingPrefix heading group with items group
... | [] = ""
... | values = headingPrefix ++ " " ++ heading ++ "\n\n" ++
  renderImpacts (groupLines values)
  where
    groupLines : List ItemImpact → List ImpactLine
    groupLines [] = []
    groupLines (item ∷ rest) =
      impactLine item (label group) ∷ groupLines rest

renderDocument : String → String → ReleaseDocument → String
renderDocument headingPrefix groupHeadingPrefix document =
  headingPrefix ++ " " ++ heading document ++ "\n\n" ++
  "**" ++ phaseLabel document ++ ":** " ++ renderPhase document ++ "  \n\n" ++
  "**" ++ itemsLabel document ++ ":** " ++ renderSummary document ++ "\n\n" ++
  renderGroup groupHeadingPrefix "Completed" (completedGroup document) ++
  renderGroup groupHeadingPrefix "Advanced" (advancedGroup document) ++
  renderGroup groupHeadingPrefix "Introduced" (introducedGroup document) ++
  renderGroup groupHeadingPrefix "Cancelled" (cancelledGroup document) ++
  renderGroup groupHeadingPrefix "Superseded" (supersededGroup document) ++
  "<sub>" ++ footer document ++ " `" ++ baseRevision document ++
  ".." ++ headRevision document ++ "`.</sub>\n"

startMarker : String
startMarker = "<!-- govenv-governance-impact:start -->\n"

endMarker : String
endMarker = "<!-- govenv-governance-impact:end -->\n"

renderBodyMaterialization : Materialization ReleaseDocument → String
renderBodyMaterialization materialization =
  startMarker ++ renderDocument "##" "###" (state materialization) ++ endMarker

renderChangelogMaterialization : Materialization ReleaseDocument → String
renderChangelogMaterialization materialization =
  startMarker ++ renderDocument "###" "####" (state materialization) ++ endMarker

renderError : GovernanceDeltaError → String
renderError (itemRegressed itemId) =
  "Governance item regressed from completed to pending: " ++ renderGovernanceId itemId
renderError (terminalItemChanged itemId) =
  "Terminal governance state was changed: " ++ renderGovernanceId itemId
renderError (governanceRemoved idx) =
  "Governance identity was removed from the roadmap: GV" ++ primShowNat idx
renderError (governanceDefinitionChanged itemId) =
  "Immutable governance definition was changed: " ++ renderGovernanceId itemId
renderError (governancePhaseChanged itemId previous current) =
  "Immutable governance owner phase was changed for " ++ renderGovernanceId itemId ++
  " from P" ++ primShowNat previous ++ " to P" ++ primShowNat current
renderError (phaseRegressed previous current) =
  "Roadmap phase regressed from P" ++ primShowNat previous ++
  " to " ++ renderPhaseId current
renderError emptyRoadmap = "A completed roadmap must contain at least one phase"
