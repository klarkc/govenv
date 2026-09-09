# Release governance

A release has two independent views: SemVer describes product/API impact, while the governance delta describes what became true or moved forward in the governed project.

The governance delta is computed purely from a previous typed roadmap snapshot, the current typed roadmap, and governed `Refs: GV…` commit attribution. Human-facing README or changelog text is never interpreted as governance state.

The governance delta classifies roadmap items as follows:

- `completed`: a previously pending item becomes done, or a newly declared done item has explicit governed `Refs: GV…` implementation evidence in the release.
- `advanced`: the item remains pending and release commits explicitly reference it through governed `Refs: GV…` metadata.
- `introduced`: the item did not exist in the previous governed snapshot and has no governed commit attribution. Its state is preserved, so an introduced item may already be `✓` or remain `◇`.

This conservative distinction avoids rewriting history by inference. The `v0.1.0` baseline predates the stable roadmap snapshot and is therefore represented as an absent historical roadmap; subsequent releases compare the versioned `.govenv/roadmap.snapshot` artifact directly. Releases from before governed commit attribution may therefore show an already-satisfied item as `✓ + introduced` rather than claiming it was implemented in that release.

A governance delta is invalid if a previously completed item becomes pending, a previously governed item disappears, or phase progression moves backwards.

Phase progress is typed separately as introduced, unchanged, advanced, or roadmap-completed. GV7 will consume this delta: major and minor releases must contain at least one completed item or advance to a later phase; patch releases are exempt.

The governed `releaseGovernanceImpact` section is materialized independently into both the Release Please pull-request body and its `CHANGELOG.md`, with read-back equality verification. Rendered release artifacts reuse the roadmap vocabulary and add change glyphs. A phase advance is rendered as `■ P1 → ▣ P2`; item impact is rendered as a tree, for example:

```text
├ ✓ GV45  completed
├ ◇ GV28  ↑ advanced
└ ✓ GV3   + introduced
```

```agda
{-# OPTIONS --safe #-}

module Govenv.Release where

open import Govenv.Kernel.Release public
```
