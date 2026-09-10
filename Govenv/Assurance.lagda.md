# Governance assurance

Governance completion is not an editorial checkbox. Completed governance must be backed by an assurance mechanism. Historical completions that predate evidence-bearing lifecycle semantics are explicitly enumerated as inherited migration debt; no pending or future governance identity can use that escape hatch.

Static assurances carry an Agda proposition and proof. Observed assurances carry a governed `Rule` whose verdict must be established from candidate-state facts. GV74 remains pending until every inherited completion has been migrated and candidate validation requires all live completed assurances to hold.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat)
import Govenv.Assurance.GV3 as GV3
import Govenv.Assurance.GV4 as GV4
import Govenv.Assurance.GV5 as GV5
import Govenv.Assurance.GV6 as GV6
import Govenv.Assurance.GV15 as GV15
import Govenv.Assurance.GV16 as GV16
import Govenv.Assurance.GV20 as GV20
import Govenv.Assurance.GV21 as GV21
import Govenv.Assurance.GV50 as GV50
import Govenv.Assurance.GV52 as GV52
import Govenv.Assurance.GV54 as GV54
import Govenv.Assurance.GV68 as GV68
import Govenv.Assurance.GV69 as GV69
import Govenv.Assurance.GV70 as GV70
open import Govenv.Kernel.Assurance
open import Govenv.Kernel.Identifier using (P; GV)
open import Govenv.Kernel.Roadmap using (Roadmap; roadmapOf; _▣; _◇; _✓)
open import Govenv.Roadmap using (roadmap)

data LegacyCompletion : Nat → Set where
  legacyGV0 : LegacyCompletion 0
  legacyGV1 : LegacyCompletion 1
  legacyGV2 : LegacyCompletion 2
  legacyGV19 : LegacyCompletion 19
  legacyGV22 : LegacyCompletion 22
  legacyGV44 : LegacyCompletion 44
  legacyGV45 : LegacyCompletion 45
  legacyGV51 : LegacyCompletion 51
  legacyGV60 : LegacyCompletion 60

assurances : List (AssuranceSpec LegacyCompletion)
assurances =
    assures (inherited legacyGV0)
  ∷ assures (inherited legacyGV1)
  ∷ assures (inherited legacyGV2)
  ∷ assures (statically GV3.evidence)
  ∷ assures (statically GV4.evidence)
  ∷ assures (statically GV5.evidence)
  ∷ assures (statically GV6.evidence)
  ∷ assures (statically GV15.evidence)
  ∷ assures (statically GV16.evidence)
  ∷ assures (inherited legacyGV19)
  ∷ assures (statically GV20.evidence)
  ∷ assures (statically GV21.evidence)
  ∷ assures (inherited legacyGV22)
  ∷ assures (inherited legacyGV44)
  ∷ assures (inherited legacyGV45)
  ∷ assures (statically GV50.evidence)
  ∷ assures (inherited legacyGV51)
  ∷ assures (statically GV52.evidence)
  ∷ assures (statically GV54.evidence)
  ∷ assures (inherited legacyGV60)
  ∷ assures (statically GV68.evidence)
  ∷ assures (statically GV69.evidence)
  ∷ assures (statically GV70.evidence)
  ∷ []

pendingRoadmap : Roadmap
pendingRoadmap = roadmapOf
  ((P 1 "assurance-test" ▣) (GV 71 "assurance-test" ◇))

unassuredDoneRoadmap : Roadmap
unassuredDoneRoadmap = roadmapOf
  ((P 1 "assurance-test" ▣) (GV 71 "assurance-test" ✓))

pendingNeedsNoAssurance :
  completionCoverage assurances pendingRoadmap ≡ true
pendingNeedsNoAssurance = refl

unassuredDoneIsRejected :
  completionCoverage assurances unassuredDoneRoadmap ≡ false
unassuredDoneIsRejected = refl

projectCompletionCovered : completionCoverage assurances roadmap ≡ true
projectCompletionCovered = refl

legacyMigrationIsPending : migrationComplete assurances ≡ false
legacyMigrationIsPending = refl
```
