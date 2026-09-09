{-# OPTIONS --safe #-}

module Govenv.Kernel.Architecture where

open import Agda.Builtin.List
open import Agda.Builtin.String using (String)

data Role : Set where
  constitution kernel projection adapter generated : Role

record Area : Set where
  constructor area
  field
    root : String
    role : Role

record Dependency : Set where
  constructor allow
  field
    from : Role
    to : Role

record Architecture : Set where
  field
    areas : List Area
    dependencies : List Dependency
