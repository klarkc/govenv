# Published release verification counterexample

Materialize run #57 published GitHub Release `v0.2.4` from exact approved
revision `f8202bcf9ef85b40257f6562d1af76eaec94ef64`, whose tree was byte-identical
to candidate revision `a2c9d6702324b581fd433a3869b0e3888a77aea3`.
The published body already matched the canonical portable release entry.

The governed read-back nevertheless failed because
`.govenv/release-governance-release.md` was rendered with the GitHub-specific
projection while `CHANGELOG.md` intentionally carries the portable projection.
The only observed governance difference was the presentation wrapper:

```diff
-<sub>Derived from immutable typed roadmap snapshots ... `8728e3d..034324b`.</sub>
+Derived from immutable typed roadmap snapshots ... `8728e3d..034324b`.
```

The failure correctly prevented `post-release-materialize` from running, but it
also exposed that this protection existed only inside that workflow run.
A later fresh checkout would select `v0.2.4` with `git describe` even though
its publication read-back had never succeeded, allowing mere tag existence to
become release-boundary authority on a subsequent run.

The repair therefore has two obligations. Published-release verification must
compare the canonical changelog entry against the independently reconstructed
**portable** governed projection, while retaining whole-body equality for the
GitHub Release. Verification must also be idempotent: an already-canonical
immutable Release is read back without mutation.

Finally, every fresh Materialize run must read-only verify the latest published
Release before using its tag as the canonical changelog boundary. Same-run
post-release advancement remains gated by successful Release verification.
Thus a failed external read-back cannot become trusted merely by surviving into
a later workflow run.