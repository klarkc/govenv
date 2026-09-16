# Pages history checkout counterexample

Observed in Materialize run #41 (`35107610323`), Pages build job
`104836021166`, while evaluating effective revision
`d4a2cea1e062b2168c737d30ec00c9f85400e1a8` on 2026-09-16.

The reusable Test and Release workflows fetched full Git history, but Pages
used the default shallow checkout before executing the same `govenv:check`.
After GV95 made canonical changelog validation depend on immutable published
tags, the Pages check failed before documentation build with:

```text
Canonical changelog materialization requires a published release tag.
Process completed with exit code 1.
```

The counterexample demonstrates that any governed workflow which executes the
tag-aware repository check must make the required release history observable.
For Pages, candidate validation must therefore require its checkout step to
fetch full history and tags before `govenv:check` may execute.
