# Materialize workflow

The Materialize workflow runs from an exact authorized revision on `main`. Its job is gated by the main-only `authorized-materialization` environment, evaluates with a read-only `GITHUB_TOKEN`, and uses only the governed materializer repository credential for Git transport. It derives at most one deterministic materialization commit, records the exact authorizing revision, and passes the resulting effective revision explicitly to post-materialization reusable workflows.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Workflows.Materialize where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Administration using
  (authorizedBranch; materializerCredentialName)
open import Govenv.Github.Authorization using
  (materializeJob; readOnlyToken; releaseToken; pagesCallToken)
open import Govenv.Materialization
open import Govenv.Materialization.Github.Workflows.Workflow

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

path : String
path = ".github/workflows/materialize.yml"

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

materializeCommand : String
materializeCommand =
  "nix run github:cachix/devenv/v2.3 -- tasks run govenv:materialize"

checkCommand : String
checkCommand =
  "nix run github:cachix/devenv/v2.3 -- tasks run govenv:check"

detectDriftCommand : String
detectDriftCommand =
  "if [[ -z \"$(git status --porcelain)\" ]]; then\n  changed=false\nelse\n  changed=true\nfi\necho \"changed=${changed}\" >> \"${GITHUB_OUTPUT}\""
commitCommand : String
commitCommand =
  "git config user.name \"govenv-materializer\"\n" ++
  "git config user.email \"govenv-materializer@users.noreply.github.com\"\n" ++
  "git add --all\n" ++
  "printf '%s\\n' \\\n  'chore(materialize): update governed materializations' \\\n  '' \\\n  '' \\\n  \"Derived-From-Authorized-Revision: ${GITHUB_SHA}\" \\\n  'Refs: GV44 GV51 GV90 GV92 GV93' \\\n  'skip-checks: true' > .govenv/materialization-commit-message\n" ++
  "git commit --cleanup=verbatim -F .govenv/materialization-commit-message\n" ++
  "rm .govenv/materialization-commit-message\n" ++
  "git push origin HEAD:main"

changed : String
changed = "steps.drift.outputs.changed == 'true'"

mainDispatchOnly : String
mainDispatchOnly =
  "github.event_name != 'workflow_dispatch' || github.ref == 'refs/heads/main'"

publishOnly : String
publishOnly = "github.event_name == 'push'"

effectiveRevisionCommand : String
effectiveRevisionCommand =
  "echo \"sha=$(git rev-parse HEAD)\" >> \"${GITHUB_OUTPUT}\""

steps : List Step
steps =
  usesStep "Checkout authorized revision" nothing nothing checkout
    (binding "ref" (expression "github.sha")
    ∷ binding "fetch-depth" (literal "0")
    ∷ binding "persist-credentials" (literal "true")
    ∷ binding "ssh-key" (expression ("secrets." ++ materializerCredentialName))
    ∷ [])
  ∷ usesStep "Install Nix" nothing nothing installNix
    (binding "extra-conf" (literal nixExtraConf) ∷ [])
  ∷ usesStep "Cache Nix" nothing nothing cacheNix
    (binding "use-gha-cache" (literal "enabled")
    ∷ binding "use-flakehub" (literal "disabled")
    ∷ [])
  ∷ runStep "Materialize constitution" nothing nothing materializeCommand []
  ∷ runStep "Check materialized state" nothing nothing checkCommand []
  ∷ runStep "Detect materialization drift" (just "drift") nothing detectDriftCommand []
  ∷ runStep "Commit derived materializations" nothing (just changed)
      commitCommand []
  ∷ runStep "Record effective materialized revision" (just "effective") nothing
      effectiveRevisionCommand []
  ∷ []

state : Workflow
state = workflow
  "Materialize"
  (pushBranches (authorizedBranch ∷ []) ∷ workflowDispatch [] ∷ [])
  (just (concurrency "materialize-${{ github.event_name }}" true))
  (job "materialize" materializeJob (just mainDispatchOnly) []
    (binding "effective-sha" (expression "steps.effective.outputs.sha") ∷ [])
    nothing "ubuntu-latest" 15 steps
  ∷ reusableJob "test" (just publishOnly) ("materialize" ∷ []) readOnlyToken
      "./.github/workflows/test.yml"
      (binding "revision" (expression "needs.materialize.outputs.effective-sha") ∷ [])
  ∷ reusableJob "release" (just publishOnly) ("materialize" ∷ "test" ∷ []) releaseToken
      "./.github/workflows/release.yml"
      (binding "revision" (expression "needs.materialize.outputs.effective-sha") ∷ [])
  ∷ reusableJob "pages" (just publishOnly) ("materialize" ∷ "test" ∷ []) pagesCallToken
      "./.github/workflows/pages.yml"
      (binding "revision" (expression "needs.materialize.outputs.effective-sha") ∷ [])
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
