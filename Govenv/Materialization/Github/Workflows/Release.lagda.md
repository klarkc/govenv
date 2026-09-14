# Release workflow

Release is reusable only from governed callers and receives the exact materialized revision explicitly. The job is gated by the main-only authorized-effects environment, checks that revision before effectful behavior, and has no standalone manual or candidate-ref trigger.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Workflows.Release where

open import Agda.Builtin.Bool using (false; true)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String)
open import Govenv.Administration using (authorizedBranch)
open import Govenv.Github.Authorization using (releaseJob)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Workflows.Workflow

path : String
path = ".github/workflows/release.yml"

checkout : ActionPin
checkout = actionPin "actions/checkout" "d23441a48e516b6c34aea4fa41551a30e30af803" "v6"

installNix : ActionPin
installNix = actionPin "DeterminateSystems/determinate-nix-action" "021c8a1bd3570eb21f5c20a054812b0c4d9ca614" "v3.22.3"

cacheNix : ActionPin
cacheNix = actionPin "DeterminateSystems/magic-nix-cache-action" "908b263ff629f4cc17666315b7fd3ec127c6244d" "v14"

releasePlease : ActionPin
releasePlease = actionPin "googleapis/release-please-action" "45996ed1f6d02564a971a2fa1b5860e934307cf7" "v5.0.0"

nixExtraConf : String
nixExtraConf = "accept-flake-config = true\nsubstituters = https://devenv.cachix.org https://cachix.cachix.org https://cache.nixos.org\nextra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="

checkCommand : String
checkCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:check"

materializePrCommand : String
materializePrCommand = "GOVENV_RELEASE_PR=\"$(jq -r '.number' <<< \"${GOVENV_RELEASE_PR_JSON}\")\"\nif [[ ! \"${GOVENV_RELEASE_PR}\" =~ ^[0-9]+$ ]]; then\n  echo \"Release Please did not return a valid pull request number.\" >&2\n  exit 2\nfi\nexport GOVENV_RELEASE_PR\nbash src/Govenv/Adapter/release-governance-pr.sh"

materializeReleaseCommand : String
materializeReleaseCommand = "bash src/Govenv/Adapter/release-governance-release.sh"

steps : List Step
steps =
  usesStep "Checkout" nothing nothing checkout
    (binding "ref" (expression "inputs.revision")
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
  ∷ usesStep "Release Please" (just "release") nothing releasePlease
    (binding "token" (expression "secrets.GITHUB_TOKEN")
    ∷ binding "config-file" (literal ".github/release-please/config.json")
    ∷ binding "manifest-file" (literal ".github/release-please/manifest.json")
    ∷ [])
  ∷ runStep "Materialize release governance" nothing
      (just "steps.release.outputs.prs_created == 'true'")
      materializePrCommand
      (binding "GH_TOKEN" (expression "secrets.GITHUB_TOKEN")
      ∷ binding "GOVENV_RELEASE_PR_JSON" (expression "steps.release.outputs.pr")
      ∷ [])
  ∷ runStep "Materialize published release governance" nothing
      (just "steps.release.outputs.release_created == 'true'")
      materializeReleaseCommand
      (binding "GH_TOKEN" (expression "secrets.GITHUB_TOKEN")
      ∷ binding "GOVENV_RELEASE_TAG" (expression "steps.release.outputs.tag_name")
      ∷ binding "GOVENV_RELEASE_SHA" (expression "steps.release.outputs.sha")
      ∷ [])
  ∷ []

state : Workflow
state = workflow
  "Release"
  (workflowCall (stringCallInput "revision" true ∷ []) ∷ [])
  (just (concurrency "release" false))
  (job "release-please" releaseJob nothing [] [] nothing
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
