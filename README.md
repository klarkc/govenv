<!-- Generated from Govenv.Materialization.Readme. Do not edit manually. -->

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

**Current:** ▣ P1 — Formal governance model and repository closure. `Verdict`, typed `Fact`, dependency-indexed `Rule`, typed roadmap structure, materialization closure, roadmap integrity, immutable governance identity, and typed release governance are in place; GV55 release-progress policy and its GV56 self-governing `Rule` are next.

> Governance IDs are immutable historical references. Definitions and owning phases never change after introduction; abandoned work is cancelled, while corrections or changed intent require a newer GV and explicit supersession.

<details>
<summary>■ <strong>P0 — Bootstrap and project shape</strong></summary>

- ✓ **GV0** Literate `Govenv.lagda.md` closure root.
- ✓ **GV1** Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`.
- ✓ **GV2** Reproducible Stage 0 bootstrap, documentation site, and automated releases.

</details>

<details open>
<summary>▣ <strong>P1 — Formal governance model and repository closure</strong></summary>

- ✓ **GV3** `Verdict`: `holds`, `violated`, and `unknown`.
- ✓ **GV4** Minimal `Rule` abstraction.
- ✓ **GV5** Typed repository facts.
- ✓ **GV6** Dependency-indexed rules.
- ↪ **GV47** Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`○` item notation instead of raw `Nat` plus `done`/`todo`. → **GV68**
- ✓ **GV68** Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`◇` item notation instead of raw `Nat` plus `done`/`todo`.
- ↪ **GV49** Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▶`/`□`, and render phase/item state using the same operator glyphs. → **GV69**
- ✓ **GV69** Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▣`/`□`, and render phase/item state using the same operator glyphs.
- ✓ **GV50** Use generic typed identifiers with structural `BelongsTo`, and express the entire roadmap as one declarative tree with implementation mechanics hidden.
- ✓ **GV52** Enforce roadmap identity and completion integrity: phase and governance indices must be unique, phase indices must progress monotonically, and a finished phase may contain no pending governance items.
- ↪ **GV9** Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration. → **GV57**
- ◇ **GV57** Inventory repository behavior and policy, distinguishing governed semantics from irreducibly observational or effectful mechanisms.
- ↪ **GV10** Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention. → **GV58**
- ◇ **GV58** Require every inventory entry whose semantics can be expressed and checked by Govenv to be backed by governed data and a rule.
- ↪ **GV11** Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified. → **GV59**
- ◇ **GV59** Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions.
- ↪ **GV17** Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts. → **GV61**
- ↪ **GV61** Enforce architecture roles and dependency directions for constitution, materialization, kernel, projection, adapters, and generated artifacts. → **GV62**
- ◇ **GV62** Enforce architecture roles and dependency directions for the closure root, constitution, materialization, kernel, projection, adapters, and generated artifacts.
- ✓ **GV20** Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity.
- ↪ **GV14** Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check. → **GV60**
- ✓ **GV60** Govern `README.md` as the canonical output of `Govenv.Materialization.Readme`; manual divergence must fail the project check.
- ✓ **GV15** Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible.
- ✓ **GV16** Materialize governed README sections from Agda rather than maintaining duplicate prose by hand.
- ✓ **GV51** Materialization closure: every state materialized by Govenv must have exactly one canonical `Govenv.Materialization.*` definition containing all semantic content, structure, ordering, inclusion, policy, and required capability decisions; projections encode only target-format representation, and adapters only observe, apply, or verify effects.
- ◇ **GV18** Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations.
- ✓ **GV19** Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing.
- ✓ **GV21** Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations.
- ✓ **GV22** Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow.
- ✓ **GV45** Require every admin materialization to read the target back after applying it, fail unless the observed value equals the governed expected value, and emit execution evidence tied to the constitution SHA, target, repository, and workflow run.
- ◇ **GV46** Model admin materialization evidence as typed governed data that can be consumed by a formal rule or assurance check rather than relying on workflow success alone.
- ↪ **GV23** Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries. → **GV63**
- ◇ **GV63** Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries.
- ◇ **GV24** CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution.
- ◇ **GV12** CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change.
- ◇ **GV13** CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change.
- ✓ **GV44** Automatically apply versioned non-admin materializations on `main` using only repository-scoped CI permission; validation and publication workflows run after Materialize completes, while admin materializations remain manual.
- ↪ **GV48** Project every release governance delta from typed roadmap state and commit references, distinguishing completed, advanced, and introduced items plus phase progression while keeping SemVer independent. → **GV70**
- ✓ **GV70** Project release governance deltas from immutable typed roadmap snapshots and commit references, distinguishing introduced, advanced, completed, cancelled, and superseded items plus phase progression while rejecting identity mutation or removal and keeping SemVer independent.
- ✓ **GV54** Preserve immutable governance identity across roadmap evolution: once introduced, a `GovernanceId`, its definition, and its owning phase may never be removed, reused, or modified; obsolete or corrected governance must remain represented as cancelled or superseded, with supersession explicitly identifying a newer replacement `GovernanceId`.
- ◇ **GV71** Restrict handwritten versioned repository content to Agda and Markdown only. Any generated or governed materialization may use its required target format. Until GV38 is completed, the only handwritten bootstrap escape hatch is root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock`; all other implementation languages and handwritten configuration formats, including Nix elsewhere, are forbidden.
- ◇ **GV72** Require every versioned repository artifact not permitted as handwritten source by GV71, except the temporary root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock` bootstrap escape hatch, to be produced by exactly one governed `Govenv.Materialization.*` definition and verified against its materialized state; transient `.govenv` state is forbidden from being versioned.
- ◇ **GV73** Require every persisted supporting artifact, including snapshots, fixtures, baselines, schemas, test vectors, and evidence, to be colocated with the module that semantically owns it; catch-all artifact directories are forbidden unless the artifact is genuinely project-global.
- ◇ **GV74** Make governance completion evidence-bearing and persistent: a governance item may transition to `done` only when governed evidence establishes its proposition for the candidate repository state, and every non-superseded `done` item, including items completed before this rule, must remain satisfied in every subsequent valid repository state.
- ◇ **GV75** Render release governance item changes as compact semantic diffs: remove redundant per-item progress labels, align before/after propositions for supersessions, visually distinguish only changed spans, and deterministically wrap or elide common context while preserving the full typed governance delta.
- ◇ **GV76** Make governance references in Git-derived projections revision-aware and navigable: linked identities, lifecycle states and operators, transitions, and elisions must resolve to documentation derived from the immutable Git revision or delta they represent; before-state references use the base revision and after-state references use the candidate or head revision.
- ◇ **GV77** Make `CHANGELOG.md` the canonical versioned portable materialization of each typed release entry, while the Release Please pull request and published GitHub Release project the same typed release content through a shared enriched GitHub renderer; external GitHub Release application must be verified by read-back equality.
- ↪ **GV7** Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt. → **GV55**
- ◇ **GV55** Model the governed release-progress policy: major and minor releases require governance progress by completing at least one pending item or advancing to a later phase; patch releases are exempt.
- ↪ **GV8** Encode GV7 as Govenv's first self-governing repository rule. → **GV56**
- ◇ **GV56** Encode and enforce GV55 as Govenv's first self-governing `Rule` over typed release governance state.

</details>

<details>
<summary>□ <strong>P2 — Pure repository evaluator</strong></summary>

- ↪ **GV25** Evaluate facts, rules, verdicts, obligations, and diagnostics without IO. → **GV64**
- ◇ **GV64** Purely evaluate facts and rules into verdicts, obligations, and typed diagnostics without IO.
- ◇ **GV65** Purely associate governance diagnostics with governed repository provenance so consumers can produce source-mapped diagnostics without IO.

</details>

<details>
<summary>□ <strong>P3 — `govenv check` and commit governance</strong></summary>

- ◇ **GV26** Observe repository facts through a thin impure adapter.
- ↪ **GV27** Produce source-mapped governance diagnostics from the pure kernel. → **GV65**
- ◇ **GV53** Expose repository evaluation as `govenv check`, with deterministic exit status and source-mapped diagnostics while keeping observation and effects outside the pure evaluator.
- ↪ **GV28** Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer. → **GV66**
- ◇ **GV66** Model governed commit policy as project data with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer.
- ◇ **GV29** Validate the staged candidate repository state using the candidate governance before accepting a commit.
- ◇ **GV30** Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly.

</details>

<details>
<summary>□ <strong>P4 — Incremental governance</strong></summary>

- ◇ **GV31** Recheck only rules affected by changed facts and emit diagnostic deltas.
- ◇ **GV32** Prove incremental checking equivalent to full checking.
- ◇ **GV33** Expose the checker through an LSP/editor loop.
- ◇ **GV34** Expose governance context and diagnostic deltas through an MCP adapter for agent clients.

</details>

<details>
<summary>□ <strong>P5 — Governed runtime compiler</strong></summary>

- ◇ **GV35** Define typed Environment/Runtime IR.
- ◇ **GV67** Keep runtime backends replaceable behind the typed IR boundary.
- ◇ **GV36** Compile valid projects through a devenv backend.
- ◇ **GV37** Expose `govenv shell`, `govenv test`, and `govenv up`.

</details>

<details>
<summary>□ <strong>P6 — Product bootstrap, self-hosting, and distribution</strong></summary>

- ◇ **GV38** Ship a standalone `govenv` entrypoint and managed runtime setup.
- ↪ **GV40** Keep runtime backends replaceable behind the typed IR boundary. → **GV67**
- ◇ **GV39** Make Govenv govern and build itself.
- ◇ **GV41** Support white-label distributions while keeping the formal kernel reusable and product-neutral.
- ◇ **GV42** Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps.
- ◇ **GV43** Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code.

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
