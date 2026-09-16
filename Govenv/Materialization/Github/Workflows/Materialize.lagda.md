# Materialize workflow

The Materialize workflow runs from an exact authorized revision on `main`. Its job is gated by the main-only `authorized-materialization` environment, evaluates with a read-only `GITHUB_TOKEN`, and uses only the governed materializer repository credential for Git transport. It derives at most one deterministic materialization commit whose immediate Git parent is its exact causal revision, making provenance stable under rebase rewriting, and passes the resulting effective revision explicitly to post-materialization reusable workflows. Because release publication can advance the latest immutable release boundary after the initial materialization has already been checked, the parent workflow records that boundary before Release, then re-enters the same materializer authority only after Release has completed successfully. Only a boundary advance observed after that verified Release enables post-release rematerialization; if that rematerialization changes `main`, Release is invoked once more against the derived revision so the next candidate is reconciled with the newly canonical `Unreleased` state.

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

recordReleaseBoundaryCommand : String
recordReleaseBoundaryCommand =
  "release_boundary=\"$(git describe --tags --abbrev=0 2>/dev/null || true)\"\necho \"tag=${release_boundary}\" >> \"${GITHUB_OUTPUT}\""

detectReleaseBoundaryAdvanceCommand : String
detectReleaseBoundaryAdvanceCommand =
  "current_boundary=\"$(git describe --tags --abbrev=0 2>/dev/null || true)\"\nif [[ \"${current_boundary}\" == \"${GOVENV_PREVIOUS_RELEASE_BOUNDARY}\" ]]; then\n  advanced=false\nelse\n  advanced=true\nfi\necho \"advanced=${advanced}\" >> \"${GITHUB_OUTPUT}\""

commitCommand : String
commitCommand =
  "git config user.name \"govenv-materializer\"\n" ++
  "git config user.email \"govenv-materializer@users.noreply.github.com\"\n" ++
  "git add --all\n" ++
  "printf '%s\\n' \\\n  'chore(materialize): update governed materializations' \\\n  '' \\\n  '' \\\n  \"Derived-From-Parent: true\" \\\n  'Refs: GV44 GV51 GV90 GV92 GV93' \\\n  'skip-checks: true' > .govenv/materialization-commit-message\n" ++
  "git commit --cleanup=verbatim -F .govenv/materialization-commit-message\n" ++
  "rm .govenv/materialization-commit-message\n" ++
  "git push origin HEAD:main"

changed : String
changed = "steps.drift.outputs.changed == 'true'"

boundaryAdvanced : String
boundaryAdvanced = "steps.boundary.outputs.advanced == 'true'"

postReleaseChanged : String
postReleaseChanged = boundaryAdvanced ++ " && " ++ changed

postReleaseJobCondition : String
postReleaseJobCondition =
  "github.event_name == 'push' && needs.materialize.result == 'success' && needs.release.result == 'success'"

reconcileReleaseCondition : String
reconcileReleaseCondition =
  "needs.post-release-materialize.outputs.changed == 'true'"

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
  ∷ runStep "Record release boundary" (just "release-boundary") nothing
      recordReleaseBoundaryCommand []
  ∷ runStep "Record effective materialized revision" (just "effective") nothing
      effectiveRevisionCommand []
  ∷ []

postReleaseSteps : List Step
postReleaseSteps =
  usesStep "Checkout authorized revision after Release" nothing nothing checkout
    (binding "ref" (expression "needs.materialize.outputs.effective-sha")
    ∷ binding "fetch-depth" (literal "0")
    ∷ binding "persist-credentials" (literal "true")
    ∷ binding "ssh-key" (expression ("secrets." ++ materializerCredentialName))
    ∷ [])
  ∷ runStep "Detect published release boundary advancement" (just "boundary")
      nothing detectReleaseBoundaryAdvanceCommand
      (binding "GOVENV_PREVIOUS_RELEASE_BOUNDARY"
        (expression "needs.materialize.outputs.release-boundary") ∷ [])
  ∷ usesStep "Install Nix" nothing (just boundaryAdvanced) installNix
      (binding "extra-conf" (literal nixExtraConf) ∷ [])
  ∷ usesStep "Cache Nix" nothing (just boundaryAdvanced) cacheNix
      (binding "use-gha-cache" (literal "enabled")
      ∷ binding "use-flakehub" (literal "disabled")
      ∷ [])
  ∷ runStep "Materialize post-release constitution" nothing
      (just boundaryAdvanced) materializeCommand []
  ∷ runStep "Check post-release materialized state" nothing
      (just boundaryAdvanced) checkCommand []
  ∷ runStep "Detect post-release materialization drift" (just "drift")
      (just boundaryAdvanced) detectDriftCommand []
  ∷ runStep "Commit post-release derived materializations" nothing
      (just postReleaseChanged) commitCommand []
  ∷ runStep "Record post-release effective revision" (just "effective") nothing
      effectiveRevisionCommand []
  ∷ []

state : Workflow
state = workflow
  "Materialize"
  (pushBranches (authorizedBranch ∷ []) ∷ workflowDispatch [] ∷ [])
  (just (concurrency "materialize-${{ github.event_name }}" true))
  (job "materialize" materializeJob (just mainDispatchOnly) []
    (binding "effective-sha" (expression "steps.effective.outputs.sha")
    ∷ binding "release-boundary"
        (expression "steps.release-boundary.outputs.tag")
    ∷ [])
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
  ∷ job "post-release-materialize" materializeJob
      (just postReleaseJobCondition) ("materialize" ∷ "release" ∷ [])
      (binding "effective-sha" (expression "steps.effective.outputs.sha")
      ∷ binding "changed" (expression "steps.drift.outputs.changed")
      ∷ [])
      nothing "ubuntu-latest" 15 postReleaseSteps
  ∷ reusableJob "release-reconcile" (just reconcileReleaseCondition)
      ("post-release-materialize" ∷ []) releaseToken
      "./.github/workflows/release.yml"
      (binding "revision"
        (expression "needs.post-release-materialize.outputs.effective-sha") ∷ [])
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
