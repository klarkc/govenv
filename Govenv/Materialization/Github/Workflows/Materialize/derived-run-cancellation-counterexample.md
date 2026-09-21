# Derived materialization run cancellation counterexample

PR #31 merged as authorized revision `0570dba38077b7d1a8dc25feafcb0c85ff20a33d`. Materialize run `35641826439` successfully materialized and checked that revision, committed derived revision `f8ca0cf748358219b1265e049e3928c4822d6c31`, pushed it to `main`, and recorded it as the effective SHA.

That derived push immediately triggered run `35642153023` in the same workflow concurrency group. The new run cancelled the authorizing run before its downstream Test, Release, and Pages jobs could execute. The successor run was itself cancelled during materialization, leaving `main` at the derived revision without a terminal successful authorizing pipeline.

This demonstrates two invalid assumptions in the previous workflow boundary:

1. a derived materialization push may compete with and cancel the run whose authorized revision caused it;
2. a workflow triggered by a derived commit may be treated as though the derived commit were fresh authorization.

A derived materialization commit creates no independent semantic authority. Its push must therefore be isolated from the concurrency group of authorizing runs and must not start a new materializer authority path. The original authorizing run already carries the derived effective revision and remains responsible for validation, publication, and any governed post-release reconciliation.
