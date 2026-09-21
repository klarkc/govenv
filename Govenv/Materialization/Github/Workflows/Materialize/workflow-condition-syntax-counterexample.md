# Materialize workflow condition syntax counterexample

After PR #33 was merged, push run `35645948292` for revision `2bd4b488d377632a5c640ec17015012177b0202e` failed immediately before GitHub created any jobs.

The generated Materialize workflow rendered a job condition as an unquoted YAML scalar while the expression contained the protocol text `Derived-From-Parent: true`. The colon made the workflow invalid YAML. `actionlint` reproduces the failure at the Materialize job `if:` line with `mapping values are not allowed in this context`.

The same event also demonstrated that a human-rebased commit may retain the derived protocol message while carrying human author/committer identity. Message content therefore classifies semantic derivation in Git history, but it is insufficient to classify whether a GitHub push was emitted by the governed materializer.

Candidate validation must reject syntactically invalid generated workflows before merge. Workflow conditions must be rendered as quoted YAML strings, and the GitHub event boundary must combine the derived protocol marker with the governed materializer commit identity before suppressing a push as an automated derived effect.
