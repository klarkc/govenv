{-# OPTIONS --safe #-}

module Govenv.Kernel.Rule where

open import Govenv.Kernel.Verdict

record Rule (Facts Diagnostic Obligation : Set) : Set where
  field
    check : Facts → Verdict Diagnostic Obligation
