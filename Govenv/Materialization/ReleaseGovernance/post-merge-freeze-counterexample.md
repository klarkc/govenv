# Post-merge release freeze materialization counterexample

Observed on 2026-09-16 after the human-approved release pull request #15 was
rebase-merged. Materialize run #48 evaluated the merged frozen revision
`e76acb119c6514e93ef90312f1c956f308a42a42` before tag or GitHub Release
publication.

The committed canonical changelog contained exactly one approved `0.2.2` freeze
boundary, based on `v0.2.1` and authorized by semantic revision
`7d9dc5ed1d379417ba3efe9070d19a65de941419`. The release manifest already named
`0.2.2`, while the latest published tag was still `v0.2.1`.

`govenv:materialize` rendered the canonical changelog by redirecting the renderer
directly onto `CHANGELOG.md`. Shell redirection truncated that file before
`release-governance.sh` could read the approved freeze it was required to preserve,
so materialization failed with:

```text
Release 0.2.2 must have exactly one governed freeze boundary.
```

Test, Release, and Pages were consequently blocked, and neither tag `v0.2.2` nor
the corresponding GitHub Release was published.

Canonical changelog materialization must render to a sibling temporary file while
the committed changelog remains available as governed input. Only a successful
render may atomically replace the destination. A failed render must leave the
approved freeze unchanged across the merge-to-publication boundary.
