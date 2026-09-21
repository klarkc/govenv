# GV1 source-placement counterexample

PR #32 introduced reusable constitutional-history kernel experiments as
root-level Agda modules under `spike/`.

GV1 is established and requires project governance under `Govenv/` and
reusable kernel code under `Govenv.Kernel.*`. The governed source boundary is
`Govenv.lagda.md`, `Govenv/`, and `src/Govenv/`; root-level `spike/` lies
outside that boundary.

The observed contradictory candidate included:

```text
spike/ConstitutionalHistory.agda
spike/ConstitutionalHistoryPropositional.agda
spike/ConstitutionalHistoryStdlib.agda
```

Before the GV1 candidate-state assurance was wired into `govenv:check`, that
check had no source-placement validation and therefore did not report this
contradiction. The branch also demonstrated a staged candidate in which
`govenv:check` completed successfully while these paths were present; later
committed runs could fail independently on release-materialization drift.

The repaired assurance observes the candidate's tracked `*.agda` and
`*.lagda.md` paths, applies the governed GV1 source-boundary rule, and rejects
the first source outside the governed Govenv source roots. With the original
paths still present, the repaired local check reports:

```text
GV1 source boundary violation: versioned Agda source outside Govenv source roots: spike/ConstitutionalHistory.agda
```

The executable regression is also preserved in `Govenv.Assurance.GV1` as
`counterexampleRejected`. The repair is not complete merely because the
offending experiment is moved; recurrence must continue to be rejected by the
same candidate-state assurance.
