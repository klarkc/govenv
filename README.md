<!-- Generated from Govenv.Readme. Do not edit manually. -->

<h1 align="center">Govenv</h1>

<p align="center">
  <strong>Compile formally governed projects into reproducible development runtimes. A type system for your repository.</strong>
</p>

<p align="center">
  <a href="https://klarkc.github.io/govenv/"><img src="https://img.shields.io/badge/docs-pages-brightgreen" alt="Docs" /></a>
  <img src="https://img.shields.io/badge/agda-2.8.0-blueviolet" alt="Agda 2.8.0" />
  <a href="https://github.com/klarkc/govenv/releases"><img src="https://img.shields.io/github/v/release/klarkc/govenv?display_name=tag&sort=semver" alt="Release" /></a>
  <img src="https://img.shields.io/badge/license-Apache--2.0-blue" alt="License" />
</p>

## Roadmap

**Current:** R1 — Formal governance kernel. `Verdict`, typed `Fact`, and the current `Rule` model are in place; dependency-indexed rules and the first self-governing rule are next.

> This roadmap is subject to change as Govenv's architecture evolves. IDs are intended to remain stable references whenever practical.

<details>
<summary>☑ <strong>R0 — Bootstrap and project shape</strong></summary>

- [x] **R0-01** Literate `Govenv.lagda.md` closure root.
- [x] **R0-02** Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`.
- [x] **R0-03** Reproducible Stage 0 bootstrap, documentation site, and automated releases.

</details>

<details open>
<summary>☐ <strong>R1 — Formal governance kernel</strong> ← current</summary>

- [x] **R1-01** `Verdict`: `holds`, `violated`, and `unknown`.
- [x] **R1-02** Minimal `Rule` abstraction.
- [x] **R1-03** Typed repository facts.
- [ ] **R1-04** Dependency-indexed rules.
- [ ] **R1-05** Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt.
- [ ] **R1-06** Encode R1-05 as Govenv's first self-governing repository rule.
- [ ] **R1-07** Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration.
- [ ] **R1-08** Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention.
- [ ] **R1-09** Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified.
- [ ] **R1-10** CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change.
- [ ] **R1-11** CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change.
- [x] **R1-12** Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check.
- [x] **R1-13** Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible.
- [x] **R1-14** Materialize governed README sections from Agda rather than maintaining duplicate prose by hand.

</details>

<details>
<summary>☐ <strong>R2 — Pure repository evaluator</strong></summary>

- [ ] **R2-01** Evaluate facts, rules, verdicts, obligations, and diagnostics without IO.

</details>

<details>
<summary>☐ <strong>R3 — `govenv check` and commit governance</strong></summary>

- [ ] **R3-01** Observe repository facts through a thin impure adapter.
- [ ] **R3-02** Produce source-mapped governance diagnostics from the pure kernel.
- [ ] **R3-03** Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`.
- [ ] **R3-04** Validate the staged candidate repository state using the candidate governance before accepting a commit.
- [ ] **R3-05** Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly.

</details>

<details>
<summary>☐ <strong>R4 — Incremental governance</strong></summary>

- [ ] **R4-01** Recheck only rules affected by changed facts and emit diagnostic deltas.
- [ ] **R4-02** Prove incremental checking equivalent to full checking.
- [ ] **R4-03** Expose the checker through an LSP/editor loop.
- [ ] **R4-04** Expose governance context and diagnostic deltas through an MCP adapter for agent clients.

</details>

<details>
<summary>☐ <strong>R5 — Governed runtime compiler</strong></summary>

- [ ] **R5-01** Define typed Environment/Runtime IR.
- [ ] **R5-02** Compile valid projects through a devenv backend.
- [ ] **R5-03** Expose `govenv shell`, `govenv test`, and `govenv up`.

</details>

<details>
<summary>☐ <strong>R6 — Product bootstrap and self-hosting</strong></summary>

- [ ] **R6-01** Ship a standalone `govenv` entrypoint and managed runtime setup.
- [ ] **R6-02** Make Govenv govern and build itself.
- [ ] **R6-03** Keep runtime backends replaceable behind the typed IR boundary.
- [ ] **R6-04** Support white-label distributions while keeping the formal kernel reusable and product-neutral.

</details>

## Getting started

Govenv currently uses devenv only as its Stage 0 bootstrap environment.

The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`.

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
