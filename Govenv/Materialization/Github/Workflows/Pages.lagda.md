# Pages workflow

Pages is reusable only from governed callers and receives the exact materialized revision explicitly. Because its build executes the canonical repository check and release governance reconstructs immutable history from published tags, checkout observes full Git history before validation. Build runs behind the authorized-effects boundary with read-only repository access plus Pages metadata read; deployment is a separate job gated by the `github-pages` environment with only Pages and OIDC write capabilities.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Workflows.Pages where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String)
open import Govenv.Administration using (authorizedBranch)
open import Govenv.Github.Authorization using (pagesBuildJob; pagesDeployJob)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Workflows.Workflow

path : String
path = ".github/workflows/pages.yml"

checkout : ActionPin
checkout = actionPin "actions/checkout" "d23441a48e516b6c34aea4fa41551a30e30af803" "v6"

installNix : ActionPin
installNix = actionPin "DeterminateSystems/determinate-nix-action" "021c8a1bd3570eb21f5c20a054812b0c4d9ca614" "v3.22.3"

cacheNix : ActionPin
cacheNix = actionPin "DeterminateSystems/magic-nix-cache-action" "908b263ff629f4cc17666315b7fd3ec127c6244d" "v14"

configurePages : ActionPin
configurePages = actionPin "actions/configure-pages" "983d7736d9b0ae728b81ab479565c72886d7745b" "v5"

uploadPages : ActionPin
uploadPages = actionPin "actions/upload-pages-artifact" "7b1f4a764d45c48632c6b24a0339c27f5614fb0b" "v4"

deployPages : ActionPin
deployPages = actionPin "actions/deploy-pages" "d6db90164ac5ed86f2b6aed7e0febac5b3c0c03e" "v4"

nixExtraConf : String
nixExtraConf = "accept-flake-config = true\nsubstituters = https://devenv.cachix.org https://cachix.cachix.org https://cache.nixos.org\nextra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="

checkCommand : String
checkCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:check"

docsCommand : String
docsCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs"

buildSteps : List Step
buildSteps =
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
  ∷ runStep "Build documentation" nothing nothing docsCommand []
  ∷ usesStep "Configure Pages" nothing nothing configurePages []
  ∷ usesStep "Upload Pages artifact" nothing nothing uploadPages
    (binding "path" (literal "_site") ∷ [])
  ∷ []

deploySteps : List Step
deploySteps =
  usesStep "Deploy to GitHub Pages" (just "deployment") nothing deployPages [] ∷ []

state : Workflow
state = workflow
  "Pages"
  (workflowCall (stringCallInput "revision" true ∷ []) ∷ [])
  (just (concurrency "pages" true))
  (job "build" pagesBuildJob nothing [] [] nothing
    "ubuntu-latest" 15 buildSteps
  ∷ job "deploy" pagesDeployJob nothing
    ("build" ∷ []) [] (just (expression "steps.deployment.outputs.page_url"))
    "ubuntu-latest" 15 deploySteps
  ∷ [])

materialization : Materialization Workflow
materialization = materialized
  (repositoryFile path)
  versionedApplication
  versionedPrivilege
  versionedAuthority
  trackedEquality
  state
```
