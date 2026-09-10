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
open import Govenv.Kernel.Assurance
open import Govenv.Kernel.Identifier using (P; GV)
open import Govenv.Kernel.Roadmap using (completionCoverage; _▣; _◇; _✓)

data LegacyCompletion : Nat → Set where
  legacyGV0 : LegacyCompletion 0
  legacyGV1 : LegacyCompletion 1
  legacyGV2 : LegacyCompletion 2
  legacyGV3 : LegacyCompletion 3
  legacyGV4 : LegacyCompletion 4
  legacyGV5 : LegacyCompletion 5
  legacyGV6 : LegacyCompletion 6
  legacyGV15 : LegacyCompletion 15
  legacyGV16 : LegacyCompletion 16
  legacyGV19 : LegacyCompletion 19
  legacyGV20 : LegacyCompletion 20
  legacyGV21 : LegacyCompletion 21
  legacyGV22 : LegacyCompletion 22
  legacyGV44 : LegacyCompletion 44
  legacyGV45 : LegacyCompletion 45
  legacyGV50 : LegacyCompletion 50
  legacyGV51 : LegacyCompletion 51
  legacyGV52 : LegacyCompletion 52
  legacyGV54 : LegacyCompletion 54
  legacyGV60 : LegacyCompletion 60
  legacyGV68 : LegacyCompletion 68
  legacyGV69 : LegacyCompletion 69
  legacyGV70 : LegacyCompletion 70

assurances : List (AssuranceSpec LegacyCompletion)
assurances =
    assures (inherited legacyGV0)
  ∷ assures (inherited legacyGV1)
  ∷ assures (inherited legacyGV2)
  ∷ assures (inherited legacyGV3)
  ∷ assures (inherited legacyGV4)
  ∷ assures (inherited legacyGV5)
  ∷ assures (inherited legacyGV6)
  ∷ assures (inherited legacyGV15)
  ∷ assures (inherited legacyGV16)
  ∷ assures (inherited legacyGV19)
  ∷ assures (inherited legacyGV20)
  ∷ assures (inherited legacyGV21)
  ∷ assures (inherited legacyGV22)
  ∷ assures (inherited legacyGV44)
  ∷ assures (inherited legacyGV45)
  ∷ assures (inherited legacyGV50)
  ∷ assures (inherited legacyGV51)
  ∷ assures (inherited legacyGV52)
  ∷ assures (inherited legacyGV54)
  ∷ assures (inherited legacyGV60)
  ∷ assures (inherited legacyGV68)
  ∷ assures (inherited legacyGV69)
  ∷ assures (inherited legacyGV70)
  ∷ []

pendingNeedsNoAssurance :
  completionCoverage assurances
    ((P 1 "assurance-test" ▣) (GV 71 "assurance-test" ◇)) ≡ true
pendingNeedsNoAssurance = refl

unassuredDoneIsRejected :
  completionCoverage assurances
    ((P 1 "assurance-test" ▣) (GV 71 "assurance-test" ✓)) ≡ false
unassuredDoneIsRejected = refl

legacyMigrationIsPending : migrationComplete assurances ≡ false
legacyMigrationIsPending = refl
```
