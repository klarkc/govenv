# Test explicit-revision counterexample

Observed on 2026-09-16 in Materialize run #45 after PR #19 introduced the
read-only release-candidate validation boundary.

Release resolved the final PR #15 candidate head as
`4e35ba5e9fc29414c3aa495b94ca76683793d5b9` and passed that value to the
nested reusable Test workflow. The nested job log recorded:

```text
revision: 4e35ba5e9fc29414c3aa495b94ca76683793d5b9
ref: 1d8350e0891b6f9685f52063386475b03255d4d5
HEAD is now at 1d8350e chore(materialize): update governed materializations
```

The reusable workflow inherited the caller's `push` event context, so testing
`github.event_name == 'workflow_call'` did not identify the reusable call.
The explicit `inputs.revision` was therefore ignored and the checkout fell back
to `github.sha`, validating `main` rather than the frozen release candidate.

An explicit revision input must take precedence whenever it is non-empty,
independently of `github.event_name`. Direct pull-request runs may then fall
back to `github.event.pull_request.head.sha`, and standalone dispatch may fall
back to `github.sha`.
