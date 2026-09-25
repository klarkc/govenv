# GV116 history-prefix snapshot assurance

This assurance establishes the typed snapshot boundary needed before release and
roadmap materializations can stop comparing stored `ItemState`. A
`HistorySnapshot` freezes a valid constitutional prefix at a revision, while
`HistoryPrefix` proves that a later Constitution was obtained only by appending
history entries.

The suffix is recovered directly from that prefix proof. It therefore contains
the exact constitutional events since the snapshot rather than a reconstructed
state diff.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV116.Snapshot where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Product.Base using (_,_)
open import Relation.Nullary.Decidable using (from-yes)
open import Govenv.Kernel.Identifier using (P; GV; GVR)
open import Govenv.Kernel.Constitution
open import Govenv.Kernel.Constitution.Snapshot

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

g1 : GovernanceDeclaration
g1 =
  governanceDeclaration
    (GV 1 "snapshot contract")
    (P 1 "snapshot phase")
    []

h1 : History
h1 = ε ▻ declare g1

h1Valid : ValidHistory h1
h1Valid =
  extend
    empty
    (declare g1)
    (from-yes (entryReady? ε (declare g1)) , tt)

c1 : Constitution
c1 = constitution h1 h1Valid

p10 : Proposition 10
p10 = prop 10

proposal10 : PropositionDeclaration
proposal10 =
  propositionDeclaration (GVR 1) (someProposition p10)

h2 : History
h2 = h1 ▻ propose proposal10

h2Valid : ValidHistory h2
h2Valid =
  extend
    h1Valid
    (propose proposal10)
    (from-yes (entryReady? h1 (propose proposal10)) , tt)

e10 : Establishment
e10 = establishment 10

h3 : History
h3 = h2 ▻ establish e10

h3Valid : ValidHistory h3
h3Valid =
  extend
    h2Valid
    (establish e10)
    (from-yes (entryReady? h2 (establish e10)) , tt)

current : Constitution
current = constitution h3 h3Valid

snapshot : HistorySnapshot
snapshot = snapshotConstitution "revision-1" c1

snapshotRevisionPreserved :
  HistorySnapshot.sourceRevision snapshot ≡ "revision-1"
snapshotRevisionPreserved = refl

snapshotHistoryPreserved :
  HistorySnapshot.history snapshot ≡ h1
snapshotHistoryPreserved = refl

proposalPrefix : HistoryPrefix h1 h2
proposalPrefix =
  appendPrefix samePrefix (propose proposal10)

establishmentPrefix : HistoryPrefix h2 h3
establishmentPrefix =
  appendPrefix samePrefix (establish e10)

snapshotToCurrent : SnapshotPrefixOf snapshot current
snapshotToCurrent =
  prefixTransitive proposalPrefix establishmentPrefix

suffixIsExactConstitutionalEvents :
  prefixEntries snapshotToCurrent ≡
    propose proposal10 ∷ establish e10 ∷ []
suffixIsExactConstitutionalEvents = refl

snapshotRemainsValidConstitutionalPrefix :
  SnapshotPrefixOf
    snapshot
    (constitution
      (HistorySnapshot.history snapshot)
      (HistorySnapshot.validHistory snapshot))
snapshotRemainsValidConstitutionalPrefix =
  snapshotPrefixOfSelf snapshot

-- Prefix composition is structural. An intermediate authorization boundary can
-- be inserted without changing the eventual suffix relation.

composedPrefix : HistoryPrefix h1 h3
composedPrefix =
  prefixTransitive proposalPrefix establishmentPrefix

composedSuffixIsExact :
  prefixEntries composedPrefix ≡
    propose proposal10 ∷ establish e10 ∷ []
composedSuffixIsExact = refl
```
