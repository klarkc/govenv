# AGENTS materialization

`AGENTS.md` is the versioned projection of `Govenv.Protocol`. It has
no independent semantic authority and manual divergence must fail repository
validation.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Agents where

open import Agda.Builtin.String using (String)
open import Govenv.Materialization
open import Govenv.Protocol using (document)

materialization : Materialization String
materialization = materialized
  (repositoryFile "AGENTS.md")
  versionedApplication
  versionedPrivilege
  versionedAuthority
  trackedEquality
  document
```
