{-# OPTIONS --safe #-}

module Govenv.Kernel.Architecture where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Char using (Char; primCharEquality)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.String using
  (String; primStringEquality; primStringToList)

data Role : Set where
  closure constitution kernel materialization projection adapter generated : Role

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

private
  startsWithChars : List Char → List Char → Bool
  startsWithChars [] _ = true
  startsWithChars (_ ∷ _) [] = false
  startsWithChars (x ∷ xs) (y ∷ ys) with primCharEquality x y
  ... | true = startsWithChars xs ys
  ... | false = false

  directoryRootChars : List Char → Bool
  directoryRootChars [] = false
  directoryRootChars (x ∷ []) = primCharEquality x '/'
  directoryRootChars (_ ∷ xs) = directoryRootChars xs

  rootMatches : String → String → Bool
  rootMatches root path with directoryRootChars (primStringToList root)
  ... | true =
    startsWithChars (primStringToList root) (primStringToList path)
  ... | false = primStringEquality root path

pathUnderRoot : String → String → Bool
pathUnderRoot = rootMatches

private
  underAnyRoot : List String → String → Bool
  underAnyRoot [] path = false
  underAnyRoot (root ∷ rest) path with pathUnderRoot root path
  ... | true = true
  ... | false = underAnyRoot rest path

firstOutsideRoots : List String → List String → Maybe String
firstOutsideRoots roots [] = nothing
firstOutsideRoots roots (path ∷ rest) with underAnyRoot roots path
... | true = firstOutsideRoots roots rest
... | false = just path
