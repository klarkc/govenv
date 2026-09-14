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

Automated candidate authorship remains a distinct, unprivileged identity with ordinary content and pull-request capabilities but no authority to merge, bypass `main`, mutate persistent governed external state, or alter executable automation. GV92 forbids solving this boundary with another manually provisioned credential. The concrete platform mechanism remains intentionally abstract until those constraints are mechanically established.

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
candidateAuthorIdentity = "candidate-author"

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
