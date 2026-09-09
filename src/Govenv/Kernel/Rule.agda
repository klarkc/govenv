{-# OPTIONS --safe #-}

module Govenv.Kernel.Rule where

open import Govenv.Kernel.Fact
open import Govenv.Kernel.Verdict

record Rule
  (Subject : Set)
  (Observation : Subject → Set)
  (subject : Subject)
  (Diagnostic Obligation : Set)
  : Set where
  field
    check : Fact Subject Observation subject → Verdict Diagnostic Obligation
