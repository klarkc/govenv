# Materialization

Materialization projects governed project data into external or versioned artifacts. Privilege determines how that projection may be applied.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization where

data Application : Set where
  automatic manual : Application

data Privilege : Set where
  repository admin : Privilege

versionedApplication : Application
versionedApplication = automatic

versionedPrivilege : Privilege
versionedPrivilege = repository

adminApplication : Application
adminApplication = manual

adminPrivilege : Privilege
adminPrivilege = admin
```
