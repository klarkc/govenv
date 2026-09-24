# GV18 candidate materialization counterexample

Observed on GitHub Actions Test run `35996248284` for pull request #40.

Candidate semantic revision:

```text
5770bc35976c73a883dc1728ad5cc3c5a363a68a
```

The candidate passed local materialization and full Govenv checks after its
governed outputs were regenerated, but the pull-request Test workflow checked
the clean semantic commit directly. `CHANGELOG.md` still described the previous
semantic revision, so `govenv:check` rejected tracked drift before the
post-authorization Materialize workflow had any chance to create the derived
commit.

The workaround was a manually-created derived commit:

```text
9ea32c00730d356d0134325312274da635dc3ec6
chore(materialize): update governed materializations
Derived-From-Parent: true
```

That workaround is not the desired authoring protocol. Candidate authors and
agents must be able to submit semantic authority without manually manufacturing
the deterministic derived commit.

Regression expectation:

1. Test checks out the exact candidate revision with no write capability.
2. Test runs `govenv:materialize` only in its ephemeral workspace.
3. Test exposes the resulting tracked drift as a review preview.
4. Test runs `govenv:check` against that transient materialized state.
5. Test never commits or pushes candidate materializations.
6. After human merge, Materialize remains the only workflow that writes the
   canonical `chore(materialize)` commit to `main`.
