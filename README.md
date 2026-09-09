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

**Current:** Phase 1 — Formal governance kernel. `Verdict`, typed `Fact`, and the current `Rule` model are in place; dependency-indexed rules and the first self-governing rule are next.

- [x] **Phase 0 — Bootstrap and project shape**
  - Literate `Govenv.lagda.md` closure root.
  - Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`.
  - Reproducible Stage 0 bootstrap, documentation site, and automated releases.
- [ ] **Phase 1 — Formal governance kernel** ← current
  - [x] `Verdict`: `holds`, `violated`, and `unknown`.
  - [x] Minimal `Rule` abstraction.
  - [x] Typed repository facts.
  - [ ] Dependency-indexed rules.
  - [ ] Roadmap governance rule: every major or minor release must advance the README roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt.
  - [ ] Encode the roadmap rule as Govenv's first self-governing repository rule.
- [ ] **Phase 2 — Pure repository evaluator**
  - Evaluate facts, rules, verdicts, obligations, and diagnostics without IO.
- [ ] **Phase 3 — `govenv check`**
  - Observe repository facts through a thin impure adapter.
  - Produce source-mapped governance diagnostics from the pure kernel.
- [ ] **Phase 4 — Incremental governance**
  - Recheck only rules affected by changed facts and emit diagnostic deltas.
  - Prove incremental checking equivalent to full checking.
  - Expose the checker through an LSP/editor loop.
- [ ] **Phase 5 — Governed runtime compiler**
  - Define typed Environment/Runtime IR.
  - Compile valid projects through a devenv backend.
  - Expose `govenv shell`, `govenv test`, and `govenv up`.
- [ ] **Phase 6 — Product bootstrap and self-hosting**
  - Ship a standalone `govenv` entrypoint and managed runtime setup.
  - Make Govenv govern and build itself.
  - Keep runtime backends replaceable behind the typed IR boundary.

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
