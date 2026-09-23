{-# OPTIONS --safe #-}

module Govenv.Kernel.Protocol where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Nat using (Nat; zero; suc; _==_)

protocolVigilanceFresh : Bool → Bool → Nat → Nat → Bool
protocolVigilanceFresh false false previous current = current == previous
protocolVigilanceFresh false true previous current = current == zero
protocolVigilanceFresh true false previous current = current == suc previous
protocolVigilanceFresh true true previous current = current == zero
