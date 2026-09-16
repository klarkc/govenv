# Test workflow

The Test workflow is the only workflow intentionally allowed to execute candidate repository state. Its token is read-only and it has no privileged environment. Whenever a reusable caller supplies an explicit revision, that revision takes precedence over the inherited GitHub event context; direct pull-request execution otherwise checks the exact pull-request head, and standalone dispatch falls back to the triggering revision.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Workflows.Test where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String)
open import Govenv.Github.Authorization using (testJob)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Workflows.Workflow

path : String
path = ".github/workflows/test.yml"

checkout : ActionPin
checkout = actionPin
  "actions/checkout"
  "d23441a48e516b6c34aea4fa41551a30e30af803"
  "v6"

installNix : ActionPin
installNix = actionPin
  "DeterminateSystems/determinate-nix-action"
  "021c8a1bd3570eb21f5c20a054812b0c4d9ca614"
  "v3.22.3"

cacheNix : ActionPin
cacheNix = actionPin
  "DeterminateSystems/magic-nix-cache-action"
  "908b263ff629f4cc17666315b7fd3ec127c6244d"
  "v14"

nixExtraConf : String
nixExtraConf = "accept-flake-config = true\nsubstituters = https://devenv.cachix.org https://cachix.cachix.org https://cache.nixos.org\nextra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="

checkoutRef : String
checkoutRef = "inputs.revision != '' && inputs.revision || github.event_name == 'pull_request' && github.event.pull_request.head.sha || github.sha"

checkCommand : String
checkCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:check"

testCommand : String
testCommand = "nix run github:cachix/devenv/v2.3 -- test"

steps : List Step
steps =
  usesStep "Checkout" nothing nothing checkout
    (binding "ref" (expression checkoutRef)
    ∷ binding "fetch-depth" (literal "0")
    ∷ binding "persist-credentials" (literal "false")
    ∷ [])
  ∷ usesStep "Install Nix" nothing nothing installNix
    (binding "extra-conf" (literal nixExtraConf) ∷ [])
  ∷ usesStep "Cache Nix" nothing nothing cacheNix
    (binding "use-gha-cache" (literal "enabled")
    ∷ binding "use-flakehub" (literal "disabled")
    ∷ [])
  ∷ runStep "Check repository state" nothing nothing checkCommand []
  ∷ runStep "Run tests" nothing nothing testCommand []
  ∷ []

state : Workflow
state = workflow
  "Test"
  (pullRequest ∷ workflowDispatch [] ∷ workflowCall (stringCallInput "revision" true ∷ []) ∷ [])
  (just (concurrency "test-${{ github.workflow }}-${{ github.ref }}" true))
  (job "test" testJob nothing [] [] nothing
    "ubuntu-latest" 15 steps ∷ [])

materialization : Materialization Workflow
materialization = materialized
  (repositoryFile path)
  versionedApplication
  versionedPrivilege
  versionedAuthority
  trackedEquality
  state
```
