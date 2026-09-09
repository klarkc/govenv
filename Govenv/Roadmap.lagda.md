# Roadmap

The roadmap is governed project data. It declares phases, items, and progress; presentation belongs to the runtime projection layer.

```agda
{-# OPTIONS --safe #-}

module Govenv.Roadmap where

open import Agda.Builtin.List
open import Govenv.Kernel.Roadmap

data PhaseId : Set where
  P0 P1 P2 P3 P4 P5 P6 : PhaseId

phase0 : Phase PhaseId
phase0 = phase P0 "Bootstrap and project shape" finished
  ( item 0 "Literate `Govenv.lagda.md` closure root." done
  ∷ item 1 "Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`." done
  ∷ item 2 "Reproducible Stage 0 bootstrap, documentation site, and automated releases." done
  ∷ [] )

phase1 : Phase PhaseId
phase1 = phase P1 "Formal governance kernel" active
  ( item 3 "`Verdict`: `holds`, `violated`, and `unknown`." done
  ∷ item 4 "Minimal `Rule` abstraction." done
  ∷ item 5 "Typed repository facts." done
  ∷ item 6 "Dependency-indexed rules." done
  ∷ item 7 "Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt." todo
  ∷ item 8 "Encode GV7 as Govenv's first self-governing repository rule." todo
  ∷ item 9 "Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration." todo
  ∷ item 10 "Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention." todo
  ∷ item 11 "Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified." todo
  ∷ item 12 "CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change." todo
  ∷ item 13 "CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change." todo
  ∷ item 14 "Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check." done
  ∷ item 15 "Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible." done
  ∷ item 16 "Materialize governed README sections from Agda rather than maintaining duplicate prose by hand." done
  ∷ item 17 "Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts." todo
  ∷ item 18 "Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations." todo
  ∷ item 19 "Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing." done
  ∷ item 20 "Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity." done
  ∷ item 21 "Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations." done
  ∷ item 22 "Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow." done
  ∷ item 23 "Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries." todo
  ∷ item 24 "CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution." todo
  ∷ [] )

phase2 : Phase PhaseId
phase2 = phase P2 "Pure repository evaluator" future
  ( item 25 "Evaluate facts, rules, verdicts, obligations, and diagnostics without IO." todo
  ∷ [] )

phase3 : Phase PhaseId
phase3 = phase P3 "`govenv check` and commit governance" future
  ( item 26 "Observe repository facts through a thin impure adapter." todo
  ∷ item 27 "Produce source-mapped governance diagnostics from the pure kernel." todo
  ∷ item 28 "Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`." todo
  ∷ item 29 "Validate the staged candidate repository state using the candidate governance before accepting a commit." todo
  ∷ item 30 "Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly." todo
  ∷ [] )

phase4 : Phase PhaseId
phase4 = phase P4 "Incremental governance" future
  ( item 31 "Recheck only rules affected by changed facts and emit diagnostic deltas." todo
  ∷ item 32 "Prove incremental checking equivalent to full checking." todo
  ∷ item 33 "Expose the checker through an LSP/editor loop." todo
  ∷ item 34 "Expose governance context and diagnostic deltas through an MCP adapter for agent clients." todo
  ∷ [] )

phase5 : Phase PhaseId
phase5 = phase P5 "Governed runtime compiler" future
  ( item 35 "Define typed Environment/Runtime IR." todo
  ∷ item 36 "Compile valid projects through a devenv backend." todo
  ∷ item 37 "Expose `govenv shell`, `govenv test`, and `govenv up`." todo
  ∷ [] )

phase6 : Phase PhaseId
phase6 = phase P6 "Product bootstrap and self-hosting" future
  ( item 38 "Ship a standalone `govenv` entrypoint and managed runtime setup." todo
  ∷ item 39 "Make Govenv govern and build itself." todo
  ∷ item 40 "Keep runtime backends replaceable behind the typed IR boundary." todo
  ∷ item 41 "Support white-label distributions while keeping the formal kernel reusable and product-neutral." todo
  ∷ item 42 "Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps." todo
  ∷ item 43 "Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code." todo
  ∷ [] )

roadmap : Roadmap PhaseId
roadmap = phase0 ∷ phase1 ∷ phase2 ∷ phase3 ∷ phase4 ∷ phase5 ∷ phase6 ∷ []
```
