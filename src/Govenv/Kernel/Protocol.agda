{-# OPTIONS --safe #-}

module Govenv.Kernel.Protocol where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Nat using (Nat; zero; suc; _==_)

protocolVigilanceFresh : Bool → Bool → Nat → Nat → Bool
protocolVigilanceFresh false false previous current = current == previous
protocolVigilanceFresh false true previous current = current == zero
protocolVigilanceFresh true false previous current = current == suc previous
protocolVigilanceFresh true true previous current = current == zero

private
  _and_ : Bool → Bool → Bool
  true and right = right
  false and right = false

  reviewEvidenceFresh : Bool → Bool → Bool → Bool
  reviewEvidenceFresh false false false = true
  reviewEvidenceFresh false false true = false
  reviewEvidenceFresh false true true = true
  reviewEvidenceFresh false true false = false
  reviewEvidenceFresh true false true = true
  reviewEvidenceFresh true false false = false
  reviewEvidenceFresh true true true = true
  reviewEvidenceFresh true true false = false

protocolReviewFresh :
  Bool →
  Bool →
  Bool →
  Nat →
  Nat →
  Bool
protocolReviewFresh triggerChanged subjectChanged evidenceChanged previous current =
  protocolVigilanceFresh triggerChanged subjectChanged previous current
    and reviewEvidenceFresh triggerChanged subjectChanged evidenceChanged
