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

**Current:** ▣ P1 — Formal governance model and repository closure. Next: **GV57** — Inventory repository behavior and policy, distinguishing governed semantics from irreducibly observational or effectful mechanisms.

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
- ◇ **GV84** Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed.
- ↪ **GV85** Treat the case-insensitive standalone word `fix` in governed commit messages as a conservative regression signal: candidate commit validation must reject it unless the commit references governed regression evidence or carries an explicit justified non-regression exemption; no exemption may discharge an unresolved observed regression. → **GV89**
- ◇ **GV86** Treat governance items as cumulative constitutional decisions: from introduction onward, every item is interpreted against the complete constitution at that revision, including `todo`, `done`, `superseded`, and `cancelled` history; lifecycle state determines operative effect rather than constitutional membership, completion records establishment rather than applicability, and explicit dependency relationships between governance items are neither required nor modeled.
- ◇ **GV87** Project the typed candidate governance delta of every governed pull request through a GitHub-native check derived from revision-aware governance state; workflow artifacts may provide transient inspection material, but finite external retention means they must never be the sole or authoritative governance evidence, and any evidence required for completion, regression closure, auditability, or future validation must persist in governed revision-addressable form from which transient projections can be reproduced.
- ◇ **GV90** Model human authorization as `AuthorizedRevision`: new semantic authority may originate only from the exact repository state accepted by an explicit human pull-request merge. Candidate revisions may perform unprivileged validation and transient non-authoritative projections, but automated candidate-authoring principals must be distinct from human authorizers and post-authorization materializers and must not receive capabilities that can alter executable automation, authorize or merge the candidate, mutate authoritative repository state, or mutate persistent governed external state; only after authorization may governed automation exercise the capabilities necessary to derive deterministic materialization revisions or external effects. Derived outcomes create no independent semantic authority, must not be treated as fresh human authorization, and must retain revision-addressable causal provenance to the authorizing revision.
- ◇ **GV91** Require authority-boundary migrations to be monotonic and non-self-locking: an enforcement or capability restriction may become active only after every authorized execution path required to operate, verify, and repair under that restriction is already present in an `AuthorizedRevision` and its prerequisite external capabilities have been applied and read-back verified; bootstrap stages must preserve a human-authorized recovery path, and no stage may depend on a capability whose establishment occurs only after the enforcement that requires it.
- ◇ **GV92** Require administrative bootstrap and continued administration to have exactly one human-supplied root authority, represented by `GOVENV_ADMIN_TOKEN`. Provisioning, replacing, or rotating the credential representing that root preserves the identity of the same administrative authority and must never constitute a new independent authority. From this root and an `AuthorizedRevision`, `Admin Materialize` must deterministically derive the required subordinate authority graph and must materialize, generate where cryptographic material is required, provision, rotate, order, and read-back verify every subordinate credential, capability boundary, identity, environment, variable, secret, policy, and persistent administrative effect required by Govenv. Generated credential material carries no independent semantic authority and must remain bound to governed identity and capability state. No additional manually supplied credential, token, key, secret, application identity, environment mutation, or per-target administrative intervention may become a prerequisite for normal operation. Any required authority that cannot be derived or materialized from this root must be treated as an architectural incompleteness unless a hosting-platform impossibility is explicitly governed.
- ◇ **GV93** When an authorized materializer relies on a GitHub ruleset bypass granted to the `DeployKey` actor class, govern the repository deploy-key set as a closed set containing only the materializer credential. No unmanaged or independently provisioned deploy key may coexist with that bypass. `Admin Materialize` must provision or rotate the materializer deploy key, remove stale or unauthorized deploy keys, and read-back verify the complete deploy-key set before the `DeployKey` bypass may become active.
- ✓ **GV94** Make roadmap current state derived and self-consistent: while governance work remains, the active phase must contain non-terminal governance work, finished phases must remain terminal, and a complete roadmap may contain no non-terminal work. Every `Current` projection, including README status and next-work information, must be derived from typed roadmap state and may contain no independently maintained progress summary.
- ◇ **GV75** Render release governance item changes as compact semantic diffs: remove redundant per-item progress labels, align before/after propositions for supersessions, visually distinguish only changed spans, and deterministically wrap or elide common context while preserving the full typed governance delta.
- ◇ **GV83** Render governance deltas sparsely: project only semantic dimensions whose values change, keep unchanged dimensions implicit, and retain only the identity and context required to unambiguously interpret the change.
- ↪ **GV76** Make governance references in Git-derived projections revision-aware and navigable: linked identities, lifecycle states and operators, transitions, and elisions must resolve to documentation derived from the immutable Git revision or delta they represent; before-state references use the base revision and after-state references use the candidate or head revision. → **GV78**
- ↪ **GV77** Make `CHANGELOG.md` the canonical versioned portable materialization of each typed release entry, while the Release Please pull request and published GitHub Release project the same typed release content through a shared enriched GitHub renderer; external GitHub Release application must be verified by read-back equality. → **GV95**
- ✓ **GV95** Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality.
- ◇ **GV78** Define revision-aware documentation references for governed identities, lifecycle states, operators, transitions, and Agda modules and symbols, so every reference can be resolved against the repository revision or delta it semantically represents.
- ◇ **GV79** Require every versioned Markdown artifact, including literate Agda, whether handwritten or materialized, to use valid navigable documentation references for governed concepts and Agda entities whenever such references are semantically exposed.
- ◇ **GV80** Make Agda documentation addressable by immutable repository revision so revision-aware documentation references never depend on mutable current documentation.
- ◇ **GV81** Require the Release Please pull request body to project governed and Agda documentation references using the revision-aware documentation reference model for the release delta it represents.
- ◇ **GV82** Require the published GitHub Release body to project the same revision-aware governed and Agda documentation references as its release document.
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
- ◇ **GV89** Treat the case-insensitive standalone word `fix` in governed commit messages as a conservative regression signal: candidate commit validation must reject it unless the commit references governed regression evidence or carries an explicit justified non-regression exemption; no exemption may discharge an unresolved observed regression.
- ◇ **GV29** Validate the staged candidate repository state using the candidate governance before accepting a commit.
- ◇ **GV30** Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly.

</details>

<details>
<summary>□ <strong>P4 — Incremental governance</strong></summary>

- ◇ **GV31** Recheck only rules affected by changed facts and emit diagnostic deltas.
- ◇ **GV32** Prove incremental checking equivalent to full checking.
- ◇ **GV33** Expose the checker through an LSP/editor loop.
- ◇ **GV34** Expose governance context and diagnostic deltas through an MCP adapter for agent clients.
- ◇ **GV88** Require every governable obligation to be enforced at its earliest sound information boundary while retaining `govenv check` as the authoritative repository evaluation and deriving every anticipatory enforcement from the same governed rule. Maintain an explicit enforcement inventory that anticipates, at minimum: construction-time Agda constraints for typed identities, roadmap/lifecycle validity, constitutional structure, evidence relationships, pure kernel boundaries, and projection/materialization structure; static candidate or incremental/LSP checks for governance evolution, immutable identity, architecture imports, handwritten-source restrictions, materialization ownership and drift, artifact colocation, documentation references, regression obligations, governance/release deltas, and release-progress classification; commit-boundary checks for staged candidate validity, commit policy, governance references, semantic commit classification, and regression signals; PR/CI checks only for information first available from GitHub or the remote candidate; and post-effect checks only for irreducible external observations such as read-back equality, publication state, admin effects, and runtime facts. Later stages may confirm earlier results but must not re-own, duplicate, or independently specify semantics that were soundly enforceable earlier.

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
