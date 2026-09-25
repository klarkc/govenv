{-# OPTIONS --safe #-}

module Govenv.Kernel.Constitution.Snapshot where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)
open import Data.List.Base using (_++_)
open import Govenv.Kernel.Constitution using
  ( History
  ; HistoryEntry
  ; ValidHistory
  ; Constitution
  ; _▻_
  )
import Govenv.Kernel.Constitution as Constitutional

-- A prefix proof states that the left history is preserved byte-for-byte in
-- constitutional order and that the right history differs only by append-only
-- extension. No equality or interpretation of Proposition Statements is needed:
-- the proof is built from the actual typed History spine.

data HistoryPrefix : History → History → Set₁ where
  samePrefix :
    {history : History} →
    HistoryPrefix history history

  appendPrefix :
    {prefix current : History} →
    HistoryPrefix prefix current →
    (entry : HistoryEntry) →
    HistoryPrefix prefix (current ▻ entry)

prefixEntries :
  {prefix current : History} →
  HistoryPrefix prefix current →
  List HistoryEntry
prefixEntries samePrefix = []
prefixEntries (appendPrefix relation entry) =
  prefixEntries relation ++ (entry ∷ [])

prefixTransitive :
  {first second third : History} →
  HistoryPrefix first second →
  HistoryPrefix second third →
  HistoryPrefix first third
prefixTransitive firstToSecond samePrefix = firstToSecond
prefixTransitive firstToSecond (appendPrefix secondToCurrent entry) =
  appendPrefix (prefixTransitive firstToSecond secondToCurrent) entry

record HistorySnapshot : Set₁ where
  constructor historySnapshot
  field
    sourceRevision : String
    history : History
    validHistory : ValidHistory history

snapshotConstitution : String → Constitution → HistorySnapshot
snapshotConstitution revision current =
  historySnapshot
    revision
    (Constitution.history current)
    (Constitution.validHistory current)

SnapshotPrefixOf : HistorySnapshot → Constitution → Set₁
SnapshotPrefixOf snapshot current =
  HistoryPrefix
    (HistorySnapshot.history snapshot)
    (Constitution.history current)

snapshotPrefixOfSelf :
  (snapshot : HistorySnapshot) →
  SnapshotPrefixOf
    snapshot
    (Constitutional.constitution
      (HistorySnapshot.history snapshot)
      (HistorySnapshot.validHistory snapshot))
snapshotPrefixOfSelf snapshot = samePrefix
