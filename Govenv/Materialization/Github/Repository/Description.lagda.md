# GitHub repository description materialization

This module is the canonical semantic definition of the GitHub repository description. Administrative privilege and read-back verification are properties of this materialization target, while application is automatic after an authorized revision.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.Description where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization
open import Govenv.Project using (purpose)

materialization : Materialization String
materialization = materialized
  (githubRepository repositoryDescription)
  authorizedEffectApplication
  adminPrivilege
  adminAuthority
  descriptionReadBackEquality
  purpose
```
