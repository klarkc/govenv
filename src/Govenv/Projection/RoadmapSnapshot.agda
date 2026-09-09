{-# OPTIONS --safe #-}

module Govenv.Projection.RoadmapSnapshot where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using
  (String; primShowNat; primShowString; primStringAppend)
open import Govenv.Kernel.Identifier using (IdentifierRef)
open import Govenv.Kernel.Release
open import Govenv.Kernel.Roadmap using
  (ItemState; done; todo; cancelled; superseded)
open import Govenv.Materialization using (Materialization)
open Materialization
open import Govenv.Materialization.RoadmapSnapshot using (materialization)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderItemState : ItemState → String
renderItemState done = "done"
renderItemState todo = "todo"
renderItemState cancelled = "cancelled"
renderItemState (superseded replacement) =
  "superseded " ++ primShowNat (IdentifierRef.referenceIndex replacement)

renderPhase : SnapshotPhase → String
renderPhase snapshotAbsent = "phase absent\n"
renderPhase (snapshotActive idx) =
  "phase active " ++ primShowNat idx ++ "\n"
renderPhase (snapshotComplete idx) =
  "phase complete " ++ primShowNat idx ++ "\n"

renderItem : SnapshotItem → String
renderItem (snapshotItem idx phase description itemState) =
  "item " ++ primShowNat idx ++
  " phase " ++ primShowNat phase ++
  " " ++ renderItemState itemState ++
  " " ++ primShowString description ++ "\n"

renderItems : List SnapshotItem → String
renderItems [] = ""
renderItems (item ∷ rest) = renderItem item ++ renderItems rest

renderRoadmapSnapshot : RoadmapSnapshot → String
renderRoadmapSnapshot (roadmapSnapshot phase items) =
  "govenv-roadmap-snapshot-v2\n" ++
  renderPhase phase ++
  renderItems items

renderSnapshot : String
renderSnapshot = renderRoadmapSnapshot (state materialization)
