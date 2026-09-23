# Govenv recovery baseline — 2026-09-23

Temporary recovery corpus used to reconcile session knowledge and unpublished local Govenv state with the governed project state.

## Session corpus

- Source file: `govenv.tar.gz` uploaded in the recovery session.
- SHA-256: `61e4fa1bd628c4b5d15b0be63e3bcc20226d0be1ad29f3e690a12fcb9bf8ce6d`
- Size: 155663 bytes.
- Unique session handoffs: 24.
- Persistent ChatGPT Library file id: `libfile_17689007859c819187c2666ee0a4ad84`.

The original corpus is an immutable recovery input. Do not reinterpret absence from the current roadmap as disposition.

## Local Govenv state

`solo098/` preserves only non-reproducible Govenv state that may encode decisions not present in current `main`: semantic patches, selected untracked source/evidence, and a Git bundle of relevant unpublished heads. Generated caches/build outputs and clean worktrees are intentionally excluded.

## Removal condition

This directory may be removed only after every session observation and every retained local-state line has an explicit disposition into one of:

- tracked by current governed state / roadmap / protocol / architecture / assurance;
- superseded by an identified governed decision;
- deliberately rejected with rationale;
- irrelevant to the project's intended state, with rationale.

Removal must itself be reviewed as a consolidation event; absence is never evidence of completion.
