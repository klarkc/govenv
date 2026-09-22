# GitHub repository website materialization

This module is the canonical semantic definition of the GitHub repository
website. Administrative privilege and read-back verification belong to the
materialization target, not to its adapter.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.Website where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization
open import Govenv.Project using (website)

materialization : Materialization String
materialization = materialized
  (githubRepository repositoryWebsite)
  adminApplication
  adminPrivilege
  adminAuthority
  websiteReadBackEquality
  website
```
