<!-- Generated from Govenv.Readme. Do not edit manually. -->

<h1 align="center">Govenv</h1>

<p align="center">
  <strong>A type system for your repository. Formally define what your project is allowed to become.</strong>
</p>

<p align="center">
  <a href="https://klarkc.github.io/govenv/"><img src="https://img.shields.io/badge/docs-pages-brightgreen" alt="Docs" /></a>
  <img src="https://img.shields.io/badge/agda-2.8.0-blueviolet" alt="Agda 2.8.0" />
  <a href="https://github.com/klarkc/govenv/releases"><img src="https://img.shields.io/github/v/release/klarkc/govenv?display_name=tag&sort=semver" alt="Release" /></a>
  <img src="https://img.shields.io/badge/license-Apache--2.0-blue" alt="Apache-2.0" />
</p>

## Roadmap

**Current:** P1 — Formal governance kernel. `Verdict`, typed `Fact`, and dependency-indexed `Rule` are in place; the roadmap release rule and Govenv's first self-governing repository rule are next.

> This roadmap is subject to change as Govenv's architecture evolves. IDs are intended to remain stable references whenever practical.

<details>
<summary>☑ <strong>P0 — Bootstrap and project shape</strong></summary>

- [x] **GV0** Literate `Govenv.lagda.md` closure root.
- [x] **GV1** Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`.
- [x] **GV2** Reproducible Stage 0 bootstrap, documentation site, and automated releases.

</details>

<details open>
<summary>☐ <strong>P1 — Formal governance kernel</strong> ← current</summary>

- [x] **GV3** `Verdict`: `holds`, `violated`, and `unknown`.
- [x] **GV4** Minimal `Rule` abstraction.
- [x] **GV5** Typed repository facts.
- [x] **GV6** Dependency-indexed rules.
- [ ] **GV7** Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt.
- [ ] **GV8** Encode GV7 as Govenv's first self-governing repository rule.
- [ ] **GV9** Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration.
- [ ] **GV10** Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention.
- [ ] **GV11** Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified.
- [ ] **GV12** CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change.
- [ ] **GV13** CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change.
- [x] **GV14** Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check.
- [x] **GV15** Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible.
- [x] **GV16** Materialize governed README sections from Agda rather than maintaining duplicate prose by hand.
- [ ] **GV17** Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts.
- [ ] **GV18** Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations.
- [x] **GV19** Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing.
- [x] **GV20** Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity.
- [x] **GV21** Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations.
- [x] **GV22** Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow.
- [ ] **GV23** Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries.
- [ ] **GV24** CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution.
- [ ] **GV44** Automatically apply versioned non-admin materializations on `main` using only repository-scoped CI permission; validation and publication workflows run after Materialize completes, while admin materializations remain manual.
- [ ] **GV45** Require every admin materialization to read the target back after applying it, fail unless the observed value equals the governed expected value, and emit execution evidence tied to the constitution SHA, target, repository, and workflow run.
- [ ] **GV46** Model admin materialization evidence as typed governed data that can be consumed by a formal rule or assurance check rather than relying on workflow success alone.

</details>

<details>
<summary>☐ <strong>P2 — Pure repository evaluator</strong></summary>

- [ ] **GV25** Evaluate facts, rules, verdicts, obligations, and diagnostics without IO.

</details>

<details>
<summary>☐ <strong>P3 — `govenv check` and commit governance</strong></summary>

- [ ] **GV26** Observe repository facts through a thin impure adapter.
- [ ] **GV27** Produce source-mapped governance diagnostics from the pure kernel.
- [ ] **GV28** Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer.
- [ ] **GV29** Validate the staged candidate repository state using the candidate governance before accepting a commit.
- [ ] **GV30** Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly.

</details>

<details>
<summary>☐ <strong>P4 — Incremental governance</strong></summary>

- [ ] **GV31** Recheck only rules affected by changed facts and emit diagnostic deltas.
- [ ] **GV32** Prove incremental checking equivalent to full checking.
- [ ] **GV33** Expose the checker through an LSP/editor loop.
- [ ] **GV34** Expose governance context and diagnostic deltas through an MCP adapter for agent clients.

</details>

<details>
<summary>☐ <strong>P5 — Governed runtime compiler</strong></summary>

- [ ] **GV35** Define typed Environment/Runtime IR.
- [ ] **GV36** Compile valid projects through a devenv backend.
- [ ] **GV37** Expose `govenv shell`, `govenv test`, and `govenv up`.

</details>

<details>
<summary>☐ <strong>P6 — Product bootstrap and self-hosting</strong></summary>

- [ ] **GV38** Ship a standalone `govenv` entrypoint and managed runtime setup.
- [ ] **GV39** Make Govenv govern and build itself.
- [ ] **GV40** Keep runtime backends replaceable behind the typed IR boundary.
- [ ] **GV41** Support white-label distributions while keeping the formal kernel reusable and product-neutral.
- [ ] **GV42** Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps.
- [ ] **GV43** Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code.

</details>

## Getting started

Govenv currently uses devenv only as its Stage 0 bootstrap environment.

The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`.

### Materialization

Materialize governed repository artifacts with:

```bash
nix run github:cachix/devenv/v2.3 -- tasks run govenv:materialize
```

On `main`, the Materialize workflow applies versioned non-admin projections automatically and commits any tracked drift as a subsequent `chore(materialize)` commit. The command above remains available for local materialization.

### Administrative materialization

Stage 0 setup for privileged targets, including the `admin-materialization` environment and `GOVENV_ADMIN_TOKEN`, is documented as governed literate Agda rather than duplicated here. [Read the governed setup guide](https://klarkc.github.io/govenv/Govenv.Administration.html).

### Test

Run the test suite with the pinned devenv tag:

```bash
nix run github:cachix/devenv/v2.3 -- test
```

This type-checks the literate Agda entrypoint `Govenv.lagda.md`, its imported Govenv modules, and verifies governed generated artifacts such as `README.md`.

### Documentation

Build the literate Agda documentation locally with:

```bash
nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs
```

The static site is written to `_site/` and deployed to GitHub Pages from `main`.
