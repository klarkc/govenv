# Admin Materialize workflow

Administrative effects remain explicit and manual. The workflow is executable only through the main-only administrative environment, validates the governed repository state before exposing the administrative credential, and dispatches only named governed targets.

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
open import Govenv.Materialization.Github.Workflows.Workflow

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

path : String
path = ".github/workflows/admin-materialize.yml"

githubDescriptionTarget : String
githubDescriptionTarget = "github-description"

adminEnvironmentTarget : String
adminEnvironmentTarget = "admin-environment"

materializerEnvironmentTarget : String
materializerEnvironmentTarget = "materializer-environment"

authorizedEffectsEnvironmentTarget : String
authorizedEffectsEnvironmentTarget = "authorized-effects-environment"

pagesEnvironmentTarget : String
pagesEnvironmentTarget = "pages-environment"

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

applyTargetCommand : String
applyTargetCommand =
  "case \"${{ inputs.target }}\" in\n" ++
  "  github-description) nix run github:cachix/devenv/v2.3 -- shell -- .govenv/admin-apply-build/DescriptionApplication ;;\n" ++
  "  admin-environment) nix run github:cachix/devenv/v2.3 -- shell -- .govenv/admin-apply-build/AdminEnvironment ;;\n" ++
  "  materializer-environment) nix run github:cachix/devenv/v2.3 -- shell -- .govenv/admin-apply-build/MaterializerEnvironment ;;\n" ++
  "  authorized-effects-environment) nix run github:cachix/devenv/v2.3 -- shell -- .govenv/admin-apply-build/AuthorizedEffectsEnvironment ;;\n" ++
  "  pages-environment) nix run github:cachix/devenv/v2.3 -- shell -- .govenv/admin-apply-build/PagesEnvironment ;;\n" ++
  "  *)\n" ++
  "    echo \"Unsupported admin materialization: ${{ inputs.target }}\" >&2\n" ++
  "    exit 64\n" ++
  "    ;;\n" ++
  "esac"

mainDispatchOnly : String
mainDispatchOnly = "github.ref == 'refs/heads/main'"

recordEvidenceCommand : String
recordEvidenceCommand =
  "{\n" ++
  "  printf '%s\\n' '### Admin materialization evidence'\n" ++
  "  printf '%s\\n' \"- Constitution: \\`${GITHUB_SHA}\\`\"\n" ++
  "  printf '%s\\n' \"- Target: \\`${{ inputs.target }}\\`\"\n" ++
  "  printf '%s\\n' \"- Repository: \\`${GITHUB_REPOSITORY}\\`\"\n" ++
  "  printf '%s\\n' \"- Workflow run: \\`${GITHUB_RUN_ID}\\`\"\n" ++
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
  ∷ runStep "Apply and verify target" nothing nothing applyTargetCommand
    (binding "GH_TOKEN" (expression ("secrets." ++ adminTokenSecret)) ∷ [])
  ∷ runStep "Record evidence" nothing nothing recordEvidenceCommand []
  ∷ []

state : Workflow
state = workflow
  "Admin Materialize"
  (workflowDispatch
    (choiceInput "target" "Governed admin materialization to apply" true
      (githubDescriptionTarget
      ∷ adminEnvironmentTarget
      ∷ materializerEnvironmentTarget
      ∷ authorizedEffectsEnvironmentTarget
      ∷ pagesEnvironmentTarget
      ∷ []) ∷ [])
  ∷ [])
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
