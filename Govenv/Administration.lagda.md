# Administrative materialization

Administrative materializations are governed projections that require permissions broader than normal CI should hold. Their credentials stay behind an explicit manual privilege boundary.

## Stage 0 setup

The current GitHub bootstrap is intentionally manual:

1. Open the repository **Settings → Environments** and create `admin-materialization`.
2. Add the environment secret `GOVENV_ADMIN_TOKEN`.
3. Create a fine-grained personal access token with **Resource owner** set to `klarkc` and repository access explicitly including `klarkc/govenv`.
4. Grant only **Repository permissions → Administration: read and write** beyond GitHub's implicit minimum metadata access.
5. Give the token a finite expiration and rotate it before expiry. The current repository setup uses a one-year expiration.
6. Prefer protecting the environment with required admin reviewers when repository settings allow it.
7. Run **Actions → Admin Materialize → Run workflow** and select a declared target.

The token must not be exposed to normal Test, Pages, or Release workflows. `Admin Materialize` is the only Stage 0 workflow allowed to consume it.

## Current targets

`github-description` reads the canonical description from `Govenv.Project`, materializes it locally, and applies only that projected value to GitHub repository metadata.

```agda
{-# OPTIONS --safe #-}

module Govenv.Administration where

open import Agda.Builtin.String using (String)

data AdminTarget : Set where
  githubDescription : AdminTarget

adminEnvironment : String
adminEnvironment = "admin-materialization"

adminTokenSecret : String
adminTokenSecret = "GOVENV_ADMIN_TOKEN"
```
