# Post-publication Unreleased convergence counterexample

Observed on 2026-09-16 after Materialize run #49 successfully published and
read back GitHub Release `v0.2.2`.

The published tag correctly targeted the approved release boundary
`e76acb119c6514e93ef90312f1c956f308a42a42`, while `main` remained at the
later authorized repair revision `8dddae741144a242a4a5211cc5d44a1c2cfb338c`.
The release workflow also created and governed release candidate #22 for
`0.2.3`, authorized by that later revision.

A fresh full-history checkout of exact `main` after publication then ran:

```text
nix run github:cachix/devenv/v2.3 -- tasks run govenv:materialize:check
```

and failed because publication had changed the latest immutable release
boundary after the initial materialization check. The canonical renderer now
required the `Unreleased` governance delta `e76acb1..8dddae7`, but `main`
still contained the pre-publication empty `Unreleased` section followed by
the frozen `0.2.2` entry.

The successful publication and read-back of `v0.2.2` were not invalidated;
the contradiction was specifically that the authorized repository state did
not reconverge after the external release boundary advanced.

After Release completes, the parent Materialize workflow must compare the
latest release tag with the boundary observed before Release. If publication
advanced that boundary, only the governed `authorized-materialization`
identity may derive and push the resulting canonical state. When that creates
a derived `main` revision, Release Please must run once more against that
revision so the next frozen candidate is reconciled with the newly canonical
`Unreleased` state. Release publication authority must not receive the
materializer credential or generic Actions-dispatch capability to accomplish
this transition.
