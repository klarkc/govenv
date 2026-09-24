# solo098 Govenv recovery snapshot

Captured read-only from Govenv worktrees on 2026-09-23.
Only non-reproducible/recovery-relevant Git state is retained; caches and generated build state are excluded.

## Worktrees
```text
worktree /home/klarkc/Sources/klarkc/govenv
HEAD d18a4a3304114b7441282cdf59dd4ab82e897e7e
branch refs/heads/main

worktree /home/klarkc/Sources/klarkc/govenv-admin-history
HEAD 9529eb7b41434748f3bf032f9b12223e71606730
branch refs/heads/gov/authorized-external-effects

worktree /home/klarkc/Sources/klarkc/govenv-admin-readback-fix
HEAD 5809e0474589ead91fda571a751fb2bb38b8e362
branch refs/heads/gov/materializer-client-id-boundary

worktree /home/klarkc/Sources/klarkc/govenv-admin-setup
HEAD 346aee0928d29bb385c7fc37c21eacc2e34b9259
branch refs/heads/gov/admin-setup-bootstrap

worktree /home/klarkc/Sources/klarkc/govenv-candidate-test-revision-fix
HEAD c109deb03c8788fec9e6abcecf0ae5b6b7a9ff24
branch refs/heads/fix/candidate-test-revision

worktree /home/klarkc/Sources/klarkc/govenv-gv101
HEAD 032fb1a3cfa189e5e3e8600b6180f5b41e4d081a
branch refs/heads/gov/gv101-global-classification

worktree /home/klarkc/Sources/klarkc/govenv-gv44-closure
HEAD 3436561e48adff166122b63c439ce8be8c252878
branch refs/heads/fix/gv44-materialize-closure

worktree /home/klarkc/Sources/klarkc/govenv-gv44-workflow-parse
HEAD f229251d459b19910eaace0a68083220d41e7bb9
branch refs/heads/fix/gv44-workflow-parse

worktree /home/klarkc/Sources/klarkc/govenv-gv84
HEAD 3467b29e4662ed0151734c876b28e968d59f0228
branch refs/heads/gov/gv84-counterexample-closure

worktree /home/klarkc/Sources/klarkc/govenv-gv90-stage-b
HEAD 500e3e76de652fd6b8c255b3fe2648ea06c0716c
branch refs/heads/wip/gv90-stage-b

worktree /home/klarkc/Sources/klarkc/govenv-gv90-stage-b-clean
HEAD 109afb57a01c3d440742f7d528db412e7152cee3
branch refs/heads/wip/gv90-stage-b-clean

worktree /home/klarkc/Sources/klarkc/govenv-gv90-stage-c
HEAD 69a4525cc1426e5a9d3d516992f8f52c1c86b86d
branch refs/heads/wip/gv90-stage-c

worktree /home/klarkc/Sources/klarkc/govenv-gv92
HEAD 52575cf8b987f43bff781ccb17d08125e04d51c0
branch refs/heads/gov/gv92-admin-root

worktree /home/klarkc/Sources/klarkc/govenv-gv92-setup
HEAD 5ea0b20bf259db48f52db3b8eba228ac7ebce21a
branch refs/heads/gov/gv92-setup

worktree /home/klarkc/Sources/klarkc/govenv-gv92-setup-readback
HEAD 7b4873b41cd085c602c302ca11d5d5f3a949b71d
branch refs/heads/gov/gv92-setup-readback

worktree /home/klarkc/Sources/klarkc/govenv-gv92-stage-a-main
HEAD 3597c844e55966b46926526a0114fcafd838a92b
branch refs/heads/wip/gv92-stage-a-main

worktree /home/klarkc/Sources/klarkc/govenv-gv92-stage-b
HEAD 335f410f8892bf521ca77dafc52fd3130508bfc5
branch refs/heads/gov/gv92-stage-b

worktree /home/klarkc/Sources/klarkc/govenv-gv92-stage-c
HEAD b77d11091a44a6c53ef10b11daedf9a69f698c50
branch refs/heads/wip/gv92-stage-c

worktree /home/klarkc/Sources/klarkc/govenv-gv92-stage-d
HEAD 47e5768163f8647e4203794de309f5ff92c3b642
branch refs/heads/wip/gv84-release-placement

worktree /home/klarkc/Sources/klarkc/govenv-gv94
HEAD 2a343faf84a1de23c536f48f5420567ce36665be
branch refs/heads/gov/gv94-derived-current

worktree /home/klarkc/Sources/klarkc/govenv-gv95-complete-check
HEAD e67a2cac808b982e345e3d1adf9f43a4b95c6b09
detached

worktree /home/klarkc/Sources/klarkc/govenv-gv95-release-renderer
HEAD 7daa0bcd9c6eb6afa62c92edc4e72ff4ead334f8
branch refs/heads/fix/gv95-release-renderer

worktree /home/klarkc/Sources/klarkc/govenv-gv95-unreleased-notes
HEAD db6e61d1239471c555a1077ae368c825ef49b275
branch refs/heads/fix/gv95-unreleased-notes

worktree /home/klarkc/Sources/klarkc/govenv-history-spike
HEAD 72786747c8f2e19053e54baa610cda79b02b1fce
branch refs/heads/spike/constitutional-history

worktree /home/klarkc/Sources/klarkc/govenv-pages-history-fix
HEAD 73486ccc2fe24a15c90365b1c5f3253c9f50d9ba
branch refs/heads/fix/pages-history-checkout

worktree /home/klarkc/Sources/klarkc/govenv-post-release-convergence-fix
HEAD e2c493c0cdbb9fcf895a18b2c02b029df796d58b
branch refs/heads/fix/release-post-publication-convergence

worktree /home/klarkc/Sources/klarkc/govenv-post-v022-check
HEAD 8dddae741144a242a4a5211cc5d44a1c2cfb338c
detached

worktree /home/klarkc/Sources/klarkc/govenv-pr23-postmerge-check
HEAD 4a27d53df22b504a9b1cd35764ee2ed3f4ca2a39
detached

worktree /home/klarkc/Sources/klarkc/govenv-pr5-verify
HEAD 8dadeb6dd066dd92f29b170ac45b0a7a0a3a7818
detached

worktree /home/klarkc/Sources/klarkc/govenv-purpose
HEAD ad94133790efc4e872b656757d246d8d13dff670
branch refs/heads/gov/product-purpose-stewardship

worktree /home/klarkc/Sources/klarkc/govenv-release-027-check
HEAD 18ef034968821ca04fcbe6df27ca8613fc393707
detached

worktree /home/klarkc/Sources/klarkc/govenv-release-auth-fix
HEAD 18d7893fe481ee400e1683c1caf0a2eea6726676
branch refs/heads/fix/release-governance-auth

worktree /home/klarkc/Sources/klarkc/govenv-release-candidate-validate
HEAD ec9ce3e24f74aab6b29eb168b13def6019f74969
detached

worktree /home/klarkc/Sources/klarkc/govenv-release-candidate-validation-fix
HEAD e7377762c659fbcc59cb2c7fa5bc1e04e8f762a3
branch refs/heads/fix/release-candidate-validation

worktree /home/klarkc/Sources/klarkc/govenv-release-history-fix
HEAD 733c8126375b9b322de505fae7b5471f796af1fb
branch refs/heads/fix/release-governance-history

worktree /home/klarkc/Sources/klarkc/govenv-release-postmerge-debug
HEAD e76acb119c6514e93ef90312f1c956f308a42a42
detached

worktree /home/klarkc/Sources/klarkc/govenv-release-postmerge-freeze-fix
HEAD 92e6d7d54b5d11af3f9d9f2fd1148f7d977c19e5
branch refs/heads/fix/release-postmerge-freeze-safe

worktree /home/klarkc/Sources/klarkc/govenv-release-verified-boundary-fix
HEAD 7f9653f0d1e5fcd5c20fcf44c16ab5b141cc6336
branch refs/heads/fix/release-verified-boundary

worktree /home/klarkc/Sources/klarkc/govenv-unreleased-history
HEAD 2006cc5a4d2577939c76d25e00bc87108a5c87d4
branch refs/heads/fix/rebase-stable-provenance

worktree /home/klarkc/Sources/klarkc/govenv-v024-verification-fix
HEAD b0265ce4a4e2176b4fa131e406acf2e5ca02f7c2
branch refs/heads/fix/v024-published-verification

worktree /home/klarkc/Sources/klarkc/govenv/govenv-gv84-release-main
HEAD 81c8b1f467c79b09b43ab17d99115ab40989b3c1
branch refs/heads/wip/gv84-release-placement-main

worktree /tmp/govenv-baseline-recovery
HEAD 79c08032d1eb574127854f3cd35a0e1bbbb86c5e
branch refs/heads/gov/baseline-session-corpus

```

## Stashes
```text
```
