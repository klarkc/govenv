{-# OPTIONS --safe #-}

module Govenv.Kernel.Verdict where

data Verdict (Diagnostic Obligation : Set) : Set where
  holds : Verdict Diagnostic Obligation
  violated : Diagnostic → Verdict Diagnostic Obligation
  unknown : Obligation → Verdict Diagnostic Obligation
