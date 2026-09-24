# GV111 stale-target assurance counterexample

The first GV111 assurance accidentally proved the initial editorial choice
`Next = GV112` as if that choice were a permanent invariant of project
direction. Once GV112 is consolidated, legitimate evolution selects GV116 as
Next. An assurance that hard-codes GV112 would therefore reject the very
direction evolution GV111 was created to support.

The repair keeps GV111 assurance structural: exact source binding, typed source
and gap coverage, README/snapshot projection, and vigilance semantics remain
proved, while the selected valid roadmap target is allowed to evolve.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV111.Counterexample.StaleTarget where

open import Agda.Builtin.Bool using (false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.Nat using (Nat; _==_)

initialTargetIndex : Nat
initialTargetIndex = 112

evolvedTargetIndex : Nat
evolvedTargetIndex = 116

hardCodedTargetRejectsLegitimateEvolution :
  (initialTargetIndex == evolvedTargetIndex) ≡ false
hardCodedTargetRejectsLegitimateEvolution = refl
```
