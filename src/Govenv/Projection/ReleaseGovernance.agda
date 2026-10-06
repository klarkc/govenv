{-# OPTIONS --safe #-}

module Govenv.Projection.ReleaseGovernance where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Char using (Char; primCharEquality)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; zero; suc; _+_; _<_)
open import Agda.Builtin.String using
  ( String; primShowNat; primStringAppend; primStringEquality
  ; primStringFromList; primStringToList )
open import Govenv.Kernel.Identifier
open import Govenv.Kernel.Release
open GovernanceDelta
open ItemImpact
open import Govenv.Kernel.Roadmap using
  ( ItemState; done; todo; cancelled; superseded; lookupGovernanceRef )
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.ReleaseGovernance
open ImpactGroup
open ReleaseDocument
open import Govenv.Projection.SemanticDiff

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

data TokenStyle : Set where
  plain removed added : TokenStyle

record RenderToken : Set where
  constructor token
  field
    value : String
    style : TokenStyle

open RenderToken

private
  infixr 5 _++ₗ_

  _++ₗ_ : {A : Set} → List A → List A → List A
  [] ++ₗ ys = ys
  (x ∷ xs) ++ₗ ys = x ∷ (xs ++ₗ ys)

  reverse : {A : Set} → List A → List A
  reverse values = go values []
    where
    go : {A : Set} → List A → List A → List A
    go [] acc = acc
    go (x ∷ xs) acc = go xs (x ∷ acc)

  length : {A : Set} → List A → Nat
  length [] = zero
  length (_ ∷ xs) = suc (length xs)

  take : {A : Set} → Nat → List A → List A
  take zero xs = []
  take (suc n) [] = []
  take (suc n) (x ∷ xs) = x ∷ take n xs

  takeLast : {A : Set} → Nat → List A → List A
  takeLast count values = reverse (take count (reverse values))

  atMost : Nat → List String → Bool
  atMost limit values with length values < suc limit
  ... | true = true
  ... | false = false

  plainTokens : List String → List RenderToken
  plainTokens [] = []
  plainTokens (word ∷ rest) = token word plain ∷ plainTokens rest

  styledTokens : TokenStyle → List String → List RenderToken
  styledTokens tokenStyle [] = []
  styledTokens tokenStyle (word ∷ rest) =
    token word tokenStyle ∷ styledTokens tokenStyle rest

  ellipsis : RenderToken
  ellipsis = token "…" plain

  hasChange : List SemanticSpan → Bool
  hasChange [] = false
  hasChange (same words ∷ rest) = hasChange rest
  hasChange (changed old new ∷ rest) = true

  commonContext : Bool → Bool → List String → List RenderToken
  commonContext seen future words with atMost 6 words
  ... | true = plainTokens words
  ... | false with seen | future
  ...   | false | true = ellipsis ∷ plainTokens (takeLast 6 words)
  ...   | true | true =
      plainTokens (take 3 words) ++ₗ
      (ellipsis ∷ plainTokens (takeLast 3 words))
  ...   | true | false = plainTokens (take 6 words) ++ₗ (ellipsis ∷ [])
  ...   | false | false with atMost 10 words
  ...     | true = plainTokens words
  ...     | false = plainTokens (take 10 words) ++ₗ (ellipsis ∷ [])

  data DiffSide : Set where
    oldSide newSide : DiffSide

  changedTokens : DiffSide → List String → List String → List RenderToken
  changedTokens oldSide old new = styledTokens removed old
  changedTokens newSide old new = styledTokens added new

  compactSpans : DiffSide → Bool → List SemanticSpan → List RenderToken
  compactSpans side seen [] = []
  compactSpans side seen (same words ∷ rest) =
    commonContext seen (hasChange rest) words ++ₗ compactSpans side seen rest
  compactSpans side seen (changed old new ∷ rest) =
    changedTokens side old new ++ₗ compactSpans side true rest

  charString : Char → String
  charString char = primStringFromList (char ∷ [])

  escapeMathChar : Char → String
  escapeMathChar char with primCharEquality char '`'
  ... | true = ""
  ... | false with primCharEquality char '_'
  ...   | true = "\\_"
  ...   | false with primCharEquality char '%'
  ...     | true = "\\%"
  ...     | false with primCharEquality char '#'
  ...       | true = "\\#"
  ...       | false with primCharEquality char '&'
  ...         | true = "\\&"
  ...         | false with primCharEquality char '$'
  ...           | true = "\\$"
  ...           | false with primCharEquality char '{'
  ...             | true = "\\{"
  ...             | false with primCharEquality char '}'
  ...               | true = "\\}"
  ...               | false = charString char

  escapeMathChars : List Char → String
  escapeMathChars [] = ""
  escapeMathChars (char ∷ rest) =
    escapeMathChar char ++ escapeMathChars rest

  escapeMath : String → String
  escapeMath value = escapeMathChars (primStringToList value)

  renderStyled : TokenStyle → String → String
  renderStyled plain value = value
  renderStyled removed value =
    "$`{\\color{red}\\texttt{" ++ escapeMath value ++ "}}`$"
  renderStyled added value =
    "$`{\\color{green}\\texttt{" ++ escapeMath value ++ "}}`$"

  visibleWidth : RenderToken → Nat
  visibleWidth current = length (primStringToList (value current))

  renderToken : RenderToken → String
  renderToken current = renderStyled (style current) (value current)

  renderTokensAt : Nat → Nat → Bool → List RenderToken → String
  renderTokensAt indent column first [] = ""
  renderTokensAt indent column true (current ∷ rest) =
    renderToken current ++
    renderTokensAt indent (column + visibleWidth current) false rest
  renderTokensAt indent column false (current ∷ rest)
    with primStringEquality (value current) "…"
  ... | true =
      "&nbsp;" ++ renderToken current ++
      renderTokensAt indent (column + suc (visibleWidth current)) false rest
  ... | false with (column + suc (visibleWidth current)) < 81
  ...   | true =
      "&nbsp;" ++ renderToken current ++
      renderTokensAt indent (column + suc (visibleWidth current)) false rest
  ...   | false =
      "<br>&nbsp;&nbsp;" ++ renderToken current ++
      renderTokensAt indent (suc (suc (visibleWidth current))) false rest

  renderDiffTokens : List RenderToken → String
  renderDiffTokens = renderTokensAt 2 2 true

  renderPlainTokens : List RenderToken → String
  renderPlainTokens = renderTokensAt zero zero true

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

hasImpact : List ImpactGroup → Bool
hasImpact [] = false
hasImpact (group ∷ rest) with items group
... | [] = hasImpact rest
... | values = true

renderSummaryGroups : List ImpactGroup → String
renderSummaryGroups [] = ""
renderSummaryGroups (group ∷ rest) with items group | hasImpact rest
... | [] | future = renderSummaryGroups rest
... | values | true = renderCount group ++ " · " ++ renderSummaryGroups rest
... | values | false = renderCount group

renderSummary : ReleaseDocument → String
renderSummary document = renderSummaryGroups
  (completedGroup document ∷
   advancedGroup document ∷
   introducedGroup document ∷
   cancelledGroup document ∷
   supersededGroup document ∷ [])

renderCompactDescription : String → String
renderCompactDescription description =
  renderPlainTokens (compactSpans oldSide false (semanticDiff description description))

renderSingleHeader : ItemImpact → String
renderSingleHeader (impact itemId state completed) =
  renderGovernanceId itemId ++ " ◇ → ✓"
renderSingleHeader (impact itemId state advanced) =
  renderGovernanceId itemId ++ " ◇ ↑"
renderSingleHeader (impact itemId state introduced) =
  "+ " ++ renderGovernanceId itemId ++ " " ++ renderItemMark state
renderSingleHeader (impact itemId state cancelledProgress) =
  renderGovernanceId itemId ++ " ◇ → ×"
renderSingleHeader
  (impact itemId state (supersededProgress replacement)) =
    renderGovernanceId itemId ++ " ↪ " ++ renderGovernanceRef replacement

renderTableRow : ItemImpact → String
renderTableRow item@(impact itemId state progress) =
  "| **" ++ renderSingleHeader item ++ "** | " ++ renderDescription itemId ++ " |\n"

renderTableRows : List ItemImpact → String
renderTableRows [] = ""
renderTableRows (item ∷ rest) = renderTableRow item ++ renderTableRows rest

renderGithubTableGroup : String → ImpactGroup → String
renderGithubTableGroup heading group with items group
... | [] = ""
... | values =
  "#### " ++ heading ++ " · " ++ primShowNat (count group) ++ "\n\n" ++
  "| GV | Proposition |\n" ++
  "| :---: | --- |\n" ++
  renderTableRows values ++ "\n"

renderDiffRow : TokenStyle → DiffSide → List SemanticSpan → String
renderDiffRow signStyle side spans =
  renderStyled signStyle (ifSign signStyle) ++ "&nbsp;" ++
  renderDiffTokens (compactSpans side false spans)
  where
  ifSign : TokenStyle → String
  ifSign removed = "-"
  ifSign added = "+"
  ifSign plain = " "

renderResolvedGithubSupersededCard :
  SomeGovernanceId → SomeGovernanceId → String
renderResolvedGithubSupersededCard previous current
  with primStringEquality (renderDescription previous) (renderDescription current)
... | true =
    "<div align=\"center\">\n\n" ++
    "| **" ++ renderGovernanceId previous ++ " ↪ " ++
      renderGovernanceId current ++ "** |\n" ++
    "| :---: |\n" ++
    "| *proposition unchanged* |\n" ++
    "| " ++ renderCompactDescription (renderDescription current) ++ " |\n\n" ++
    "</div>\n\n"
... | false =
    "<div align=\"center\">\n\n" ++
    "| **" ++ renderGovernanceId previous ++ " ↪ " ++
      renderGovernanceId current ++ "** |\n" ++
    "| :---: |\n" ++
    "| " ++ renderDiffRow removed oldSide spans ++ " |\n" ++
    "| " ++ renderDiffRow added newSide spans ++ " |\n\n" ++
    "</div>\n\n"
  where
  spans : List SemanticSpan
  spans = semanticDiff (renderDescription previous) (renderDescription current)

renderGithubSupersededCard :
  ReleaseDocument → SomeGovernanceId → GovernanceRef → String
renderGithubSupersededCard document previous replacement
  with lookupGovernanceRef replacement (roadmap document)
... | nothing =
  "<div align=\"center\">\n\n" ++
  "| **" ++ renderGovernanceId previous ++ " ↪ " ++ renderGovernanceRef replacement ++ "** |\n" ++
  "| :---: |\n" ++
  "| " ++ renderDescription previous ++ " |\n\n" ++
  "</div>\n\n"
... | just current = renderResolvedGithubSupersededCard previous current

renderGithubSupersededCards : ReleaseDocument → List ItemImpact → String
renderGithubSupersededCards document [] = ""
renderGithubSupersededCards document
  (impact itemId state (supersededProgress replacement) ∷ rest) =
    renderGithubSupersededCard document itemId replacement ++
    renderGithubSupersededCards document rest
renderGithubSupersededCards document (item ∷ rest) =
  renderGithubSupersededCards document rest

renderGithubSupersededGroup : ReleaseDocument → ImpactGroup → String
renderGithubSupersededGroup document group with items group
... | [] = ""
... | values =
  "#### Superseded · " ++ primShowNat (count group) ++ "\n\n" ++
  renderGithubSupersededCards document values

renderPortableSupersededCard :
  ReleaseDocument → SomeGovernanceId → GovernanceRef → String
renderPortableSupersededCard document previous replacement
  with lookupGovernanceRef replacement (roadmap document)
... | nothing =
  "##### " ++ renderGovernanceId previous ++ " ↪ " ++ renderGovernanceRef replacement ++ "\n\n" ++
  renderDescription previous ++ "\n\n"
... | just current with primStringEquality (renderDescription previous) (renderDescription current)
...   | true =
    "##### " ++ renderGovernanceId previous ++ " ↪ " ++ renderGovernanceId current ++ "\n\n" ++
    "*Proposition unchanged.* " ++ renderDescription current ++ "\n\n"
...   | false =
    "##### " ++ renderGovernanceId previous ++ " ↪ " ++ renderGovernanceId current ++ "\n\n" ++
    "```diff\n- " ++ renderDescription previous ++ "\n+ " ++ renderDescription current ++ "\n```\n\n"

renderPortableSupersededCards : ReleaseDocument → List ItemImpact → String
renderPortableSupersededCards document [] = ""
renderPortableSupersededCards document
  (impact itemId state (supersededProgress replacement) ∷ rest) =
    renderPortableSupersededCard document itemId replacement ++
    renderPortableSupersededCards document rest
renderPortableSupersededCards document (item ∷ rest) =
  renderPortableSupersededCards document rest

renderPortableSupersededGroup : ReleaseDocument → ImpactGroup → String
renderPortableSupersededGroup document group with items group
... | [] = ""
... | values =
  "#### Superseded · " ++ primShowNat (count group) ++ "\n\n" ++
  renderPortableSupersededCards document values

renderGithubRelease : String → ReleaseDocument → String
renderGithubRelease headingPrefix document =
  headingPrefix ++ " " ++ heading document ++ "\n\n" ++
  "**" ++ phaseLabel document ++ ":** " ++ renderPhase document ++ "  \n" ++
  "**" ++ itemsLabel document ++ ":** " ++ renderSummary document ++ "\n\n" ++
  renderGithubTableGroup "Completed" (completedGroup document) ++
  renderGithubTableGroup "Advanced" (advancedGroup document) ++
  renderGithubTableGroup "Introduced" (introducedGroup document) ++
  renderGithubTableGroup "Cancelled" (cancelledGroup document) ++
  renderGithubSupersededGroup document (supersededGroup document) ++
  "<sub>" ++ footer document ++ " `" ++ baseRevision document ++
  ".." ++ headRevision document ++ "`.</sub>\n"

renderPortableRelease : String → ReleaseDocument → String
renderPortableRelease headingPrefix document =
  headingPrefix ++ " " ++ heading document ++ "\n\n" ++
  "**" ++ phaseLabel document ++ ":** " ++ renderPhase document ++ "  \n" ++
  "**" ++ itemsLabel document ++ ":** " ++ renderSummary document ++ "\n\n" ++
  renderGithubTableGroup "Completed" (completedGroup document) ++
  renderGithubTableGroup "Advanced" (advancedGroup document) ++
  renderGithubTableGroup "Introduced" (introducedGroup document) ++
  renderGithubTableGroup "Cancelled" (cancelledGroup document) ++
  renderPortableSupersededGroup document (supersededGroup document) ++
  footer document ++ " `" ++ baseRevision document ++ ".." ++ headRevision document ++ "`.\n"

startMarker : String
startMarker = "<!-- govenv-governance-impact:start -->\n"

endMarker : String
endMarker = "<!-- govenv-governance-impact:end -->\n"

renderBodyMaterialization : Materialization ReleaseDocument → String
renderBodyMaterialization materialization =
  startMarker ++ renderGithubRelease "###" (state materialization) ++ endMarker

renderChangelogMaterialization : Materialization ReleaseDocument → String
renderChangelogMaterialization materialization =
  startMarker ++ renderPortableRelease "###" (state materialization) ++ endMarker

renderGithubReleaseMaterialization : Materialization ReleaseDocument → String
renderGithubReleaseMaterialization materialization =
  startMarker ++ renderGithubRelease "###" (state materialization) ++ endMarker

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
