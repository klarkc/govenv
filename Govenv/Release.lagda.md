# Release governance

A release has two independent views: SemVer describes product/API impact, while the governance delta describes what became true or moved forward in the governed project.

The governance delta classifies roadmap items as follows:

- `completed`: the item becomes done in the release.
- `advanced`: commits in the release reference the item, but it remains todo.
- `introduced`: the item is newly declared and remains todo without implementation evidence.

A release also records the active phase before and after the release. GV7 will consume this delta: major and minor releases must contain at least one completed item or advance to a later phase; patch releases are exempt.

Rendered release artifacts reuse the roadmap vocabulary: completed items render as `✓ GV…`; advanced and introduced items remain pending and render as `○ GV…`; phase progression renders the previous phase as finished and the new phase as active, for example `■ P1 → ▣ P2`.

```agda
{-# OPTIONS --safe #-}

module Govenv.Release where

open import Govenv.Kernel.Release public
```
