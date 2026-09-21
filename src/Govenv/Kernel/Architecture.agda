{-# OPTIONS --safe #-}

module Govenv.Kernel.Architecture where

open import Agda.Builtin.Reflection using (Name)

data Role : Set where
  governance protocol assurance kernel experiment materialization projection adapter : Role

record Classification : Set where
  constructor classify
  field
    subject : Name
    role : Role

record Dependency : Set where
  constructor allow
  field
    from : Role
    to : Role
