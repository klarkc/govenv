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

- [x] **R0 — Bootstrap and project shape**
  - [x] **R0.1** Literate `Govenv.lagda.md` closure root.
  - [x] **R0.2** Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`.
  - [x] **R0.3** Reproducible Stage 0 bootstrap, documentation site, and automated releases.
- [ ] **R1 — Formal governance kernel** ← current
  - [x] **R1.1** `Verdict`: `holds`, `violated`, and `unknown`.
  - [x] **R1.2** Minimal `Rule` abstraction.
  - [x] **R1.3** Typed repository facts.
  - [ ] **R1.4** Dependency-indexed rules.
  - [ ] **R1.5** Roadmap release rule: every major or minor release must advance the README roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt.
  - [ ] **R1.6** Encode R1.5 as Govenv's first self-governing repository rule.
- [ ] **R2 — Pure repository evaluator**
  - [ ] **R2.1** Evaluate facts, rules, verdicts, obligations, and diagnostics without IO.
- [ ] **R3 — `govenv check`**
  - [ ] **R3.1** Observe repository facts through a thin impure adapter.
  - [ ] **R3.2** Produce source-mapped governance diagnostics from the pure kernel.
- [ ] **R4 — Incremental governance**
  - [ ] **R4.1** Recheck only rules affected by changed facts and emit diagnostic deltas.
  - [ ] **R4.2** Prove incremental checking equivalent to full checking.
  - [ ] **R4.3** Expose the checker through an LSP/editor loop.
- [ ] **R5 — Governed runtime compiler**
  - [ ] **R5.1** Define typed Environment/Runtime IR.
  - [ ] **R5.2** Compile valid projects through a devenv backend.
  - [ ] **R5.3** Expose `govenv shell`, `govenv test`, and `govenv up`.
- [ ] **R6 — Product bootstrap and self-hosting**
  - [ ] **R6.1** Ship a standalone `govenv` entrypoint and managed runtime setup.
  - [ ] **R6.2** Make Govenv govern and build itself.
  - [ ] **R6.3** Keep runtime backends replaceable behind the typed IR boundary.
  - [ ] **R6.4** Support white-label distributions while keeping the formal kernel reusable and product-neutral.

## Bootstrap

Govenv currently uses devenv only as its Stage 0 bootstrap environment.

The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`.

## Test

Run the test suite with the pinned devenv tag:

```bash
nix run github:cachix/devenv/v2.3 -- test
```

This type-checks the literate Agda entrypoint `Govenv.lagda.md` and its imported Govenv modules.

## Documentation

Build the literate Agda documentation locally with:

```bash
nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs
```

The static site is written to `_site/` and deployed to GitHub Pages from `main`.
