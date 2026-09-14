# GitHub authorization capabilities

GitHub capability profiles project GV90 onto credentials and workflow runtime tokens. Candidate authoring may create ordinary repository content and pull requests, but it cannot alter executable workflow definitions or exercise administrative/publication capabilities. Privileged post-authorization identities and workflow jobs are separate and narrowly scoped.

```agda
{-# OPTIONS --safe #-}

module Govenv.Github.Authorization where

open import Agda.Builtin.String using (String)
open import Govenv.Administration using
  (candidateAuthorAppSlug; materializerAppSlug; adminEnvironment;
   materializerEnvironment; authorizedEffectsEnvironment; pagesEnvironment)

data Permission : Set where
  none read write : Permission

record CredentialCapabilities : Set where
  constructor credentialCapabilities
  field
    contents : Permission
    pullRequests : Permission
    issues : Permission
    actions : Permission
    workflows : Permission
    administration : Permission
    environments : Permission
    pages : Permission

record CredentialProfile : Set where
  constructor credentialProfile
  field
    identity : String
    capabilities : CredentialCapabilities

candidateAuthoring : CredentialProfile
candidateAuthoring = credentialProfile
  candidateAuthorAppSlug
  (credentialCapabilities write write none none none none none none)

materializer : CredentialProfile
materializer = credentialProfile
  materializerAppSlug
  (credentialCapabilities write none none none write none none none)

administrator : CredentialProfile
administrator = credentialProfile
  adminEnvironment
  (credentialCapabilities none none none none none write read none)

record WorkflowTokenCapabilities : Set where
  constructor workflowTokenCapabilities
  field
    actions : Permission
    contents : Permission
    issues : Permission
    pullRequests : Permission
    pages : Permission
    idToken : Permission

data SourceAuthority : Set where
  candidateSource authorizedSource : SourceAuthority

data EnvironmentGate : SourceAuthority → Set where
  ungatedCandidate : EnvironmentGate candidateSource
  authorizedEnvironment : String → EnvironmentGate authorizedSource

record WorkflowSecurityProfile : Set where
  constructor workflowSecurityProfile
  field
    name : String
    sourceAuthority : SourceAuthority
    environmentGate : EnvironmentGate sourceAuthority
    githubToken : WorkflowTokenCapabilities

readOnlyToken : WorkflowTokenCapabilities
readOnlyToken = workflowTokenCapabilities
  none read none none none none

releaseToken : WorkflowTokenCapabilities
releaseToken = workflowTokenCapabilities
  none write write write none none

pagesBuildToken : WorkflowTokenCapabilities
pagesBuildToken = workflowTokenCapabilities
  none read none none read none

pagesDeployToken : WorkflowTokenCapabilities
pagesDeployToken = workflowTokenCapabilities
  none none none none write write

testJob : WorkflowSecurityProfile
testJob = workflowSecurityProfile
  "Test/test" candidateSource ungatedCandidate readOnlyToken

materializeJob : WorkflowSecurityProfile
materializeJob = workflowSecurityProfile
  "Materialize/materialize"
  authorizedSource
  (authorizedEnvironment materializerEnvironment)
  readOnlyToken

releaseJob : WorkflowSecurityProfile
releaseJob = workflowSecurityProfile
  "Release/release-please"
  authorizedSource
  (authorizedEnvironment authorizedEffectsEnvironment)
  releaseToken

pagesBuildJob : WorkflowSecurityProfile
pagesBuildJob = workflowSecurityProfile
  "Pages/build"
  authorizedSource
  (authorizedEnvironment authorizedEffectsEnvironment)
  pagesBuildToken

pagesDeployJob : WorkflowSecurityProfile
pagesDeployJob = workflowSecurityProfile
  "Pages/deploy"
  authorizedSource
  (authorizedEnvironment pagesEnvironment)
  pagesDeployToken

adminMaterializeJob : WorkflowSecurityProfile
adminMaterializeJob = workflowSecurityProfile
  "Admin Materialize/materialize"
  authorizedSource
  (authorizedEnvironment adminEnvironment)
  readOnlyToken
```
