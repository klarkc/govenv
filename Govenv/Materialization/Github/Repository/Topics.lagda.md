# GitHub repository topics materialization

This module is the canonical semantic definition of the GitHub repository
topics. Administrative privilege and read-back verification belong to the
materialization target, while application is automatic after an authorized revision.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Repository.Topics where

open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)
open import Govenv.Materialization
open import Govenv.Project using (topics)

materialization : Materialization (List String)
materialization = materialized
  (githubRepository repositoryTopics)
  authorizedEffectApplication
  adminPrivilege
  adminAuthority
  topicsReadBackSetEquality
  topics
```
