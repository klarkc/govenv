# Materialization

Materialization defines canonical semantic target state from governed project data. Projection only encodes that state for a concrete target format, while adapters only observe, apply, or verify effects. Application, privilege, and verification are governed properties of each materialization target.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization where

open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)

data Application : Set where
  automatic manual : Application

data Privilege : Set where
  repository admin : Privilege

data GithubRepositoryProperty : Set where
  repositoryDescription : GithubRepositoryProperty

data GithubPullRequestSection : Set where
  releaseGovernanceImpact : GithubPullRequestSection

data Target : Set where
  repositoryFile : String → Target
  githubRepository : GithubRepositoryProperty → Target
  githubPullRequestBodySection : Nat → GithubPullRequestSection → Target
  githubPullRequestFileSection : Nat → String → GithubPullRequestSection → Target

data Verification : Target → Set where
  trackedEquality : {path : String} → Verification (repositoryFile path)
  readBackEquality : {property : GithubRepositoryProperty} →
    Verification (githubRepository property)
  pullRequestBodySectionEquality : {number : Nat} {section : GithubPullRequestSection} →
    Verification (githubPullRequestBodySection number section)
  pullRequestFileSectionEquality :
    {number : Nat} {path : String} {section : GithubPullRequestSection} →
    Verification (githubPullRequestFileSection number path section)

record Materialization (State : Set) : Set where
  constructor materialized
  field
    target : Target
    application : Application
    privilege : Privilege
    verification : Verification target
    state : State

versionedApplication : Application
versionedApplication = automatic

versionedPrivilege : Privilege
versionedPrivilege = repository

adminApplication : Application
adminApplication = manual

adminPrivilege : Privilege
adminPrivilege = admin
```
