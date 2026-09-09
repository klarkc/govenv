{-# OPTIONS --safe #-}

module Govenv.Kernel.Fact where

record Fact
  (Subject : Set)
  (Observation : Subject → Set)
  (subject : Subject)
  : Set where
  constructor observed
  field
    observation : Observation subject
