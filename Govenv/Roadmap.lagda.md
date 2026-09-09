# Roadmap

The roadmap is governed project data. Its identifiers, hierarchy, and progress are declared here; generic construction mechanics live in the kernel.

Each governance identifier is indexed by its owning phase, so a GV cannot be placed under the wrong phase. The tree notation is the constitutional surface; list and constructor details are intentionally hidden.

```agda
{-# OPTIONS --safe #-}

module Govenv.Roadmap where

open import Govenv.Kernel.Roadmap

data PhaseId : Set where
  P0 P1 P2 P3 P4 P5 P6 : PhaseId

data GovernanceId : PhaseId → Set where
  GV0 GV1 GV2 : GovernanceId P0
  GV3 GV4 GV5 GV6 GV7 GV8 GV9 GV10 GV11 GV12 GV13 GV14 GV15 GV16 GV17 GV18 GV19 GV20 GV21 GV22 GV23 GV24 GV44 GV45 GV46 GV47 GV48 GV49 GV50 : GovernanceId P1
  GV25 : GovernanceId P2
  GV26 GV27 GV28 GV29 GV30 : GovernanceId P3
  GV31 GV32 GV33 GV34 : GovernanceId P4
  GV35 GV36 GV37 : GovernanceId P5
  GV38 GV39 GV40 GV41 GV42 GV43 : GovernanceId P6

phase0 : FinishedPhases PhaseId GovernanceId
phase0 = P0 ■ "Bootstrap and project shape"
  ┬ GV0 ✓ "Literate `Govenv.lagda.md` closure root."
  ├ GV1 ✓ "Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`."
  ├ GV2 ✓ "Reproducible Stage 0 bootstrap, documentation site, and automated releases."

phase1 : ActivePhase PhaseId GovernanceId
phase1 = P1 ▣ "Formal governance kernel"
  ┬ GV3 ✓ "`Verdict`: `holds`, `violated`, and `unknown`."
  ├ GV4 ✓ "Minimal `Rule` abstraction."
  ├ GV5 ✓ "Typed repository facts."
  ├ GV6 ✓ "Dependency-indexed rules."
  ├ GV7 ◇ "Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt."
  ├ GV8 ◇ "Encode GV7 as Govenv's first self-governing repository rule."
  ├ GV9 ◇ "Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration."
  ├ GV10 ◇ "Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention."
  ├ GV11 ◇ "Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified."
  ├ GV12 ◇ "CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change."
  ├ GV13 ◇ "CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change."
  ├ GV14 ✓ "Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check."
  ├ GV15 ✓ "Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible."
  ├ GV16 ✓ "Materialize governed README sections from Agda rather than maintaining duplicate prose by hand."
  ├ GV17 ◇ "Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts."
  ├ GV18 ◇ "Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations."
  ├ GV19 ✓ "Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing."
  ├ GV20 ✓ "Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity."
  ├ GV21 ✓ "Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations."
  ├ GV22 ✓ "Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow."
  ├ GV23 ◇ "Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries."
  ├ GV24 ◇ "CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution."
  ├ GV44 ◇ "Automatically apply versioned non-admin materializations on `main` using only repository-scoped CI permission; validation and publication workflows run after Materialize completes, while admin materializations remain manual."
  ├ GV45 ✓ "Require every admin materialization to read the target back after applying it, fail unless the observed value equals the governed expected value, and emit execution evidence tied to the constitution SHA, target, repository, and workflow run."
  ├ GV46 ◇ "Model admin materialization evidence as typed governed data that can be consumed by a formal rule or assurance check rather than relying on workflow success alone."
  ├ GV47 ✓ "Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`◇` item notation instead of raw `Nat` plus `done`/`todo`."
  ├ GV48 ◇ "Project every release governance delta from typed roadmap state and commit references, distinguishing completed, advanced, and introduced items plus phase progression while keeping SemVer independent."
  ├ GV49 ✓ "Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▣`/`□`, and render phase/item state using the same operator glyphs."
  ├ GV50 ✓ "Index each governance identifier by its owning phase and express roadmap hierarchy through declarative tree operators, keeping list and constructor mechanics out of the constitution."

phase2 : FuturePhases PhaseId GovernanceId
phase2 = P2 □ "Pure repository evaluator"
  ┬ GV25 ◇ "Evaluate facts, rules, verdicts, obligations, and diagnostics without IO."

phase3 : FuturePhases PhaseId GovernanceId
phase3 = P3 □ "`govenv check` and commit governance"
  ┬ GV26 ◇ "Observe repository facts through a thin impure adapter."
  ├ GV27 ◇ "Produce source-mapped governance diagnostics from the pure kernel."
  ├ GV28 ◇ "Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer."
  ├ GV29 ◇ "Validate the staged candidate repository state using the candidate governance before accepting a commit."
  ├ GV30 ◇ "Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly."

phase4 : FuturePhases PhaseId GovernanceId
phase4 = P4 □ "Incremental governance"
  ┬ GV31 ◇ "Recheck only rules affected by changed facts and emit diagnostic deltas."
  ├ GV32 ◇ "Prove incremental checking equivalent to full checking."
  ├ GV33 ◇ "Expose the checker through an LSP/editor loop."
  ├ GV34 ◇ "Expose governance context and diagnostic deltas through an MCP adapter for agent clients."

phase5 : FuturePhases PhaseId GovernanceId
phase5 = P5 □ "Governed runtime compiler"
  ┬ GV35 ◇ "Define typed Environment/Runtime IR."
  ├ GV36 ◇ "Compile valid projects through a devenv backend."
  ├ GV37 ◇ "Expose `govenv shell`, `govenv test`, and `govenv up`."

phase6 : FuturePhases PhaseId GovernanceId
phase6 = P6 □ "Product bootstrap and self-hosting"
  ┬ GV38 ◇ "Ship a standalone `govenv` entrypoint and managed runtime setup."
  ├ GV39 ◇ "Make Govenv govern and build itself."
  ├ GV40 ◇ "Keep runtime backends replaceable behind the typed IR boundary."
  ├ GV41 ◇ "Support white-label distributions while keeping the formal kernel reusable and product-neutral."
  ├ GV42 ◇ "Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps."
  ├ GV43 ◇ "Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code."

roadmap : Roadmap PhaseId GovernanceId
roadmap =
  phase0 ◁ phase1
  ┬ phase2
  ├ phase3
  ├ phase4
  ├ phase5
  ├ phase6
```
