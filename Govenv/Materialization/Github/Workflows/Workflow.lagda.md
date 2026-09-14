# GitHub Actions workflow semantics

Workflow materializations own trigger, job ordering, execution authority, capabilities, action pins, inputs, commands, and environment data. YAML projection owns only representation.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Workflows.Workflow where

open import Agda.Builtin.Bool using (Bool)
open import Agda.Builtin.List using (List)
open import Agda.Builtin.Maybe using (Maybe)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Github.Authorization public using
  (Permission; WorkflowSecurityProfile; WorkflowTokenCapabilities;
   SourceAuthority; EnvironmentGate; none; read; write;
   ungatedCandidate; authorizedEnvironment)

record DispatchInput : Set where
  constructor choiceInput
  field
    identifier : String
    description : String
    required : Bool
    options : List String

data Trigger : Set where
  pushBranches : List String → Trigger
  workflowDispatch : List DispatchInput → Trigger
  pullRequest : Trigger

record ActionPin : Set where
  constructor actionPin
  field
    repository : String
    revision : String
    versionLabel : String

data Value : Set where
  literal : String → Value
  expression : String → Value

record Binding : Set where
  constructor binding
  field
    key : String
    value : Value

data Step : Set where
  usesStep :
    String → Maybe String → Maybe String → ActionPin → List Binding → Step
  runStep :
    String → Maybe String → Maybe String → String → List Binding → Step

record Job : Set where
  constructor job
  field
    identifier : String
    security : WorkflowSecurityProfile
    condition : Maybe String
    runner : String
    timeoutMinutes : Nat
    steps : List Step

record Concurrency : Set where
  constructor concurrency
  field
    group : String
    cancelInProgress : Bool

record Workflow : Set where
  constructor workflow
  field
    name : String
    triggers : List Trigger
    concurrencyPolicy : Maybe Concurrency
    jobs : List Job
```
