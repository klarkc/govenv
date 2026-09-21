# Published release renderer counterexample

Run `35256420319` published `v0.2.4` successfully after PR #26, but the post-publication governance read-back failed even though the published body carried the canonical portable canonical release entry.

The expected document was still rendered through the legacy GitHub-specific projection, producing this false mismatch:

```diff
-<sub>Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `8728e3d..034324b`.</sub>
+Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `8728e3d..034324b`.
```

This is not only an HTML-footer discrepancy: the GitHub-specific renderer also has distinct supersession rendering. Therefore publication verification must derive its expected governance section from the same portable renderer that owns the canonical `ReleaseEntry`, rather than maintaining a second presentation-specific semantic projection.

A later completion transition of GV95 exposed a second boundary condition in the regression itself: replaying the old release through the current roadmap reinterpreted the historical delta (`GV95 ◇ ↑` became `GV95 ◇ → ✓`). Historical publication evidence must therefore be compared against the immutable release boundary that originally froze it, not re-derived through a later roadmap state. Candidate validation preserves the `v0.2.4` governance section byte-for-byte from `v0.2.4:CHANGELOG.md` while separately requiring the publication adapter to use the portable renderer.
