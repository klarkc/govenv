# Admin Materialize workflow

`Admin Materialize` exposes one human-facing administrative operation: `setup`. It is executable only through the main-only administrative environment, validates the governed repository state before exposing the administrative credential, and delegates the ordered Stage A effects to the Agda-projected setup executable. Main rulesets remain outside this setup until Stage B is authorized and verified, preserving GV91.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Workflows.AdminMaterialize where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Administration using
  (adminTokenSecret; authorizedBranch)
open import Govenv.Github.Authorization using (adminMaterializeJob)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Administration.Setup using (setupTarget)
open import Govenv.Materialization.Github.Workflows.Workflow

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

path : String
path = ".github/workflows/admin-materialize.yml"

checkout : ActionPin
checkout = actionPin "actions/checkout" "d23441a48e516b6c34aea4fa41551a30e30af803" "v6"

installNix : ActionPin
installNix = actionPin "DeterminateSystems/determinate-nix-action" "021c8a1bd3570eb21f5c20a054812b0c4d9ca614" "v3.22.3"

cacheNix : ActionPin
cacheNix = actionPin "DeterminateSystems/magic-nix-cache-action" "908b263ff629f4cc17666315b7fd3ec127c6244d" "v14"

nixExtraConf : String
nixExtraConf = "accept-flake-config = true\nsubstituters = https://devenv.cachix.org https://cachix.cachix.org https://cache.nixos.org\nextra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="

checkCommand : String
checkCommand = "nix run github:cachix/devenv/v2.3 -- tasks run govenv:check"

buildAdaptersCommand : String
buildAdaptersCommand =
  "nix run github:cachix/devenv/v2.3 -- tasks run govenv:admin:build"

applySetupCommand : String
applySetupCommand =
  "nix run github:cachix/devenv/v2.3 -- shell -- " ++
  ".govenv/admin-apply-build/Setup"

mainDispatchOnly : String
mainDispatchOnly = "github.ref == 'refs/heads/main'"

recordEvidenceCommand : String
recordEvidenceCommand =
  "{\n" ++
  "  printf '%s\\n' '### Admin materialization evidence'\n" ++
  "  printf '%s\\n' \"- Constitution: \\`${GITHUB_SHA}\\`\"\n" ++
  "  printf '%s\\n' \"- Target: \\`" ++ setupTarget ++ "\\`\"\n" ++
  "  printf '%s\\n' \"- Repository: \\`${GITHUB_REPOSITORY}\\`\"\n" ++
  "  printf '%s\\n' \"- Workflow run: \\`${GITHUB_RUN_ID}\\`\"\n" ++
  "  printf '%s\\n' \"- Actor: \\`${GITHUB_ACTOR}\\`\"\n" ++
  "  printf '%s\\n' '- Expected: `Govenv.Materialization.Github.Administration.Setup.plan`'\n" ++
  "  printf '%s\\n' '- Observed: `all setup steps read-back equal`'\n" ++
  "  printf '%s\\n' \"- Assurance: \\`expected == observed\\`\"\n" ++
  "} >> \"${GITHUB_STEP_SUMMARY}\""

steps : List Step
steps =
  usesStep "Checkout" nothing nothing checkout
    (binding "ref" (expression "github.sha")
    ∷ binding "persist-credentials" (literal "false")
    ∷ [])
  ∷ usesStep "Install Nix" nothing nothing installNix
    (binding "extra-conf" (literal nixExtraConf) ∷ [])
  ∷ usesStep "Cache Nix" nothing nothing cacheNix
    (binding "use-gha-cache" (literal "enabled")
    ∷ binding "use-flakehub" (literal "disabled")
    ∷ [])
  ∷ runStep "Check repository state" nothing nothing checkCommand []
  ∷ runStep "Build admin adapters" nothing nothing buildAdaptersCommand []
  ∷ runStep "Apply and verify setup" nothing nothing applySetupCommand
    (binding "GH_TOKEN" (expression ("secrets." ++ adminTokenSecret)) ∷ [])
  ∷ runStep "Record evidence" nothing nothing recordEvidenceCommand []
  ∷ []

state : Workflow
state = workflow
  "Admin Materialize"
  (workflowDispatch [] ∷ [])
  nothing
  (job "materialize" adminMaterializeJob (just mainDispatchOnly)
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
