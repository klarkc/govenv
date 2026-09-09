{-# OPTIONS --safe #-}

module Govenv.Kernel.Rule where

open import Agda.Builtin.List using (List)
open import Govenv.Kernel.Fact
open import Govenv.Kernel.Verdict

record Rule
  (Subject : Set)
  (Observation : Subject → Set)
  (dependencies : List Subject)
  (Diagnostic Obligation : Set)
  : Set where
  field
    check : Facts Subject Observation dependencies → Verdict Diagnostic Obligation
