# Release governance history-preservation counterexample

Observed after release pull request #3 entered `main` on 2026-09-15. Revision
`733c8126375b9b322de505fae7b5471f796af1fb` contained the `0.2.1` governance
impact, but the previously canonical `0.2.0` governance impact that exists at
tag `v0.2.0` had disappeared. Materialize run #37 accepted that state with no
materialization drift, exposing an adapter assurance gap under GV84.

The reduced changelog below records the destructive precondition. Canonical
reconstruction must no longer trust this mutable surviving history: every
published entry represented here must instead be reconstructed from its
immutable release tag and preserved byte-for-byte in the generated changelog.

# Changelog

## [0.2.1](https://github.com/klarkc/govenv/compare/v0.2.0...v0.2.1) (2026-09-15)

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged
**Items:** stale target impact
<!-- govenv-governance-impact:end -->

### Governance

* newest release content

## [0.2.0](https://github.com/klarkc/govenv/compare/v0.1.0...v0.2.0) (2026-09-11)

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** + ▣ P1 — phase governance introduced
**Items:** historical release impact
<!-- govenv-governance-impact:end -->

### Governance

* historical release content
