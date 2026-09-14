# Administrative materialization

Administrative authority has one human-supplied root. `GOVENV_ADMIN_TOKEN` is the current credential representing that root; replacing or rotating the token changes the credential, never the identity of the administrative authority. Normal runtime workflows must never consume the root credential.

## Administrative root

The only irreducible human bootstrap is provisioning `GOVENV_ADMIN_TOKEN` into the main-only `admin-materialization` environment. The fine-grained token is repository-restricted and requires **Administration: read/write** plus **Environments: read/write**. It intentionally receives no Actions, Contents, or Workflows permission.

From an `AuthorizedRevision`, `Admin Materialize` uses that root credential to derive and reconcile subordinate authority. No GitHub App, client ID, private key, deploy key, environment secret, variable, ruleset mutation, or individual administrative target may require a second manual provisioning ceremony.

## Convergent setup

GV92 requires the human-facing administrative operation to become one revision-bound `setup`, not a menu of independent targets. Its governed plan owns ordering; adapters only apply, observe, and verify the effects selected by that plan. Re-running setup must converge partially configured external state toward the canonical state for the authorized revision.

Every externally observable step retains apply → read-back → equality semantics. Secret values are not readable through GitHub and therefore are not constitutional data; governance owns their identity, placement, derivation procedure, and observable name boundary.

## Authorized materializer

The GV92/GV93 materializer design uses one repository-scoped write deploy key named `govenv-materializer`. `Admin Materialize` must generate its keypair when provisioning or rotation is required, install the public key as the repository deploy key, and provision the corresponding runtime credential directly into the `authorized-materialization` environment as `GOVENV_MATERIALIZER_SSH_KEY`.

GitHub rulesets grant bypass to the `DeployKey` actor class rather than to one deploy key identifier. Therefore the repository deploy-key set is governed as a closed set containing only the materializer key. Setup removes stale or unauthorized deploy keys and verifies the complete observed set before any DeployKey bypass may become active.

The materializer credential creates no semantic authority: it may apply only deterministic effects causally derived from an `AuthorizedRevision`.

## Candidate authoring

Automated candidate authorship uses the platform-issued per-job `GITHUB_TOKEN` acting as the `github-actions` principal. It receives only ordinary content and pull-request write capabilities for proposing candidate branches and pull requests. The GitHub Actions App does not expose the separate `workflows` permission required to update `.github/workflows`, and Stage C prevents the principal from updating `main`; it receives no administrative, environment, release, Pages, or materializer credential.

No candidate-author secret is provisioned. GitHub mints the ephemeral token for the governed job, so GV92 introduces no second human credential or independent authority. Pull requests created or updated by this token produce `pull_request` validation runs in GitHub's approval-required state; a human may allow those unprivileged validation runs, but that approval is not authorization and creates no `AuthorizedRevision`. Repository Actions workflow permissions remain a governed administrative setting and must be read-back verified before candidate automation is enabled.

## Monotonic rollout

GV91 still controls activation order. Setup may prepare environments and subordinate credentials before stronger rulesets exist, but an enforcement may become active only when every path needed to operate, verify, and repair under it already exists in an `AuthorizedRevision` and its prerequisite capabilities have been read-back verified.

```agda
{-# OPTIONS --safe #-}

module Govenv.Administration where

open import Agda.Builtin.String using (String)

data AdministrativeRoot : Set where
  govenvAdministrativeRoot : AdministrativeRoot

record AdministrativeCredential (root : AdministrativeRoot) : Set where
  constructor administrativeCredential
  field
    secretName : String

adminCredential : AdministrativeCredential govenvAdministrativeRoot
adminCredential = administrativeCredential "GOVENV_ADMIN_TOKEN"

adminTokenSecret : String
adminTokenSecret = AdministrativeCredential.secretName adminCredential

adminEnvironment : String
adminEnvironment = "admin-materialization"

authorizedBranch : String
authorizedBranch = "main"

record DerivedCredential (root : AdministrativeRoot) : Set where
  constructor derivedCredential
  field
    identity : String

materializerCredential : DerivedCredential govenvAdministrativeRoot
materializerCredential = derivedCredential "govenv-materializer"

materializerDeployKeyTitle : String
materializerDeployKeyTitle = DerivedCredential.identity materializerCredential

candidateAuthorIdentity : String
candidateAuthorIdentity = "github-actions"

materializerEnvironment : String
materializerEnvironment = "authorized-materialization"

materializerCredentialName : String
materializerCredentialName = "GOVENV_MATERIALIZER_SSH_KEY"

materializerBranch : String
materializerBranch = authorizedBranch

authorizedEffectsEnvironment : String
authorizedEffectsEnvironment = "authorized-effects"

pagesEnvironment : String
pagesEnvironment = "github-pages"

authorizationHumanLogin : String
authorizationHumanLogin = "klarkc"
```
