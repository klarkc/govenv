# Rebase provenance counterexample

Observed after pull request #16 was merged with GitHub's rebase strategy on
2026-09-16. Candidate commit `c31bfa531c8c63d73631a406e3e6ae4be0ac7e23`
was the semantic parent of candidate materialization commit
`932fd7f08fca1b354e04136047b49686b22b8a99`. Rebase rewrote them to
`d7d131482448e9ead1c1f2d71aefd9eaf328238a` and
`f86ee5870abf527b4f065f827277be701f131441` respectively.

The landed materialization commit retained the pre-rebase trailer:

```text
chore(materialize): update governed materializations

Derived-From-Revision: c31bfa531c8c63d73631a406e3e6ae4be0ac7e23
```

Materialize run #39 then failed before any effect with:

```text
fatal: Needed a single revision
fatal: Not a valid commit name c31bfa531c8c63d73631a406e3e6ae4be0ac7e23
Derived materialization provenance is not an ancestor of HEAD.
```

The counterexample demonstrates that an embedded parent SHA is not rebase-stable.
A derived materialization must instead resolve its causal revision from the
single-parent Git edge of the materialization commit itself; derived commit
`Refs:` must not create independent semantic authority.
