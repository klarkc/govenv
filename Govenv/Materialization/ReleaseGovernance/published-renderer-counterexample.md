# Published release renderer counterexample

Run `35256420319` published `v0.2.4` successfully after PR #26, but the post-publication governance read-back failed even though the published body carried the canonical portable canonical release entry.

The expected document was still rendered through the legacy GitHub-specific projection, producing this false mismatch:

```diff
-<sub>Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `8728e3d..034324b`.</sub>
+Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `8728e3d..034324b`.
```

This is not only an HTML-footer discrepancy: the GitHub-specific renderer also has distinct supersession rendering. Therefore publication verification must derive its expected governance section from the same portable renderer that owns the canonical `ReleaseEntry`, rather than maintaining a second presentation-specific semantic projection.
