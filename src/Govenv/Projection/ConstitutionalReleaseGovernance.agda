{-# OPTIONS --safe #-}

module Govenv.Projection.ConstitutionalReleaseGovernance where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; zero; suc)
open import Agda.Builtin.String using
  (String; primShowNat; primStringAppend)
open import Govenv.Kernel.Identifier using
  ( GovernanceRef; SomeGovernanceId; SomePhaseId
  ; IdentifierRef; indexOf; descriptionOf; someIdentifier
  )
open import Govenv.Kernel.Constitution using
  ( Disposition
  ; PropositionDisposition
  ; preserved
  ; abandoned
  ; withdrawn
  ; reformulated
  )
open import Govenv.Kernel.Constitution.Release
open ConstitutionalDelta
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.ConstitutionalReleaseGovernance
open ConstitutionalReleaseDocument

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

private
  renderGovernanceRef : GovernanceRef → String
  renderGovernanceRef governance =
    "GV" ++ primShowNat (IdentifierRef.referenceIndex governance)

  renderGovernanceId : SomeGovernanceId → String
  renderGovernanceId (someIdentifier governance) =
    "GV" ++ primShowNat (indexOf governance)

  renderGovernanceDescription : SomeGovernanceId → String
  renderGovernanceDescription (someIdentifier governance) =
    descriptionOf governance

  renderPhaseId : SomePhaseId → String
  renderPhaseId (someIdentifier phase) =
    "P" ++ primShowNat (indexOf phase)

  renderPhaseDescription : SomePhaseId → String
  renderPhaseDescription (someIdentifier phase) =
    descriptionOf phase

  renderNatList : String → List Nat → String
  renderNatList prefix [] = "none"
  renderNatList prefix (value ∷ rest) =
    prefix ++ primShowNat value ++ renderNatTail rest
    where
    renderNatTail : List Nat → String
    renderNatTail [] = ""
    renderNatTail (next ∷ values) =
      ", " ++ prefix ++ primShowNat next ++ renderNatTail values

  renderDispositionValue : Disposition → String
  renderDispositionValue preserved = "preserved"
  renderDispositionValue abandoned = "abandoned"
  renderDispositionValue withdrawn = "withdrawn"
  renderDispositionValue (reformulated targets) =
    "reformulated → " ++ renderNatList "Prop" targets

  renderDisposition : PropositionDisposition → String
  renderDisposition item =
    "Prop" ++
    primShowNat (PropositionDisposition.propositionIndex item) ++
    " " ++
    renderDispositionValue (PropositionDisposition.disposition item)

  renderDispositions : List PropositionDisposition → String
  renderDispositions [] = "none"
  renderDispositions (item ∷ rest) =
    renderDisposition item ++ renderDispositionTail rest
    where
    renderDispositionTail : List PropositionDisposition → String
    renderDispositionTail [] = ""
    renderDispositionTail (next ∷ values) =
      "; " ++ renderDisposition next ++ renderDispositionTail values

  countImpacts : List ConstitutionalImpact → Nat
  countImpacts [] = zero
  countImpacts (_ ∷ rest) = suc (countImpacts rest)

renderPhaseProgress : ConstitutionalPhaseProgress → String
renderPhaseProgress (currentUnchanged nothing) =
  "unchanged · no Current phase"
renderPhaseProgress (currentUnchanged (just current)) =
  "▣ " ++ renderPhaseId current ++ " — unchanged"
renderPhaseProgress (currentIntroduced current) =
  "+ ▣ " ++ renderPhaseId current ++
  " — " ++ renderPhaseDescription current
renderPhaseProgress (currentAdvanced previous current) =
  "■ " ++ renderPhaseId previous ++
  " → ▣ " ++ renderPhaseId current
renderPhaseProgress (roadmapCompleted previous) =
  "■ " ++ renderPhaseId previous ++ " → ■ roadmap complete"

renderImpact : ConstitutionalImpact → String
renderImpact (phaseIdentityIntroduced phase) =
  "- **+ " ++ renderPhaseId phase ++
  "** — phase identity · " ++ renderPhaseDescription phase ++ "\n"
renderImpact (governanceIntroduced governance phase) =
  "- **+ " ++ renderGovernanceId governance ++
  "** @ " ++ renderPhaseId phase ++
  " — " ++ renderGovernanceDescription governance ++ "\n"
renderImpact (propositionEstablished governance proposition) =
  "- **" ++ renderGovernanceRef governance ++
  "** · Prop" ++ primShowNat proposition ++ " established\n"
renderImpact (propositionAbandoned governance proposition) =
  "- **" ++ renderGovernanceRef governance ++
  "** · Prop" ++ primShowNat proposition ++ " abandoned\n"
renderImpact
  (governanceSuperseded
    previous successor establishments dispositions) =
  "- **" ++ renderGovernanceRef previous ++
  " ↪ " ++ renderGovernanceRef successor ++
  "** · establishments: " ++ renderNatList "Prop" establishments ++
  " · dispositions: " ++ renderDispositions dispositions ++ "\n"

renderImpacts : List ConstitutionalImpact → String
renderImpacts [] = ""
renderImpacts (impact ∷ rest) =
  renderImpact impact ++ renderImpacts rest

renderImpactSummary : List ConstitutionalImpact → String
renderImpactSummary [] = "no constitutional governance impact"
renderImpactSummary impacts =
  primShowNat (countImpacts impacts) ++
  " constitutional event impact(s)"

renderRelease : String → ConstitutionalReleaseDocument → String
renderRelease headingPrefix document =
  headingPrefix ++ " " ++ heading document ++ "\n\n" ++
  "**" ++ phaseLabel document ++ ":** " ++
    renderPhaseProgress (phaseProgress (delta document)) ++ "  \n" ++
  "**" ++ impactsLabel document ++ ":** " ++
    renderImpactSummary (impacts (delta document)) ++ "\n\n" ++
  renderImpacts (impacts (delta document)) ++
  "<sub>" ++ footer document ++
  " `" ++ baseRevision document ++
  ".." ++ headRevision document ++ "`.</sub>\n"

startMarker : String
startMarker = "<!-- govenv-governance-impact:start -->\n"

endMarker : String
endMarker = "<!-- govenv-governance-impact:end -->\n"

renderBodyMaterialization :
  Materialization ConstitutionalReleaseDocument →
  String
renderBodyMaterialization materialization =
  startMarker ++
  renderRelease "###" (state materialization) ++
  endMarker

renderPortableSection :
  ConstitutionalReleaseDocument →
  String
renderPortableSection document =
  startMarker ++
  renderRelease "###" document ++
  endMarker

renderError : ConstitutionalDeltaError → String
renderError (missingResponsibleGovernance proposition) =
  "constitutional release delta could not resolve GovernanceId responsibility for Prop" ++
  primShowNat proposition
