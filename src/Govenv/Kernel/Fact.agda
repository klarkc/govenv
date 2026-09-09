{-# OPTIONS --safe #-}

module Govenv.Kernel.Fact where

open import Agda.Builtin.List using (List; []; _∷_)

record Fact
  (Subject : Set)
  (Observation : Subject → Set)
  (subject : Subject)
  : Set where
  constructor observed
  field
    observation : Observation subject

data Facts
  (Subject : Set)
  (Observation : Subject → Set)
  : List Subject → Set where
  empty : Facts Subject Observation []
  _∷ᶠ_ :
    {subject : Subject} {subjects : List Subject} →
    Fact Subject Observation subject →
    Facts Subject Observation subjects →
    Facts Subject Observation (subject ∷ subjects)
