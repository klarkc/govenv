# Unreleased notes counterexample

The `v0.2.3` cycle exposed a GV95 regression after PR #24 was merged.
At derived main revision `5983ff63b9279919a4e9b2fec655c7f2acdeeaaa`,
the canonical `Unreleased` governance range correctly ended at semantic authority
`c41881fb5fcb8cb3eef5ea945ca7eeb8be67cdc6`, but the conventional release note
for that commit was absent from `Unreleased`.

Observed `Unreleased` footer:

```text
e76acb1..c41881f
```

Missing note:

```text
fix(release): require verified publication boundary (c41881f)
```

Release Please later introduced that note only when freezing the `0.2.3`
candidate. Therefore the candidate gained content that had never existed in the
canonical `Unreleased` payload, contradicting GV95's requirement to freeze that
exact governed state.

The repair must make semantic Conventional Commit notes part of `Unreleased`,
exclude derived materialization commits from release-note content, and prove
that freezing changes only candidate metadata while preserving the complete
`Unreleased` payload byte-for-byte.
