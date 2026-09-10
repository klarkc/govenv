# Release governance

A release has two independent views: SemVer describes product/API impact, while the governance delta describes what became true or moved forward in the governed project.

The governance delta is computed purely from a previous immutable typed roadmap snapshot, the current typed roadmap, and governed `Refs: GV…` commit attribution. Human-facing README or changelog text is never interpreted as governance state.

A snapshot preserves each governance identity together with its owning phase, exact definition, and lifecycle state. Once introduced, a `GovernanceId` is append-only history: its definition and owning phase cannot change and the identity cannot disappear. Corrections or changed intent require a newer governance item; the old item remains present as `superseded` and points to that replacement. Work abandoned without replacement remains present as `cancelled`.

The governance delta classifies legitimate roadmap evolution as follows:

- `introduced`: the identity did not exist in the previous governed snapshot. Introduction takes precedence over commit attribution, and the current lifecycle state is preserved.
- `advanced`: a previously pending item remains pending and release commits explicitly reference it through governed `Refs: GV…` metadata.
- `completed`: a previously pending item becomes completed.
- `cancelled`: a previously pending item becomes explicitly cancelled.
- `superseded`: a previously pending or completed item becomes superseded and explicitly identifies its newer replacement.

Completed governance may be superseded when its definition later needs correction or replacement. Cancelled and superseded states are terminal; their identity, definition, owning phase, and supersession target cannot subsequently be rewritten. The roadmap constructor additionally requires every supersession target to exist and have a greater `GovernanceId`, making supersession point forward to a newer identity.

A governance delta is invalid if a governed identity disappears, its definition changes, its owning phase changes, a completed item regresses to pending, a terminal lifecycle is rewritten, or phase progression moves backwards. There is deliberately no `amended` state: even an orthographic correction requires supersession.

The `v0.1.0` baseline predates immutable governed roadmap snapshots and is therefore represented conservatively as an absent historical roadmap. Snapshot v2 is the first immutable-identity baseline; all subsequent releases compare the versioned `.govenv/roadmap.snapshot` artifact directly.

Phase progress is typed separately as introduced, unchanged, advanced, or roadmap-completed. GV55 will consume this delta: major and minor releases must contain governance progress according to the governed policy; patch releases are exempt.

The governed `releaseGovernanceImpact` section has one typed semantic document with three materialization targets. `CHANGELOG.md` is the canonical versioned repository-file section and uses a portable Markdown projection. The Release Please pull-request body uses an enriched GitHub projection of the same document. After Release Please publishes a GitHub Release, its body replaces the carried portable changelog section in place with that same enriched GitHub projection and verifies the external section by read-back equality. Item projections are compact: lifecycle-only changes show the governance identity and transition once, while supersessions align the previous and replacement propositions; GitHub projections visually distinguish changed spans, while the portable changelog uses standard Markdown diff fences.

```text
GV60  ◇ → ✓
Govern README.md as the canonical output …

GV14 ↪ GV60
- Govern the README as the canonical materialization of Govenv.Readme …
+ Govern README.md as the canonical output of Govenv.Materialization.Readme …
```

```agda
{-# OPTIONS --safe #-}

module Govenv.Release where

open import Govenv.Kernel.Release public
```
