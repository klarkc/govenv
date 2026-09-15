# Release governance push authorization counterexample

Observed on GitHub Actions run `35006600907` (`Materialize` #35) on
2026-09-15 after authorized revision
`b3ffd02a67c7cb0e091e5f28ab80362859d19ede` entered `main`.

The Release job intentionally checked out with `persist-credentials: false` and
received `contents: write` through its authorized-effects boundary. Release
Please successfully updated pull request #3, but the release-governance adapter
then attempted a plain Git push to the release branch without explicitly
binding the job-scoped GitHub token to Git credential acquisition.

The observed contradiction was:

```text
fatal: could not read Username for 'https://github.com': No such device or address
```

This fixture preserves the GV84 counterexample. Candidate validation must prove
that the release-branch mutation uses an explicit ephemeral `GH_TOKEN` bridge,
with checkout credential persistence and ambient credential helpers disabled.
