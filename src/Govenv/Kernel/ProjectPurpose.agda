{-# OPTIONS --safe #-}

module Govenv.Kernel.ProjectPurpose where

open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)

record ProjectPurposeSnapshot : Set where
  constructor projectPurposeSnapshot
  field
    snapshotPurpose : String
    snapshotReviewRationale : String
    snapshotReviewIndex : Nat
