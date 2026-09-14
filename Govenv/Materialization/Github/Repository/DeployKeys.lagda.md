# GitHub repository deploy-key set

Repository deploy keys are governed as a complete set rather than as individually tolerated credentials. This is required because GitHub rulesets identify the bypass actor class `DeployKey`, not one specific key.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.DeployKeys where

open import Agda.Builtin.Bool using (Bool)
open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)

record DeployKeyState : Set where
  constructor deployKeyState
  field
    title : String
    writable : Bool

record DeployKeySet : Set where
  constructor deployKeySet
  field
    keys : List DeployKeyState
```
