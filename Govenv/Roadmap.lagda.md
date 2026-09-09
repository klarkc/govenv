# Roadmap

The roadmap is the governed project plan. Identity, membership proofs, phase validity, and construction mechanics are intentionally hidden behind the roadmap DSL.

```agda
{-# OPTIONS --safe #-}

module Govenv.Roadmap where

open import Govenv.Roadmap.DSL

roadmap = roadmapOf (
    (P 0 "Bootstrap and project shape" ■
    ┬ GV 0 "Literate `Govenv.lagda.md` closure root." ✓
    ├ GV 1 "Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`." ✓
    ├ GV 2 "Reproducible Stage 0 bootstrap, documentation site, and automated releases." ✓
  ) ╟ (P 1 "Formal governance kernel" ▣
    ┬ GV 3 "`Verdict`: `holds`, `violated`, and `unknown`." ✓
    ├ GV 4 "Minimal `Rule` abstraction." ✓
    ├ GV 5 "Typed repository facts." ✓
    ├ GV 6 "Dependency-indexed rules." ✓
    ├ GV 7 "Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt." ◇
    ├ GV 8 "Encode GV7 as Govenv's first self-governing repository rule." ◇
    ├ GV 9 "Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration." ◇
    ├ GV 10 "Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention." ◇
    ├ GV 11 "Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified." ◇
    ├ GV 12 "CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change." ◇
    ├ GV 13 "CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change." ◇
    ├ GV 14 "Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check." ✓
    ├ GV 15 "Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible." ✓
    ├ GV 16 "Materialize governed README sections from Agda rather than maintaining duplicate prose by hand." ✓
    ├ GV 17 "Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts." ◇
    ├ GV 18 "Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations." ◇
    ├ GV 19 "Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing." ✓
    ├ GV 20 "Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity." ✓
    ├ GV 21 "Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations." ✓
    ├ GV 22 "Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow." ✓
    ├ GV 23 "Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries." ◇
    ├ GV 24 "CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution." ◇
    ├ GV 44 "Automatically apply versioned non-admin materializations on `main` using only repository-scoped CI permission; validation and publication workflows run after Materialize completes, while admin materializations remain manual." ◇
    ├ GV 45 "Require every admin materialization to read the target back after applying it, fail unless the observed value equals the governed expected value, and emit execution evidence tied to the constitution SHA, target, repository, and workflow run." ✓
    ├ GV 46 "Model admin materialization evidence as typed governed data that can be consumed by a formal rule or assurance check rather than relying on workflow success alone." ◇
    ├ GV 47 "Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`◇` item notation instead of raw `Nat` plus `done`/`todo`." ✓
    ├ GV 48 "Project every release governance delta from typed roadmap state and commit references, distinguishing completed, advanced, and introduced items plus phase progression while keeping SemVer independent." ◇
    ├ GV 49 "Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▣`/`□`, and render phase/item state using the same operator glyphs." ✓
    ├ GV 50 "Use generic typed identifiers with structural `BelongsTo`, and express the entire roadmap as one declarative tree with implementation mechanics hidden." ✓
  ) ╟ (P 2 "Pure repository evaluator" □
    ┬ GV 25 "Evaluate facts, rules, verdicts, obligations, and diagnostics without IO." ◇
  ) ╟ (P 3 "`govenv check` and commit governance" □
    ┬ GV 26 "Observe repository facts through a thin impure adapter." ◇
    ├ GV 27 "Produce source-mapped governance diagnostics from the pure kernel." ◇
    ├ GV 28 "Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer." ◇
    ├ GV 29 "Validate the staged candidate repository state using the candidate governance before accepting a commit." ◇
    ├ GV 30 "Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly." ◇
  ) ╟ (P 4 "Incremental governance" □
    ┬ GV 31 "Recheck only rules affected by changed facts and emit diagnostic deltas." ◇
    ├ GV 32 "Prove incremental checking equivalent to full checking." ◇
    ├ GV 33 "Expose the checker through an LSP/editor loop." ◇
    ├ GV 34 "Expose governance context and diagnostic deltas through an MCP adapter for agent clients." ◇
  ) ╟ (P 5 "Governed runtime compiler" □
    ┬ GV 35 "Define typed Environment/Runtime IR." ◇
    ├ GV 36 "Compile valid projects through a devenv backend." ◇
    ├ GV 37 "Expose `govenv shell`, `govenv test`, and `govenv up`." ◇
  ) ╟ (P 6 "Product bootstrap and self-hosting" □
    ┬ GV 38 "Ship a standalone `govenv` entrypoint and managed runtime setup." ◇
    ├ GV 39 "Make Govenv govern and build itself." ◇
    ├ GV 40 "Keep runtime backends replaceable behind the typed IR boundary." ◇
    ├ GV 41 "Support white-label distributions while keeping the formal kernel reusable and product-neutral." ◇
    ├ GV 42 "Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps." ◇
    ├ GV 43 "Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code." ◇
  ))
```
