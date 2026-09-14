# Administrative materialization

Administrative materializations are governed targets whose canonical definitions require permissions broader than normal CI should hold. Their credentials stay behind an explicit manual privilege boundary; adapters only apply and verify governed target state.

## Stage 0 credential bootstrap

The irreducible initial GitHub credential setup is manual because Govenv cannot safely create the credential that authorizes its own first administrative effect:

1. Create the `admin-materialization` environment and add the environment secret `GOVENV_ADMIN_TOKEN`.
2. Create a fine-grained personal access token owned by `klarkc`, restricted to `klarkc/govenv`, with **Administration: read and write** plus **Environments: read**. Administration write is required to materialize repository environments, deployment branch policies, and repository rulesets; Environments read is required only to verify the exact names of environment secrets and variables. Secret values are never read back.
3. Give the token a finite expiration and rotate it before expiry. No normal Test, Materialize, Pages, or Release job may consume this credential.
4. After the governed Stage A `Admin Materialize` workflow is present on an authorized `main`, dispatch the `admin-environment` target from `main` as the first administrative effect. It deterministically restricts `admin-materialization` itself to `main` and verifies the boundary plus the exact credential-name set.

The repository predates step 4: the externally observed `admin-materialization` environment currently contains `GOVENV_ADMIN_TOKEN` but is not branch-restricted. Until the self-hardening target has succeeded, the environment must not be treated as the authorization boundary described below. This is a one-time bootstrap trust window: no automated candidate-authoring principal may receive repository write capability before self-hardening succeeds; only the human authorizer may control writable repository credentials during that interval.

## Stage A executable targets

`Admin Materialize` is manual, target-restricted, checks the authorized repository state before compiling effect adapters, and exposes `GOVENV_ADMIN_TOKEN` only to the selected application step. Its Stage A target set is deliberately limited to:

- `github-description` — apply and read back the canonical repository description;
- `admin-environment` — self-harden the administrative environment to `main`;
- `materializer-environment` — create/verify the main-only `authorized-materialization` boundary and the exact credential names `GOVENV_MATERIALIZER_PRIVATE_KEY` and `GOVENV_MATERIALIZER_CLIENT_ID`;
- `authorized-effects-environment` — create/verify the main-only Release/Pages-build boundary;
- `pages-environment` — create/verify the main-only `github-pages` deployment boundary.

Every target is applied by an Agda adapter derived from a canonical `Govenv.Materialization.*` state, is read back after the effect, and fails unless the governed observable state equals the target. A successful workflow records the constitution SHA, target, repository, workflow run, and read-back-equality result as execution evidence.

Credential values remain irreducibly external. In particular, the materializer environment can be created by Govenv before its private key and client ID exist, but that first application remains incomplete and therefore fails read-back equality until a human provisions the `GOVENV_MATERIALIZER_PRIVATE_KEY` secret and the public `GOVENV_MATERIALIZER_CLIENT_ID` variable; rerunning the same target then verifies the complete governed name boundary. No second semantic state is introduced for this bootstrap transition.

## Candidate authoring boundary

Automated candidate authorship uses the dedicated `govenv-author` GitHub App rather than a credential that acts as the human authorizer. It may write ordinary repository contents and pull requests, but it has no Actions, Workflows, Administration, Pages, or OIDC capability. It is never a bypass actor for `main`; therefore it can propose a candidate but cannot merge or directly create semantic authority. Human interactive authorship may use the human account, but automated agents must not receive that human credential.

## Authorized materializer boundary

GV90 introduces a separate non-admin capability boundary for deterministic post-merge repository materialization. The dedicated `govenv-materializer` GitHub App must be installed only on this repository and needs repository Contents write plus Workflows write capability, but no repository Administration capability. Its private key lives only in the `authorized-materialization` environment.

The App remains private to the owning account. Because a private GitHub App cannot be resolved anonymously by slug before a token exists, its public `client_id` is supplied through the governed `GOVENV_MATERIALIZER_CLIENT_ID` environment variable while the private key remains in `GOVENV_MATERIALIZER_PRIVATE_KEY`. Materialize uses those two values only to mint a short-lived installation token, then verifies that the resulting App slug and capabilities match the governed `govenv-materializer` identity. The environment is restricted to `main`, so candidate pull-request refs cannot obtain the App credential while code already accepted onto `main` may use it for deterministic materialization effects.

## Monotonic authorization rollout

GV91 forbids activating an enforcement before the execution path that must survive it is already authorized and verified. The GitHub rollout is therefore staged:

1. **Stage A — administrative path:** merge the governed Admin Materialize/environment adapters while the legacy repository materializer remains usable; dispatch `admin-environment` from `main` and verify its read-back.
2. **Credential boundary:** create/install `govenv-materializer` with only Contents write + Workflows write, dispatch `materializer-environment` to establish its main-only boundary, provision `GOVENV_MATERIALIZER_PRIVATE_KEY` plus `GOVENV_MATERIALIZER_CLIENT_ID`, and rerun the target until read-back equality succeeds. Establish and verify `authorized-effects` and `github-pages` the same way. No automated candidate-authoring principal receives repository write capability during this stage.
3. **Stage B — authorized workflows:** merge the governed Materialize/Test/Release/Pages workflows. Materialize now evaluates with a read-only `GITHUB_TOKEN` and obtains the Materializer App token only when deterministic tracked drift exists; Release and Pages can run only from the authorized post-Materialize path.
4. **Stage C — main enforcement:** only after Stage B is present on an `AuthorizedRevision` and its prerequisite environments/App identity are read-back verified may the three main rulesets become executable targets and be activated. Their read-back equality must succeed before machine candidate authorship is enabled.
5. **Stage D — candidate automation:** only after Stage C succeeds may `govenv-author` be installed/provisioned for automated agents. Its Contents + Pull requests write capability is then constrained by the already-active main authority ruleset, so it can propose pull requests but cannot directly create semantic authority.

Three independent rulesets define that final enforcement. `govenv-main-authorization` requires a pull request plus the governed `test` check and lets only the materializer App bypass those candidate gates. `govenv-main-authority` restricts default-branch updates to the governed human principal in pull-request-only bypass mode and the materializer App in always-bypass mode, so generic machine credentials with `Contents: write` cannot create authority. `govenv-main-integrity` blocks deletion and non-fast-forward updates with no bypass actor.

The ruleset semantic states, pure projections, identity-resolution plans, effect adapters, and read-back equality logic are already defined locally, but **the rulesets are intentionally not exposed by the Stage A Admin Materialize target list**. Exposing/activating them before Stage B would violate GV91.

```agda
{-# OPTIONS --safe #-}

module Govenv.Administration where

open import Agda.Builtin.String using (String)

adminEnvironment : String
adminEnvironment = "admin-materialization"

adminTokenSecret : String
adminTokenSecret = "GOVENV_ADMIN_TOKEN"

authorizedBranch : String
authorizedBranch = "main"

candidateAuthorAppSlug : String
candidateAuthorAppSlug = "govenv-author"

materializerAppSlug : String
materializerAppSlug = "govenv-materializer"

materializerEnvironment : String
materializerEnvironment = "authorized-materialization"

materializerPrivateKeySecret : String
materializerPrivateKeySecret = "GOVENV_MATERIALIZER_PRIVATE_KEY"

materializerClientIdVariable : String
materializerClientIdVariable = "GOVENV_MATERIALIZER_CLIENT_ID"

materializerBranch : String
materializerBranch = authorizedBranch

authorizedEffectsEnvironment : String
authorizedEffectsEnvironment = "authorized-effects"

pagesEnvironment : String
pagesEnvironment = "github-pages"

authorizationHumanLogin : String
authorizationHumanLogin = "klarkc"
```
