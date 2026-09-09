# GitHub repository description materialization

This module is the canonical semantic definition of the GitHub repository description. Administrative privilege and read-back verification are properties of this materialization target, not decisions introduced by its adapter.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.Description where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization
open import Govenv.Project using (description)

materialization : Materialization String
materialization = materialized
  (githubRepository repositoryDescription)
  adminApplication
  adminPrivilege
  readBackEquality
  description
```
