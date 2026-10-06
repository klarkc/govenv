# Materialize workflow

The Materialize workflow runs from an exact authorized revision on `main`; manual dispatch exists only to verify the materializer credential boundary and never invokes publication. It evaluates materializations with a read-only `GITHUB_TOKEN`, derives at most one deterministic materialization commit, records the exact authorizing revision, and passes the resulting effective revision explicitly to post-materialization reusable workflows.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Github.Workflows.Materialize where

open import Agda.Builtin.Bool using (true)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Administration using
  (authorizedBranch; materializerAppSlug; materializerPrivateKeySecret)
open import Govenv.Github.Authorization using
  (materializeJob; materializer; readOnlyToken; releaseToken; pagesCallToken)
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

createAppToken : ActionPin
createAppToken = actionPin
  "actions/create-github-app-token"
  "bcd2ba49218906704ab6c1aa796996da409d3eb1"
  "v3.2.0"

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


resolveAppClientCommand : String
resolveAppClientCommand =
  "client_id=\"$(gh api \"/apps/${EXPECTED_APP_SLUG}\" --jq .client_id)\"\nif [[ -z \"${client_id}\" ]]; then\n  echo \"Unable to resolve client_id for ${EXPECTED_APP_SLUG}.\" >&2\n  exit 1\nfi\necho \"client-id=${client_id}\" >> \"${GITHUB_OUTPUT}\""

verifyAppIdentityCommand : String
verifyAppIdentityCommand =
  "if [[ \"${OBSERVED_APP_SLUG}\" != \"${EXPECTED_APP_SLUG}\" ]]; then\n  echo \"Materializer identity mismatch: expected ${EXPECTED_APP_SLUG}, observed ${OBSERVED_APP_SLUG}.\" >&2\n  exit 1\nfi"

resolveAppUserCommand : String
resolveAppUserCommand =
  "echo \"user-id=$(gh api \"/users/${{ steps.app-token.outputs.app-slug }}[bot]\" --jq .id)\" >> \"${GITHUB_OUTPUT}\""

commitCommand : String
commitCommand =
  "git config user.name \"${{ steps.app-token.outputs.app-slug }}[bot]\"\ngit config user.email \"${{ steps.app-user.outputs.user-id }}+${{ steps.app-token.outputs.app-slug }}[bot]@users.noreply.github.com\"\ngit add --all\nprintf '%s\\n' \\\n  'chore(materialize): update governed materializations' \\\n  '' \\\n  '' \\\n  \"Derived-From-Authorized-Revision: ${GITHUB_SHA}\" \\\n  'Refs: GV44 GV51 GV90' \\\n  'skip-checks: true' > .govenv/materialization-commit-message\ngit commit --cleanup=verbatim -F .govenv/materialization-commit-message\nrm .govenv/materialization-commit-message\ngit push \"https://x-access-token:${GH_TOKEN}@github.com/${GITHUB_REPOSITORY}.git\" HEAD:main"

changed : String
changed = "steps.drift.outputs.changed == 'true'"

credentialRequired : String
credentialRequired =
  "steps.drift.outputs.changed == 'true' || github.event_name == 'workflow_dispatch'"

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
  usesStep "Checkout" nothing nothing checkout
    (binding "ref" (expression "github.sha")
    ∷ binding "fetch-depth" (literal "0")
    ∷ binding "persist-credentials" (literal "false")
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
  ∷ verifyGithubAppProfileStep "Verify materializer App capabilities" nothing materializer
  ∷ runStep "Resolve materializer App" (just "app-identity") (just credentialRequired)
      resolveAppClientCommand
      (binding "EXPECTED_APP_SLUG" (literal materializerAppSlug)
      ∷ binding "GH_TOKEN" (expression "github.token")
      ∷ [])
  ∷ usesStep "Create materializer token" (just "app-token") (just credentialRequired) createAppToken
    (binding "client-id" (expression "steps.app-identity.outputs.client-id")
    ∷ binding "private-key" (expression ("secrets." ++ materializerPrivateKeySecret))
    ∷ binding "repositories" (expression "github.repository")
    ∷ binding "permission-contents" (literal "write")
    ∷ binding "permission-workflows" (literal "write")
    ∷ [])
  ∷ runStep "Verify materializer identity" nothing (just credentialRequired)
      verifyAppIdentityCommand
      (binding "EXPECTED_APP_SLUG" (literal materializerAppSlug)
      ∷ binding "OBSERVED_APP_SLUG" (expression "steps.app-token.outputs.app-slug")
      ∷ [])
  ∷ verifyGithubAppTokenScopeStep "Verify materializer token scope"
      (just credentialRequired)
      (expression "steps.app-token.outputs.token")
      currentRepositoryOnly
  ∷ runStep "Resolve materializer identity" (just "app-user") (just changed)
      resolveAppUserCommand
      (binding "GH_TOKEN" (expression "steps.app-token.outputs.token") ∷ [])
  ∷ runStep "Commit derived materializations" nothing (just changed)
      commitCommand
      (binding "GH_TOKEN" (expression "steps.app-token.outputs.token") ∷ [])
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
  ∷ reusableJob "release" (just publishOnly) ("materialize" ∷ []) releaseToken
      "./.github/workflows/release.yml"
      (binding "revision" (expression "needs.materialize.outputs.effective-sha") ∷ [])
  ∷ reusableJob "pages" (just publishOnly) ("materialize" ∷ []) pagesCallToken
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
