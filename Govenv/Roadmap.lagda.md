# Roadmap

The roadmap is the governed project plan. Governance identities are append-only: lifecycle may advance, but an introduced definition and its owning phase never mutate. Obsolete or corrected items remain visible as cancelled or superseded history. Identity, membership proofs, phase validity, supersession validity, and construction mechanics are intentionally hidden behind the roadmap DSL.

```agda
{-# OPTIONS --safe #-}

module Govenv.Roadmap where

open import Govenv.Roadmap.DSL

roadmap : Roadmap
roadmap = roadmapOf (
    (P 0 "Bootstrap and project shape" ■
    ┬ GV 0 "Literate `Govenv.lagda.md` closure root." ✓
    ├ GV 1 "Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`." ✓
    ├ GV 2 "Reproducible Stage 0 bootstrap, documentation site, and automated releases." ✓
  ) ╟ (P 1 "Formal governance model and repository closure" ▣
    ┬ GV 3 "`Verdict`: `holds`, `violated`, and `unknown`." ✓
    ├ GV 4 "Minimal `Rule` abstraction." ✓
    ├ GV 5 "Typed repository facts." ✓
    ├ GV 6 "Dependency-indexed rules." ✓
    ├ GV 47 "Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`○` item notation instead of raw `Nat` plus `done`/`todo`." ↪ GVR 68
    ├ GV 68 "Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`◇` item notation instead of raw `Nat` plus `done`/`todo`." ✓
    ├ GV 49 "Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▶`/`□`, and render phase/item state using the same operator glyphs." ↪ GVR 69
    ├ GV 69 "Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▣`/`□`, and render phase/item state using the same operator glyphs." ✓
    ├ GV 50 "Use generic typed identifiers with structural `BelongsTo`, and express the entire roadmap as one declarative tree with implementation mechanics hidden." ✓
    ├ GV 52 "Enforce roadmap identity and completion integrity: phase and governance indices must be unique, phase indices must progress monotonically, and a finished phase may contain no pending governance items." ✓
    ├ GV 9 "Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration." ↪ GVR 57
    ├ GV 57 "Inventory repository behavior and policy, distinguishing governed semantics from irreducibly observational or effectful mechanisms." ◇
    ├ GV 10 "Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention." ↪ GVR 58
    ├ GV 58 "Require every inventory entry whose semantics can be expressed and checked by Govenv to be backed by governed data and a rule." ◇
    ├ GV 11 "Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified." ↪ GVR 59
    ├ GV 59 "Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions." ◇
    ├ GV 17 "Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts." ↪ GVR 61
    ├ GV 61 "Enforce architecture roles and dependency directions for constitution, materialization, kernel, projection, adapters, and generated artifacts." ↪ GVR 62
    ├ GV 62 "Enforce architecture roles and dependency directions for the closure root, constitution, materialization, kernel, projection, adapters, and generated artifacts." ◇
    ├ GV 20 "Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity." ✓
    ├ GV 14 "Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check." ↪ GVR 60
    ├ GV 60 "Govern `README.md` as the canonical output of `Govenv.Materialization.Readme`; manual divergence must fail the project check." ✓
    ├ GV 15 "Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible." ✓
    ├ GV 16 "Materialize governed README sections from Agda rather than maintaining duplicate prose by hand." ✓
    ├ GV 51 "Materialization closure: every state materialized by Govenv must have exactly one canonical `Govenv.Materialization.*` definition containing all semantic content, structure, ordering, inclusion, policy, and required capability decisions; projections encode only target-format representation, and adapters only observe, apply, or verify effects." ✓
    ├ GV 18 "Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations." ◇
    ├ GV 19 "Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing." ✓
    ├ GV 21 "Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations." ✓
    ├ GV 22 "Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow." ✓
    ├ GV 45 "Require every admin materialization to read the target back after applying it, fail unless the observed value equals the governed expected value, and emit execution evidence tied to the constitution SHA, target, repository, and workflow run." ✓
    ├ GV 46 "Model admin materialization evidence as typed governed data that can be consumed by a formal rule or assurance check rather than relying on workflow success alone." ◇
    ├ GV 23 "Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries." ↪ GVR 63
    ├ GV 63 "Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries." ◇
    ├ GV 24 "CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution." ◇
    ├ GV 12 "CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change." ◇
    ├ GV 13 "CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change." ◇
    ├ GV 44 "Automatically apply versioned non-admin materializations on `main` using only repository-scoped CI permission; validation and publication workflows run after Materialize completes, while admin materializations remain manual." ✓
    ├ GV 48 "Project every release governance delta from typed roadmap state and commit references, distinguishing completed, advanced, and introduced items plus phase progression while keeping SemVer independent." ↪ GVR 70
    ├ GV 70 "Project release governance deltas from immutable typed roadmap snapshots and commit references, distinguishing introduced, advanced, completed, cancelled, and superseded items plus phase progression while rejecting identity mutation or removal and keeping SemVer independent." ✓
    ├ GV 54 "Preserve immutable governance identity across roadmap evolution: once introduced, a `GovernanceId`, its definition, and its owning phase may never be removed, reused, or modified; obsolete or corrected governance must remain represented as cancelled or superseded, with supersession explicitly identifying a newer replacement `GovernanceId`." ✓
    ├ GV 71 "Restrict handwritten versioned repository content to Agda and Markdown only. Any generated or governed materialization may use its required target format. Until GV38 is completed, the only handwritten bootstrap escape hatch is root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock`; all other implementation languages and handwritten configuration formats, including Nix elsewhere, are forbidden." ◇
    ├ GV 72 "Require every versioned repository artifact not permitted as handwritten source by GV71, except the temporary root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock` bootstrap escape hatch, to be produced by exactly one governed `Govenv.Materialization.*` definition and verified against its materialized state; transient `.govenv` state is forbidden from being versioned." ◇
    ├ GV 73 "Require every persisted supporting artifact, including snapshots, fixtures, baselines, schemas, test vectors, and evidence, to be colocated with the module that semantically owns it; catch-all artifact directories are forbidden unless the artifact is genuinely project-global." ◇
    ├ GV 74 "Make governance completion evidence-bearing and persistent: a governance item may transition to `done` only when governed evidence establishes its proposition for the candidate repository state, and every non-superseded `done` item, including items completed before this rule, must remain satisfied in every subsequent valid repository state." ◇
    ├ GV 75 "Render release governance item changes as compact semantic diffs: remove redundant per-item progress labels, align before/after propositions for supersessions, visually distinguish only changed spans, and deterministically wrap or elide common context while preserving the full typed governance delta." ◇
    ├ GV 83 "Render governance deltas sparsely: project only semantic dimensions whose values change, keep unchanged dimensions implicit, and retain only the identity and context required to unambiguously interpret the change." ◇
    ├ GV 76 "Make governance references in Git-derived projections revision-aware and navigable: linked identities, lifecycle states and operators, transitions, and elisions must resolve to documentation derived from the immutable Git revision or delta they represent; before-state references use the base revision and after-state references use the candidate or head revision." ↪ GVR 78
    ├ GV 77 "Make `CHANGELOG.md` the canonical versioned portable materialization of each typed release entry, while the Release Please pull request and published GitHub Release project the same typed release content through a shared enriched GitHub renderer; external GitHub Release application must be verified by read-back equality." ◇
    ├ GV 78 "Define revision-aware documentation references for governed identities, lifecycle states, operators, transitions, and Agda modules and symbols, so every reference can be resolved against the repository revision or delta it semantically represents." ◇
    ├ GV 79 "Require every versioned Markdown artifact, including literate Agda, whether handwritten or materialized, to use valid navigable documentation references for governed concepts and Agda entities whenever such references are semantically exposed." ◇
    ├ GV 80 "Make Agda documentation addressable by immutable repository revision so revision-aware documentation references never depend on mutable current documentation." ◇
    ├ GV 81 "Require the Release Please pull request body to project governed and Agda documentation references using the revision-aware documentation reference model for the release delta it represents." ◇
    ├ GV 82 "Require the published GitHub Release body to project the same revision-aware governed and Agda documentation references as its release document." ◇
    ├ GV 7 "Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt." ↪ GVR 55
    ├ GV 55 "Model the governed release-progress policy: major and minor releases require governance progress by completing at least one pending item or advancing to a later phase; patch releases are exempt." ◇
    ├ GV 8 "Encode GV7 as Govenv's first self-governing repository rule." ↪ GVR 56
    ├ GV 56 "Encode and enforce GV55 as Govenv's first self-governing `Rule` over typed release governance state." ◇
  ) ╟ (P 2 "Pure repository evaluator" □
    ┬ GV 25 "Evaluate facts, rules, verdicts, obligations, and diagnostics without IO." ↪ GVR 64
    ├ GV 64 "Purely evaluate facts and rules into verdicts, obligations, and typed diagnostics without IO." ◇
    ├ GV 65 "Purely associate governance diagnostics with governed repository provenance so consumers can produce source-mapped diagnostics without IO." ◇
  ) ╟ (P 3 "`govenv check` and commit governance" □
    ┬ GV 26 "Observe repository facts through a thin impure adapter." ◇
    ├ GV 27 "Produce source-mapped governance diagnostics from the pure kernel." ↪ GVR 65
    ├ GV 53 "Expose repository evaluation as `govenv check`, with deterministic exit status and source-mapped diagnostics while keeping observation and effects outside the pure evaluator." ◇
    ├ GV 28 "Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer." ↪ GVR 66
    ├ GV 66 "Model governed commit policy as project data with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer." ◇
    ├ GV 29 "Validate the staged candidate repository state using the candidate governance before accepting a commit." ◇
    ├ GV 30 "Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly." ◇
  ) ╟ (P 4 "Incremental governance" □
    ┬ GV 31 "Recheck only rules affected by changed facts and emit diagnostic deltas." ◇
    ├ GV 32 "Prove incremental checking equivalent to full checking." ◇
    ├ GV 33 "Expose the checker through an LSP/editor loop." ◇
    ├ GV 34 "Expose governance context and diagnostic deltas through an MCP adapter for agent clients." ◇
  ) ╟ (P 5 "Governed runtime compiler" □
    ┬ GV 35 "Define typed Environment/Runtime IR." ◇
    ├ GV 67 "Keep runtime backends replaceable behind the typed IR boundary." ◇
    ├ GV 36 "Compile valid projects through a devenv backend." ◇
    ├ GV 37 "Expose `govenv shell`, `govenv test`, and `govenv up`." ◇
  ) ╟ (P 6 "Product bootstrap, self-hosting, and distribution" □
    ┬ GV 38 "Ship a standalone `govenv` entrypoint and managed runtime setup." ◇
    ├ GV 40 "Keep runtime backends replaceable behind the typed IR boundary." ↪ GVR 67
    ├ GV 39 "Make Govenv govern and build itself." ◇
    ├ GV 41 "Support white-label distributions while keeping the formal kernel reusable and product-neutral." ◇
    ├ GV 42 "Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps." ◇
    ├ GV 43 "Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code." ◇
  ))
```