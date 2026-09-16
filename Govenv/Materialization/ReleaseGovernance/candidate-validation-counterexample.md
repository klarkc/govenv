# Release candidate validation counterexample

Observed on 2026-09-16 after Materialize run #43 updated release pull request #15.
Release Please and `release-governance-pr.sh` produced the frozen candidate head
`ec9ce3e24f74aab6b29eb168b13def6019f74969`, whose freeze was bound to semantic
revision `e0186e9fbafe97ef08589b04cd3903aa0aaecc4f`.

The candidate branch was mutated with the workflow `GITHUB_TOKEN`. GitHub did not
schedule the normal pull-request Test workflow for that mutation; observation with
`gh pr checks 15 --repo klarkc/govenv` returned:

```text
no checks reported on the 'release-please--branches--main--components--govenv' branch
```

The release job had checked the authorized main revision before candidate mutation
and verified the frozen changelog/body by read-back, but no unprivileged full
repository check executed against the final candidate SHA before human approval.
A manual read-only `govenv:check` of the exact candidate SHA passed, demonstrating
that the candidate was valid while the governed validation boundary was incomplete.

After release-candidate materialization, the exact final candidate revision must be
resolved and passed to the reusable Test workflow under read-only permissions. The
candidate repository state must never execute with Release's privileged token or
authorized-effects environment.
