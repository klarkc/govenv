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

data RepositoryFileSection : Set where
  releaseGovernanceImpactInChangelog : RepositoryFileSection

data RepositoryFileSectionPlacement : Set where
  afterReleaseHeadingInFile : RepositoryFileSectionPlacement

data GithubPullRequestSection : Set where
  releaseGovernanceImpact : GithubPullRequestSection

data GithubReleaseSection : Set where
  releaseGovernanceImpactInRelease : GithubReleaseSection

data GithubPullRequestBodyPlacement : Set where
  afterReleaseHeadingInBody : GithubPullRequestBodyPlacement

data GithubReleaseBodyPlacement : Set where
  replaceCarriedChangelogSection : GithubReleaseBodyPlacement

data Target : Set where
  repositoryFile : String → Target
  repositoryFileSection :
    String → RepositoryFileSection → RepositoryFileSectionPlacement → Target
  githubRepository : GithubRepositoryProperty → Target
  githubPullRequestBodySection :
    Nat → GithubPullRequestSection → GithubPullRequestBodyPlacement → Target
  githubReleaseBodySection :
    String → GithubReleaseSection → GithubReleaseBodyPlacement → Target

data Verification : Target → Set where
  trackedEquality : {path : String} → Verification (repositoryFile path)
  repositoryFileSectionEquality :
    {path : String} {section : RepositoryFileSection}
    {placement : RepositoryFileSectionPlacement} →
    Verification (repositoryFileSection path section placement)
  readBackEquality : {property : GithubRepositoryProperty} →
    Verification (githubRepository property)
  pullRequestBodySectionEquality :
    {number : Nat} {section : GithubPullRequestSection}
    {placement : GithubPullRequestBodyPlacement} →
    Verification (githubPullRequestBodySection number section placement)
  githubReleaseBodySectionEquality :
    {tag : String} {section : GithubReleaseSection}
    {placement : GithubReleaseBodyPlacement} →
    Verification (githubReleaseBodySection tag section placement)

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
