# Published release body read-back counterexample

Run `35512667953` published `v0.2.5` successfully after PR #28. Release Please created the release and the published body matched the canonical frozen release entry, but `Materialize published release governance` failed with:

```text
GitHub Release whole-body read-back verification failed.
```

The only reported difference was one additional empty line after the final release note:

```diff
@@ -20,3 +20,4 @@
 ### Bug Fixes

 * **release:** unify published release renderer (...)
+
```

The external GitHub Release body already ended with the canonical terminal newline. The observation path decoded the JSON body through record-oriented `gh --jq` output, which appended its own terminal newline and therefore made the local observation one newline longer than the external state.

Publication read-back must keep whole-body equality strict while decoding the JSON `body` field without adding an output record terminator. This preserves every body byte, including its canonical terminal newline, without trimming or otherwise weakening equality.
