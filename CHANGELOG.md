# Changelog

## [Unreleased]

## [0.2.7](https://github.com/klarkc/govenv/compare/v0.2.6...v0.2.7) (2026-09-21)
<!-- govenv-release-freeze: version=0.2.7 base=v0.2.6 authorized=3dd0834de86d45c3254d3182650fc866e89ff16e -->

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged  
**Items:** 1 completed · 2 advanced

#### Completed · 1

| GV | Proposition |
| :---: | --- |
| **GV95 ◇ → ✓** | Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality. |

#### Advanced · 2

| GV | Proposition |
| :---: | --- |
| **GV84 ◇ ↑** | Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed. |
| **GV90 ◇ ↑** | Model human authorization as `AuthorizedRevision`: new semantic authority may originate only from the exact repository state accepted by an explicit human pull-request merge. Candidate revisions may perform unprivileged validation and transient non-authoritative projections, but automated candidate-authoring principals must be distinct from human authorizers and post-authorization materializers and must not receive capabilities that can alter executable automation, authorize or merge the candidate, mutate authoritative repository state, or mutate persistent governed external state; only after authorization may governed automation exercise the capabilities necessary to derive deterministic materialization revisions or external effects. Derived outcomes create no independent semantic authority, must not be treated as fresh human authorization, and must retain revision-addressable causal provenance to the authorizing revision. |

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `1be569a..3dd0834`.
<!-- govenv-governance-impact:end -->


### Bug Fixes

* **release:** preserve historical renderer boundary ([13c86c0](https://github.com/klarkc/govenv/commit/13c86c0be3268cdd503b38f066b3883768f47193))
* **materialize:** preserve authorizing run across derived push ([3361293](https://github.com/klarkc/govenv/commit/3361293bf8f77fb271c52e2ef79397042f37633d))
* **workflow:** close materialize projection boundary ([3dd0834](https://github.com/klarkc/govenv/commit/3dd0834de86d45c3254d3182650fc866e89ff16e))


### Governance

* **roadmap:** complete GV95 ([b934509](https://github.com/klarkc/govenv/commit/b9345094ccb9a55062dbd90a74bf11e3af96c791))
* **assurance:** establish GV95 completion evidence ([662f841](https://github.com/klarkc/govenv/commit/662f84107b0c86a4d53a95d8b10dc2b8687843e5))

## [0.2.6](https://github.com/klarkc/govenv/compare/v0.2.5...v0.2.6) (2026-09-21)
<!-- govenv-release-freeze: version=0.2.6 base=v0.2.5 authorized=29b5926cf6d1a590ec2a9afa3427af14d75d1e64 -->

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged  
**Items:** 2 advanced

#### Advanced · 2

| GV | Proposition |
| :---: | --- |
| **GV84 ◇ ↑** | Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed. |
| **GV95 ◇ ↑** | Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality. |

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `135cfa8..29b5926`.
<!-- govenv-governance-impact:end -->


### Bug Fixes

* **release:** preserve exact published body read-back ([29b5926](https://github.com/klarkc/govenv/commit/29b5926cf6d1a590ec2a9afa3427af14d75d1e64))

## [0.2.5](https://github.com/klarkc/govenv/compare/v0.2.4...v0.2.5) (2026-09-17)
<!-- govenv-release-freeze: version=0.2.5 base=v0.2.4 authorized=67362b998103d534d697dba3e7a40da9d28b0c8c -->

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged  
**Items:** 2 advanced

#### Advanced · 2

| GV | Proposition |
| :---: | --- |
| **GV84 ◇ ↑** | Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed. |
| **GV95 ◇ ↑** | Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality. |

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `f8202bc..67362b9`.
<!-- govenv-governance-impact:end -->


### Bug Fixes

* **release:** unify published release renderer ([67362b9](https://github.com/klarkc/govenv/commit/67362b998103d534d697dba3e7a40da9d28b0c8c))

## [0.2.4](https://github.com/klarkc/govenv/compare/v0.2.3...v0.2.4) (2026-09-17)
<!-- govenv-release-freeze: version=0.2.4 base=v0.2.3 authorized=034324bdfcc3af0d698121a266e31f5279b71510 -->

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged  
**Items:** 4 advanced

#### Advanced · 4

| GV | Proposition |
| :---: | --- |
| **GV59 ◇ ↑** | Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions. |
| **GV84 ◇ ↑** | Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed. |
| **GV90 ◇ ↑** | Model human authorization as `AuthorizedRevision`: new semantic authority may originate only from the exact repository state accepted by an explicit human pull-request merge. Candidate revisions may perform unprivileged validation and transient non-authoritative projections, but automated candidate-authoring principals must be distinct from human authorizers and post-authorization materializers and must not receive capabilities that can alter executable automation, authorize or merge the candidate, mutate authoritative repository state, or mutate persistent governed external state; only after authorization may governed automation exercise the capabilities necessary to derive deterministic materialization revisions or external effects. Derived outcomes create no independent semantic authority, must not be treated as fresh human authorization, and must retain revision-addressable causal provenance to the authorizing revision. |
| **GV95 ◇ ↑** | Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality. |

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `8728e3d..034324b`.
<!-- govenv-governance-impact:end -->


### Bug Fixes

* **release:** freeze exact Unreleased notes ([034324b](https://github.com/klarkc/govenv/commit/034324bdfcc3af0d698121a266e31f5279b71510))

## [0.2.3](https://github.com/klarkc/govenv/compare/v0.2.2...v0.2.3) (2026-09-17)
<!-- govenv-release-freeze: version=0.2.3 base=v0.2.2 authorized=c41881fb5fcb8cb3eef5ea945ca7eeb8be67cdc6 -->

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged  
**Items:** 7 advanced

#### Advanced · 7

| GV | Proposition |
| :---: | --- |
| **GV59 ◇ ↑** | Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions. |
| **GV18 ◇ ↑** | Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations. |
| **GV63 ◇ ↑** | Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries. |
| **GV84 ◇ ↑** | Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed. |
| **GV90 ◇ ↑** | Model human authorization as `AuthorizedRevision`: new semantic authority may originate only from the exact repository state accepted by an explicit human pull-request merge. Candidate revisions may perform unprivileged validation and transient non-authoritative projections, but automated candidate-authoring principals must be distinct from human authorizers and post-authorization materializers and must not receive capabilities that can alter executable automation, authorize or merge the candidate, mutate authoritative repository state, or mutate persistent governed external state; only after authorization may governed automation exercise the capabilities necessary to derive deterministic materialization revisions or external effects. Derived outcomes create no independent semantic authority, must not be treated as fresh human authorization, and must retain revision-addressable causal provenance to the authorizing revision. |
| **GV95 ◇ ↑** | Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality. |
| **GV88 ◇ ↑** | Require every governable obligation to be enforced at its earliest sound information boundary while retaining `govenv check` as the authoritative repository evaluation and deriving every anticipatory enforcement from the same governed rule. Maintain an explicit enforcement inventory that anticipates, at minimum: construction-time Agda constraints for typed identities, roadmap/lifecycle validity, constitutional structure, evidence relationships, pure kernel boundaries, and projection/materialization structure; static candidate or incremental/LSP checks for governance evolution, immutable identity, architecture imports, handwritten-source restrictions, materialization ownership and drift, artifact colocation, documentation references, regression obligations, governance/release deltas, and release-progress classification; commit-boundary checks for staged candidate validity, commit policy, governance references, semantic commit classification, and regression signals; PR/CI checks only for information first available from GitHub or the remote candidate; and post-effect checks only for irreducible external observations such as read-back equality, publication state, admin effects, and runtime facts. Later stages may confirm earlier results but must not re-own, duplicate, or independently specify semantics that were soundly enforceable earlier. |

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `e76acb1..c41881f`.
<!-- govenv-governance-impact:end -->


### Bug Fixes

* **release:** converge main after publication ([224e67f](https://github.com/klarkc/govenv/commit/224e67fcf7e9c5856096ed127734ef4b5912c937))
* **release:** preserve post-merge freeze materialization ([8dddae7](https://github.com/klarkc/govenv/commit/8dddae741144a242a4a5211cc5d44a1c2cfb338c))
* **release:** require verified publication boundary ([c41881f](https://github.com/klarkc/govenv/commit/c41881fb5fcb8cb3eef5ea945ca7eeb8be67cdc6))


### Miscellaneous

* **materialize:** update governed materializations ([5983ff6](https://github.com/klarkc/govenv/commit/5983ff63b9279919a4e9b2fec655c7f2acdeeaaa))
* **materialize:** update governed materializations ([9e30e00](https://github.com/klarkc/govenv/commit/9e30e004fff73f6e0eecea168cc5bc9abc5c6777))
* **materialize:** update governed materializations ([f7d4982](https://github.com/klarkc/govenv/commit/f7d4982bdeb5bc7f1274e8b6a16bbf1eb0278710))
* **materialize:** update governed materializations ([4a27d53](https://github.com/klarkc/govenv/commit/4a27d53df22b504a9b1cd35764ee2ed3f4ca2a39))
## [0.2.2](https://github.com/klarkc/govenv/compare/v0.2.1...v0.2.2) (2026-09-16)
<!-- govenv-release-freeze: version=0.2.2 base=v0.2.1 authorized=7d9dc5ed1d379417ba3efe9070d19a65de941419 -->

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged  
**Items:** 6 advanced · 2 introduced · 1 superseded

#### Advanced · 6

| GV | Proposition |
| :---: | --- |
| **GV59 ◇ ↑** | Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions. |
| **GV18 ◇ ↑** | Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations. |
| **GV63 ◇ ↑** | Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries. |
| **GV84 ◇ ↑** | Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed. |
| **GV90 ◇ ↑** | Model human authorization as `AuthorizedRevision`: new semantic authority may originate only from the exact repository state accepted by an explicit human pull-request merge. Candidate revisions may perform unprivileged validation and transient non-authoritative projections, but automated candidate-authoring principals must be distinct from human authorizers and post-authorization materializers and must not receive capabilities that can alter executable automation, authorize or merge the candidate, mutate authoritative repository state, or mutate persistent governed external state; only after authorization may governed automation exercise the capabilities necessary to derive deterministic materialization revisions or external effects. Derived outcomes create no independent semantic authority, must not be treated as fresh human authorization, and must retain revision-addressable causal provenance to the authorizing revision. |
| **GV88 ◇ ↑** | Require every governable obligation to be enforced at its earliest sound information boundary while retaining `govenv check` as the authoritative repository evaluation and deriving every anticipatory enforcement from the same governed rule. Maintain an explicit enforcement inventory that anticipates, at minimum: construction-time Agda constraints for typed identities, roadmap/lifecycle validity, constitutional structure, evidence relationships, pure kernel boundaries, and projection/materialization structure; static candidate or incremental/LSP checks for governance evolution, immutable identity, architecture imports, handwritten-source restrictions, materialization ownership and drift, artifact colocation, documentation references, regression obligations, governance/release deltas, and release-progress classification; commit-boundary checks for staged candidate validity, commit policy, governance references, semantic commit classification, and regression signals; PR/CI checks only for information first available from GitHub or the remote candidate; and post-effect checks only for irreducible external observations such as read-back equality, publication state, admin effects, and runtime facts. Later stages may confirm earlier results but must not re-own, duplicate, or independently specify semantics that were soundly enforceable earlier. |

#### Introduced · 2

| GV | Proposition |
| :---: | --- |
| **+ GV94 ✓** | Make roadmap current state derived and self-consistent: while governance work remains, the active phase must contain non-terminal governance work, finished phases must remain terminal, and a complete roadmap may contain no non-terminal work. Every `Current` projection, including README status and next-work information, must be derived from typed roadmap state and may contain no independently maintained progress summary. |
| **+ GV95 ◇** | Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality. |

#### Superseded · 1

##### GV77 ↪ GV95

```diff
- Make `CHANGELOG.md` the canonical versioned portable materialization of each typed release entry, while the Release Please pull request and published GitHub Release project the same typed release content through a shared enriched GitHub renderer; external GitHub Release application must be verified by read-back equality.
+ Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality.
```

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `733c812..7d9dc5e`.
<!-- govenv-governance-impact:end -->


### Bug Fixes

* **materialization:** make causal provenance rebase-stable ([991cd79](https://github.com/klarkc/govenv/commit/991cd7949269c674c65e5238374530487723c5aa))
* **pages:** fetch release history for governed check ([e0186e9](https://github.com/klarkc/govenv/commit/e0186e9fbafe97ef08589b04cd3903aa0aaecc4f))
* **release:** validate frozen candidate read-only ([ea593f0](https://github.com/klarkc/govenv/commit/ea593f02d2ba6c34d1c4730fea1eb1fc9cbf558a))
* **test:** evaluate exact pull request head ([d7d1314](https://github.com/klarkc/govenv/commit/d7d131482448e9ead1c1f2d71aefd9eaf328238a))
* **test:** honor explicit reusable revision ([7d9dc5e](https://github.com/klarkc/govenv/commit/7d9dc5ed1d379417ba3efe9070d19a65de941419))


### Governance

* **release:** make changelog canonical ([4b7132c](https://github.com/klarkc/govenv/commit/4b7132cdd3c7e6048ba2f053ebf935a59af61de4))
* **roadmap:** derive current state ([a85ba42](https://github.com/klarkc/govenv/commit/a85ba42f29f472dc1afe6302c181b01a2a8ac440))


### Miscellaneous

* **materialize:** update governed materializations ([787c5d9](https://github.com/klarkc/govenv/commit/787c5d926a9922e87b5ea49f17fe19148de02ca6))
* **materialize:** update governed materializations ([b6771ef](https://github.com/klarkc/govenv/commit/b6771efb57faa1095a42725641604c0f8e397480))
* **materialize:** update governed materializations ([1d8350e](https://github.com/klarkc/govenv/commit/1d8350e0891b6f9685f52063386475b03255d4d5))
* **materialize:** update governed materializations ([9d2d4ad](https://github.com/klarkc/govenv/commit/9d2d4ad4c24edd6abd2bb67e0eae7b1ac2546453))
* **materialize:** update governed materializations ([8a46346](https://github.com/klarkc/govenv/commit/8a4634653db35ef95369fe73d624fd86164f4d08))
* **materialize:** update governed materializations ([cc3215c](https://github.com/klarkc/govenv/commit/cc3215cd8058713772ae04c1f89d35a1b9e2fc30))
* **materialize:** update governed materializations ([d4a2cea](https://github.com/klarkc/govenv/commit/d4a2cea1e062b2168c737d30ec00c9f85400e1a8))
* **materialize:** update governed materializations ([c5fb2c2](https://github.com/klarkc/govenv/commit/c5fb2c27216b0aa9d299c1d88d6487f6067d0e0b))
* **materialize:** update governed materializations ([f86ee58](https://github.com/klarkc/govenv/commit/f86ee5870abf527b4f065f827277be701f131441))
* **materialize:** update governed materializations ([89a2356](https://github.com/klarkc/govenv/commit/89a2356ec79b3667c08510a7a8cc0af25763b15f))
## [0.2.1](https://github.com/klarkc/govenv/compare/v0.2.0...v0.2.1) (2026-09-15)

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** ▣ P1 — unchanged  
**Items:** 4 advanced · 15 introduced · 2 superseded

#### Advanced · 4

| GV | Proposition |
| :---: | --- |
| **GV59 ◇ ↑** | Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions. |
| **GV63 ◇ ↑** | Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries. |
| **GV77 ◇ ↑** | Make `CHANGELOG.md` the canonical versioned portable materialization of each typed release entry, while the Release Please pull request and published GitHub Release project the same typed release content through a shared enriched GitHub renderer; external GitHub Release application must be verified by read-back equality. |
| **GV42 ◇ ↑** | Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps. |

#### Introduced · 15

| GV | Proposition |
| :---: | --- |
| **+ GV84 ◇** | Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed. |
| **+ GV86 ◇** | Treat governance items as cumulative constitutional decisions: from introduction onward, every item is interpreted against the complete constitution at that revision, including `todo`, `done`, `superseded`, and `cancelled` history; lifecycle state determines operative effect rather than constitutional membership, completion records establishment rather than applicability, and explicit dependency relationships between governance items are neither required nor modeled. |
| **+ GV87 ◇** | Project the typed candidate governance delta of every governed pull request through a GitHub-native check derived from revision-aware governance state; workflow artifacts may provide transient inspection material, but finite external retention means they must never be the sole or authoritative governance evidence, and any evidence required for completion, regression closure, auditability, or future validation must persist in governed revision-addressable form from which transient projections can be reproduced. |
| **+ GV90 ◇** | Model human authorization as `AuthorizedRevision`: new semantic authority may originate only from the exact repository state accepted by an explicit human pull-request merge. Candidate revisions may perform unprivileged validation and transient non-authoritative projections, but automated candidate-authoring principals must be distinct from human authorizers and post-authorization materializers and must not receive capabilities that can alter executable automation, authorize or merge the candidate, mutate authoritative repository state, or mutate persistent governed external state; only after authorization may governed automation exercise the capabilities necessary to derive deterministic materialization revisions or external effects. Derived outcomes create no independent semantic authority, must not be treated as fresh human authorization, and must retain revision-addressable causal provenance to the authorizing revision. |
| **+ GV91 ◇** | Require authority-boundary migrations to be monotonic and non-self-locking: an enforcement or capability restriction may become active only after every authorized execution path required to operate, verify, and repair under that restriction is already present in an `AuthorizedRevision` and its prerequisite external capabilities have been applied and read-back verified; bootstrap stages must preserve a human-authorized recovery path, and no stage may depend on a capability whose establishment occurs only after the enforcement that requires it. |
| **+ GV92 ◇** | Require administrative bootstrap and continued administration to have exactly one human-supplied root authority, represented by `GOVENV_ADMIN_TOKEN`. Provisioning, replacing, or rotating the credential representing that root preserves the identity of the same administrative authority and must never constitute a new independent authority. From this root and an `AuthorizedRevision`, `Admin Materialize` must deterministically derive the required subordinate authority graph and must materialize, generate where cryptographic material is required, provision, rotate, order, and read-back verify every subordinate credential, capability boundary, identity, environment, variable, secret, policy, and persistent administrative effect required by Govenv. Generated credential material carries no independent semantic authority and must remain bound to governed identity and capability state. No additional manually supplied credential, token, key, secret, application identity, environment mutation, or per-target administrative intervention may become a prerequisite for normal operation. Any required authority that cannot be derived or materialized from this root must be treated as an architectural incompleteness unless a hosting-platform impossibility is explicitly governed. |
| **+ GV93 ◇** | When an authorized materializer relies on a GitHub ruleset bypass granted to the `DeployKey` actor class, govern the repository deploy-key set as a closed set containing only the materializer credential. No unmanaged or independently provisioned deploy key may coexist with that bypass. `Admin Materialize` must provision or rotate the materializer deploy key, remove stale or unauthorized deploy keys, and read-back verify the complete deploy-key set before the `DeployKey` bypass may become active. |
| **+ GV83 ◇** | Render governance deltas sparsely: project only semantic dimensions whose values change, keep unchanged dimensions implicit, and retain only the identity and context required to unambiguously interpret the change. |
| **+ GV78 ◇** | Define revision-aware documentation references for governed identities, lifecycle states, operators, transitions, and Agda modules and symbols, so every reference can be resolved against the repository revision or delta it semantically represents. |
| **+ GV79 ◇** | Require every versioned Markdown artifact, including literate Agda, whether handwritten or materialized, to use valid navigable documentation references for governed concepts and Agda entities whenever such references are semantically exposed. |
| **+ GV80 ◇** | Make Agda documentation addressable by immutable repository revision so revision-aware documentation references never depend on mutable current documentation. |
| **+ GV81 ◇** | Require the Release Please pull request body to project governed and Agda documentation references using the revision-aware documentation reference model for the release delta it represents. |
| **+ GV82 ◇** | Require the published GitHub Release body to project the same revision-aware governed and Agda documentation references as its release document. |
| **+ GV89 ◇** | Treat the case-insensitive standalone word `fix` in governed commit messages as a conservative regression signal: candidate commit validation must reject it unless the commit references governed regression evidence or carries an explicit justified non-regression exemption; no exemption may discharge an unresolved observed regression. |
| **+ GV88 ◇** | Require every governable obligation to be enforced at its earliest sound information boundary while retaining `govenv check` as the authoritative repository evaluation and deriving every anticipatory enforcement from the same governed rule. Maintain an explicit enforcement inventory that anticipates, at minimum: construction-time Agda constraints for typed identities, roadmap/lifecycle validity, constitutional structure, evidence relationships, pure kernel boundaries, and projection/materialization structure; static candidate or incremental/LSP checks for governance evolution, immutable identity, architecture imports, handwritten-source restrictions, materialization ownership and drift, artifact colocation, documentation references, regression obligations, governance/release deltas, and release-progress classification; commit-boundary checks for staged candidate validity, commit policy, governance references, semantic commit classification, and regression signals; PR/CI checks only for information first available from GitHub or the remote candidate; and post-effect checks only for irreducible external observations such as read-back equality, publication state, admin effects, and runtime facts. Later stages may confirm earlier results but must not re-own, duplicate, or independently specify semantics that were soundly enforceable earlier. |

#### Superseded · 2

##### GV85 ↪ GV89

**Phase:** P1 → P3

##### GV76 ↪ GV78

```diff
- Make governance references in Git-derived projections revision-aware and navigable: linked identities, lifecycle states and operators, transitions, and elisions must resolve to documentation derived from the immutable Git revision or delta they represent; before-state references use the base revision and after-state references use the candidate or head revision.
+ Define revision-aware documentation references for governed identities, lifecycle states, operators, transitions, and Agda modules and symbols, so every reference can be resolved against the repository revision or delta it semantically represents.
```

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `0e03a8c..30fc755`.
<!-- govenv-governance-impact:end -->



### Bug Fixes

* **authorization:** support private materializer app ([346aee0](https://github.com/klarkc/govenv/commit/346aee0928d29bb385c7fc37c21eacc2e34b9259))
* **release:** parse quoted roadmap snapshot strings ([ac963c3](https://github.com/klarkc/govenv/commit/ac963c3fad1f15f66dd73409564fbd2cb0480cb6))
* **release:** simplify phase delta classification ([9c8e438](https://github.com/klarkc/govenv/commit/9c8e4387891f97cc090913999cbaa4b3c4fa9776))


### Governance

* **administration:** materialize single setup ([47707f8](https://github.com/klarkc/govenv/commit/47707f86031b8a3a4c865ff5a7dc272f29704a22))
* **administration:** model single-root authority ([9742d9a](https://github.com/klarkc/govenv/commit/9742d9ae21d697c6c7ff819a47698ccc4e1a645a))
* **administration:** normalize deploy key readback ([328cc1c](https://github.com/klarkc/govenv/commit/328cc1cb4a6fd34c331d67ca275347cb1f0a502c))
* **assurance:** define regression closure policy ([ca6c2ed](https://github.com/klarkc/govenv/commit/ca6c2ed539968c34791f95d44e249faba0d04ccf))
* **authorization:** bind post-merge effects to exact revision ([b3ffd02](https://github.com/klarkc/govenv/commit/b3ffd02a67c7cb0e091e5f28ab80362859d19ede))
* **authorization:** stage monotonic authority bootstrap ([6e35290](https://github.com/klarkc/govenv/commit/6e35290ae3219d4f36d414a7a368416e2fbeda32))
* **release:** bind governance impact to release version ([95c4ceb](https://github.com/klarkc/govenv/commit/95c4cebaa6dbadd470b02df0b84df8184d2916fd))
* **release:** close release push authorization regression ([30fc755](https://github.com/klarkc/govenv/commit/30fc755bb47fc30ebe5b53f601177f635ff48594))
* **release:** model sparse supersession dimensions ([6928076](https://github.com/klarkc/govenv/commit/69280766b4504f5623f6234896759a0ede542348))
* **release:** render only changed supersession dimensions ([bcf858f](https://github.com/klarkc/govenv/commit/bcf858f1f7a0ca1593d5723de0d6f6501189bea0))
* **roadmap:** govern documentation references ([748d65d](https://github.com/klarkc/govenv/commit/748d65d4bf2f5ec158ffd5b1a45734c23b629684))
* **roadmap:** govern sparse delta projection ([b01ad45](https://github.com/klarkc/govenv/commit/b01ad4540cad9485469d832d8d56698ddb4443d3))


### Documentation

* **release:** describe sparse governance deltas ([206dfb9](https://github.com/klarkc/govenv/commit/206dfb9af04c4def91371e6fb670a3e8a2880530))


### Code Refactoring

* **materialization:** project deploy key set ([6cebdee](https://github.com/klarkc/govenv/commit/6cebdeeacad4bec4ca10d1e24a0d9d156661aded))
* **release:** close projection over typed delta ([e0b59aa](https://github.com/klarkc/govenv/commit/e0b59aafd2e56f753ce52e0fc790377fa70936e4))


### Miscellaneous

* **materialize:** update governed materializations ([cfa0ad3](https://github.com/klarkc/govenv/commit/cfa0ad36aa38e40a97fdafbbee639f0a6df2d830))
* **materialize:** update governed materializations ([9fd6483](https://github.com/klarkc/govenv/commit/9fd648365791c892e4a0b1ed04890728cd21d813))

## [0.2.0](https://github.com/klarkc/govenv/compare/v0.1.0...v0.2.0) (2026-09-11)

<!-- govenv-governance-impact:start -->
### Governance impact

**Phase:** + ▣ P1 — phase governance introduced  
**Items:** 62 introduced · 16 superseded

#### Introduced · 62

| GV | Proposition |
| :---: | --- |
| **+ GV0 ✓** | Literate `Govenv.lagda.md` closure root. |
| **+ GV1 ✓** | Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`. |
| **+ GV2 ✓** | Reproducible Stage 0 bootstrap, documentation site, and automated releases. |
| **+ GV3 ✓** | `Verdict`: `holds`, `violated`, and `unknown`. |
| **+ GV4 ✓** | Minimal `Rule` abstraction. |
| **+ GV5 ✓** | Typed repository facts. |
| **+ GV6 ✓** | Dependency-indexed rules. |
| **+ GV68 ✓** | Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`◇` item notation instead of raw `Nat` plus `done`/`todo`. |
| **+ GV69 ✓** | Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▣`/`□`, and render phase/item state using the same operator glyphs. |
| **+ GV50 ✓** | Use generic typed identifiers with structural `BelongsTo`, and express the entire roadmap as one declarative tree with implementation mechanics hidden. |
| **+ GV52 ✓** | Enforce roadmap identity and completion integrity: phase and governance indices must be unique, phase indices must progress monotonically, and a finished phase may contain no pending governance items. |
| **+ GV57 ◇** | Inventory repository behavior and policy, distinguishing governed semantics from irreducibly observational or effectful mechanisms. |
| **+ GV58 ◇** | Require every inventory entry whose semantics can be expressed and checked by Govenv to be backed by governed data and a rule. |
| **+ GV59 ◇** | Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions. |
| **+ GV62 ◇** | Enforce architecture roles and dependency directions for the closure root, constitution, materialization, kernel, projection, adapters, and generated artifacts. |
| **+ GV20 ✓** | Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity. |
| **+ GV60 ✓** | Govern `README.md` as the canonical output of `Govenv.Materialization.Readme`; manual divergence must fail the project check. |
| **+ GV15 ✓** | Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible. |
| **+ GV16 ✓** | Materialize governed README sections from Agda rather than maintaining duplicate prose by hand. |
| **+ GV51 ✓** | Materialization closure: every state materialized by Govenv must have exactly one canonical `Govenv.Materialization.*` definition containing all semantic content, structure, ordering, inclusion, policy, and required capability decisions; projections encode only target-format representation, and adapters only observe, apply, or verify effects. |
| **+ GV18 ◇** | Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations. |
| **+ GV19 ✓** | Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing. |
| **+ GV21 ✓** | Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations. |
| **+ GV22 ✓** | Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow. |
| **+ GV45 ✓** | Require every admin materialization to read the target back after applying it, fail unless the observed value equals the governed expected value, and emit execution evidence tied to the constitution SHA, target, repository, and workflow run. |
| **+ GV46 ◇** | Model admin materialization evidence as typed governed data that can be consumed by a formal rule or assurance check rather than relying on workflow success alone. |
| **+ GV63 ◇** | Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries. |
| **+ GV24 ◇** | CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution. |
| **+ GV12 ◇** | CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change. |
| **+ GV13 ◇** | CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change. |
| **+ GV44 ✓** | Automatically apply versioned non-admin materializations on `main` using only repository-scoped CI permission; validation and publication workflows run after Materialize completes, while admin materializations remain manual. |
| **+ GV70 ✓** | Project release governance deltas from immutable typed roadmap snapshots and commit references, distinguishing introduced, advanced, completed, cancelled, and superseded items plus phase progression while rejecting identity mutation or removal and keeping SemVer independent. |
| **+ GV54 ✓** | Preserve immutable governance identity across roadmap evolution: once introduced, a `GovernanceId`, its definition, and its owning phase may never be removed, reused, or modified; obsolete or corrected governance must remain represented as cancelled or superseded, with supersession explicitly identifying a newer replacement `GovernanceId`. |
| **+ GV71 ◇** | Restrict handwritten versioned repository content to Agda and Markdown only. Any generated or governed materialization may use its required target format. Until GV38 is completed, the only handwritten bootstrap escape hatch is root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock`; all other implementation languages and handwritten configuration formats, including Nix elsewhere, are forbidden. |
| **+ GV72 ◇** | Require every versioned repository artifact not permitted as handwritten source by GV71, except the temporary root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock` bootstrap escape hatch, to be produced by exactly one governed `Govenv.Materialization.*` definition and verified against its materialized state; transient `.govenv` state is forbidden from being versioned. |
| **+ GV73 ◇** | Require every persisted supporting artifact, including snapshots, fixtures, baselines, schemas, test vectors, and evidence, to be colocated with the module that semantically owns it; catch-all artifact directories are forbidden unless the artifact is genuinely project-global. |
| **+ GV74 ◇** | Make governance completion evidence-bearing and persistent: a governance item may transition to `done` only when governed evidence establishes its proposition for the candidate repository state, and every non-superseded `done` item, including items completed before this rule, must remain satisfied in every subsequent valid repository state. |
| **+ GV75 ◇** | Render release governance item changes as compact semantic diffs: remove redundant per-item progress labels, align before/after propositions for supersessions, visually distinguish only changed spans, and deterministically wrap or elide common context while preserving the full typed governance delta. |
| **+ GV76 ◇** | Make governance references in Git-derived projections revision-aware and navigable: linked identities, lifecycle states and operators, transitions, and elisions must resolve to documentation derived from the immutable Git revision or delta they represent; before-state references use the base revision and after-state references use the candidate or head revision. |
| **+ GV77 ◇** | Make `CHANGELOG.md` the canonical versioned portable materialization of each typed release entry, while the Release Please pull request and published GitHub Release project the same typed release content through a shared enriched GitHub renderer; external GitHub Release application must be verified by read-back equality. |
| **+ GV55 ◇** | Model the governed release-progress policy: major and minor releases require governance progress by completing at least one pending item or advancing to a later phase; patch releases are exempt. |
| **+ GV56 ◇** | Encode and enforce GV55 as Govenv's first self-governing `Rule` over typed release governance state. |
| **+ GV64 ◇** | Purely evaluate facts and rules into verdicts, obligations, and typed diagnostics without IO. |
| **+ GV65 ◇** | Purely associate governance diagnostics with governed repository provenance so consumers can produce source-mapped diagnostics without IO. |
| **+ GV26 ◇** | Observe repository facts through a thin impure adapter. |
| **+ GV53 ◇** | Expose repository evaluation as `govenv check`, with deterministic exit status and source-mapped diagnostics while keeping observation and effects outside the pure evaluator. |
| **+ GV66 ◇** | Model governed commit policy as project data with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer. |
| **+ GV29 ◇** | Validate the staged candidate repository state using the candidate governance before accepting a commit. |
| **+ GV30 ◇** | Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly. |
| **+ GV31 ◇** | Recheck only rules affected by changed facts and emit diagnostic deltas. |
| **+ GV32 ◇** | Prove incremental checking equivalent to full checking. |
| **+ GV33 ◇** | Expose the checker through an LSP/editor loop. |
| **+ GV34 ◇** | Expose governance context and diagnostic deltas through an MCP adapter for agent clients. |
| **+ GV35 ◇** | Define typed Environment/Runtime IR. |
| **+ GV67 ◇** | Keep runtime backends replaceable behind the typed IR boundary. |
| **+ GV36 ◇** | Compile valid projects through a devenv backend. |
| **+ GV37 ◇** | Expose `govenv shell`, `govenv test`, and `govenv up`. |
| **+ GV38 ◇** | Ship a standalone `govenv` entrypoint and managed runtime setup. |
| **+ GV39 ◇** | Make Govenv govern and build itself. |
| **+ GV41 ◇** | Support white-label distributions while keeping the formal kernel reusable and product-neutral. |
| **+ GV42 ◇** | Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps. |
| **+ GV43 ◇** | Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code. |

#### Superseded · 16

##### GV47 ↪ GV68

```diff
- Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`○` item notation instead of raw `Nat` plus `done`/`todo`.
+ Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`◇` item notation instead of raw `Nat` plus `done`/`todo`.
```

##### GV49 ↪ GV69

```diff
- Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▶`/`□`, and render phase/item state using the same operator glyphs.
+ Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▣`/`□`, and render phase/item state using the same operator glyphs.
```

##### GV9 ↪ GV57

```diff
- Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration.
+ Inventory repository behavior and policy, distinguishing governed semantics from irreducibly observational or effectful mechanisms.
```

##### GV10 ↪ GV58

```diff
- Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention.
+ Require every inventory entry whose semantics can be expressed and checked by Govenv to be backed by governed data and a rule.
```

##### GV11 ↪ GV59

```diff
- Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified.
+ Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions.
```

##### GV17 ↪ GV61

```diff
- Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts.
+ Enforce architecture roles and dependency directions for constitution, materialization, kernel, projection, adapters, and generated artifacts.
```

##### GV61 ↪ GV62

```diff
- Enforce architecture roles and dependency directions for constitution, materialization, kernel, projection, adapters, and generated artifacts.
+ Enforce architecture roles and dependency directions for the closure root, constitution, materialization, kernel, projection, adapters, and generated artifacts.
```

##### GV14 ↪ GV60

```diff
- Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check.
+ Govern `README.md` as the canonical output of `Govenv.Materialization.Readme`; manual divergence must fail the project check.
```

##### GV23 ↪ GV63

```diff
- Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries.
+ Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries.
```

##### GV48 ↪ GV70

```diff
- Project every release governance delta from typed roadmap state and commit references, distinguishing completed, advanced, and introduced items plus phase progression while keeping SemVer independent.
+ Project release governance deltas from immutable typed roadmap snapshots and commit references, distinguishing introduced, advanced, completed, cancelled, and superseded items plus phase progression while rejecting identity mutation or removal and keeping SemVer independent.
```

##### GV7 ↪ GV55

```diff
- Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt.
+ Model the governed release-progress policy: major and minor releases require governance progress by completing at least one pending item or advancing to a later phase; patch releases are exempt.
```

##### GV8 ↪ GV56

```diff
- Encode GV7 as Govenv's first self-governing repository rule.
+ Encode and enforce GV55 as Govenv's first self-governing `Rule` over typed release governance state.
```

##### GV25 ↪ GV64

```diff
- Evaluate facts, rules, verdicts, obligations, and diagnostics without IO.
+ Purely evaluate facts and rules into verdicts, obligations, and typed diagnostics without IO.
```

##### GV27 ↪ GV65

```diff
- Produce source-mapped governance diagnostics from the pure kernel.
+ Purely associate governance diagnostics with governed repository provenance so consumers can produce source-mapped diagnostics without IO.
```

##### GV28 ↪ GV66

```diff
- Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer.
+ Model governed commit policy as project data with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer.
```

##### GV40 ↪ GV67

*Proposition unchanged.* Keep runtime backends replaceable behind the typed IR boundary.

Derived from immutable typed roadmap snapshots and governed `Refs: GV…` commit metadata. SemVer remains independent. `45895e6..d18a4a3`.
<!-- govenv-governance-impact:end -->



### Features

* **kernel:** model typed repository facts ([adcb92a](https://github.com/klarkc/govenv/commit/adcb92a4de70d4801e0410ed8705a3bedefffe46))


### Governance

* **admin:** record verified materialization ([1029e8e](https://github.com/klarkc/govenv/commit/1029e8e58ac8343e2872fa39d4e91b3007aaf996))
* **admin:** verify materialization read-back ([c7b6f1c](https://github.com/klarkc/govenv/commit/c7b6f1c33b367136eac2c9aa90542f95212c789b))
* **assurance:** gate completed governance ([faa1e59](https://github.com/klarkc/govenv/commit/faa1e59911cb3ea9b120fdab31048d1d59a651ea))
* **assurance:** require candidate witnesses ([b50e8ef](https://github.com/klarkc/govenv/commit/b50e8ef338af8cdf90bd197b7b3a0a85130459db))
* **assurance:** separate completion evidence ([419c35c](https://github.com/klarkc/govenv/commit/419c35c5954a21c32260350ff359cc4de60c5eeb))
* **ci:** govern administrative bootstrap and CI projection ([c8739c8](https://github.com/klarkc/govenv/commit/c8739c80eca73b261acfda2effb7cb79754c82cb))
* **commits:** require roadmap references ([208cdd5](https://github.com/klarkc/govenv/commit/208cdd524c289899c594fdd24aed6b86a8fa71f6))
* **kernel:** index rules by declared facts ([3cda88c](https://github.com/klarkc/govenv/commit/3cda88cb9317c5284fb66483117f05dd11a1895b))
* **materialization:** make target semantics canonical ([fc0e244](https://github.com/klarkc/govenv/commit/fc0e244830b858826ebe356701a87ae4447a5027))
* **materialize:** automate versioned projections ([bbdf037](https://github.com/klarkc/govenv/commit/bbdf03763c205b95e974d4d71187f06b29bf04cf))
* **project:** govern identity and materializations ([dc2d11c](https://github.com/klarkc/govenv/commit/dc2d11ce5c0d11d95e1ed272654de738fafb4314))
* **readme:** materialize governed project readme ([0975a90](https://github.com/klarkc/govenv/commit/0975a90752be28f130fb633f529d14d51da103a5))
* **release:** clarify governance impact ([ed1c61c](https://github.com/klarkc/govenv/commit/ed1c61cefc42b52906e163cc131e333e46b89f9d))
* **release:** classify terminal introductions ([37255ae](https://github.com/klarkc/govenv/commit/37255aeea7c0d566b449a334dbc916cbc9d017b1))
* **release:** close typed release governance ([b421130](https://github.com/klarkc/govenv/commit/b4211300c85cd1e9c5e46501011e75e526e0fd0f))
* **release:** decouple canonical changelog target ([d18a4a3](https://github.com/klarkc/govenv/commit/d18a4a3304114b7441282cdf59dd4ab82e897e7e))
* **release:** define governance delta ([bb10417](https://github.com/klarkc/govenv/commit/bb10417d2cc8209596cf9f14fb70292136e61ed1))
* **release:** isolate release bot identity ([fa9da09](https://github.com/klarkc/govenv/commit/fa9da09ae7133120fcb72d8981069fab563c70e2))
* **release:** project typed governance delta ([8982372](https://github.com/klarkc/govenv/commit/8982372193832f1b63270738a49a7d3e3c0350fb))
* **release:** render semantic governance diffs ([288108c](https://github.com/klarkc/govenv/commit/288108cdd9768b81a8e7bbc2edaec9d3ec52ee38))
* **release:** separate canonical and GitHub projections ([1664c89](https://github.com/klarkc/govenv/commit/1664c8961f25fea73148d00481854f91dcdd9483))
* **roadmap:** add MCP adapter milestone ([9b7edaa](https://github.com/klarkc/govenv/commit/9b7edaa93266547c2e600e9982882f3965b7e4ca))
* **roadmap:** add stable roadmap references ([f4ce4f5](https://github.com/klarkc/govenv/commit/f4ce4f51b3e70407a21baaafac06dbd7c5e2f851))
* **roadmap:** adopt P and GV identifiers ([19f6e56](https://github.com/klarkc/govenv/commit/19f6e56d6640cbb3d3c79e8ae01452adc939687e))
* **roadmap:** align governance phase boundaries ([6e9449f](https://github.com/klarkc/govenv/commit/6e9449f2571a21bbe440449e9932996e436df8f4))
* **roadmap:** distinguish active phase glyph ([0a50c3b](https://github.com/klarkc/govenv/commit/0a50c3b59683973000365a59e895885f9aa10f71))
* **roadmap:** distinguish pending item glyph ([8456e5b](https://github.com/klarkc/govenv/commit/8456e5bd2cc220909195194092034fd40aaa6b87))
* **roadmap:** enforce roadmap integrity ([942cf39](https://github.com/klarkc/govenv/commit/942cf392a7fa80dd15e952589343405fcaf624d0))
* **roadmap:** govern ci cache ([3f88678](https://github.com/klarkc/govenv/commit/3f886781c58bc76660b8b8c9c39d5902e9502cd7))
* **roadmap:** index governance by phase ([9217340](https://github.com/klarkc/govenv/commit/9217340b6ecf6ca7b8e1241a5903057cf2bf3d69))
* **roadmap:** make roadmap structure intrinsic ([a25ee67](https://github.com/klarkc/govenv/commit/a25ee67e2f1126c09d78cf08f833eb205b06a430))
* **roadmap:** minimize ungoverned surface ([79b8c1b](https://github.com/klarkc/govenv/commit/79b8c1b7e94554f65ad09f6f34fa5a922c0eed43))
* **roadmap:** preserve immutable governance history ([03b2d54](https://github.com/klarkc/govenv/commit/03b2d54f830641c32e755fb496bb3a180cdccc31))
* **roadmap:** reflect typed facts progress ([f059233](https://github.com/klarkc/govenv/commit/f059233dd59bab474ed2f2c951de6a5b92ec7702))
* **roadmap:** require progress on major and minor releases ([27dbaca](https://github.com/klarkc/govenv/commit/27dbaca00a465223ad1197fd8c295835023790e7))
* **roadmap:** restore commit governance plan ([88b76ad](https://github.com/klarkc/govenv/commit/88b76ada910b3dbce53d2380fd2fc56e80439e29))
* **roadmap:** type governance identifiers ([22fd80a](https://github.com/klarkc/govenv/commit/22fd80ad014af3e787430a7e8304bed2f2030621))
* **roadmap:** type phase identifiers ([ef05299](https://github.com/klarkc/govenv/commit/ef052994599f674c1737045aea9dd7e2cf3fa54e))
* **roadmap:** unify phase and item state notation ([7ade94c](https://github.com/klarkc/govenv/commit/7ade94c5cd93c6b138bf1722504ddecfb41f9244))


### Continuous Integration

* avoid flakehub cache misses ([3e87730](https://github.com/klarkc/govenv/commit/3e877303b09d44c5746437e0be420d9725b21460))
* keep determinate nix in actions ([d91843c](https://github.com/klarkc/govenv/commit/d91843c1db6746bd376c54381976f072aa2dd042))
* restore local nix cache ([85c632d](https://github.com/klarkc/govenv/commit/85c632d3c69184729265a1ac802ec10fc8eee5d2))
* test govenv and fix nix cache setup ([07951f1](https://github.com/klarkc/govenv/commit/07951f11459058efe7180c2c952f73ef8163910c))
* use upstream nix in actions ([a9b522c](https://github.com/klarkc/govenv/commit/a9b522c11a4677d150019125ad27bca2f5c7631c))


### Miscellaneous

* **materialize:** update governed materializations ([78923b0](https://github.com/klarkc/govenv/commit/78923b04320cd8a746354190708dafe8d3818a8f))
* **materialize:** update governed materializations ([87937cb](https://github.com/klarkc/govenv/commit/87937cb8a4eb98fdfa557069f788c5bd757db4b5))
* **materialize:** update governed materializations ([8531839](https://github.com/klarkc/govenv/commit/85318394926aa130c85fb5fea12057c7c4a576a0))
* **materialize:** update governed readme ([fdc8b9c](https://github.com/klarkc/govenv/commit/fdc8b9ca5f7055c8a00e8a56038037a40c354849))
* **materialize:** update governed readme ([d91d969](https://github.com/klarkc/govenv/commit/d91d969b6ca2c69543e232dd13554693f436f20e))
* **materialize:** update governed readme ([389bc14](https://github.com/klarkc/govenv/commit/389bc14d01a17cb065b828c1eaf2d7c111228c31))
* **materialize:** update governed readme ([085cb76](https://github.com/klarkc/govenv/commit/085cb7644857a27a068b0db629da2a6bc1284068))

## 0.1.0 (2026-09-08)


### Features

* **bootstrap:** initialize govenv ([8c4604a](https://github.com/klarkc/govenv/commit/8c4604a804ec12608fb5d5bdb211259d93106f01))
* **kernel:** model governance rules ([8465e9d](https://github.com/klarkc/govenv/commit/8465e9d4ff9a263b02e680a65c1fd73f5b682396))
* **kernel:** model governance verdicts ([341069c](https://github.com/klarkc/govenv/commit/341069c9fbfbe658d0d1bed0c45281de000f653b))


### Governance

* **release:** include governance commits in changelog ([a028711](https://github.com/klarkc/govenv/commit/a028711770ee77d2015ef1765e2e3f8f9a463476))


### Documentation

* publish literate governance with pages ([31b70d9](https://github.com/klarkc/govenv/commit/31b70d937eb9b59d8b68d611d636ed83dde391bc))
* **readme:** streamline project header ([c64f35e](https://github.com/klarkc/govenv/commit/c64f35e6fe687ed1aeacb91c6d12a6d08902f71a))


### Continuous Integration

* cache nix builds for pages ([a2c8a9c](https://github.com/klarkc/govenv/commit/a2c8a9ce8ec1a6489784b2612a265e7642f2cfaf))
* **release:** automate conventional releases ([91455fb](https://github.com/klarkc/govenv/commit/91455fb780c1ba41b67faa5a57bf06c3dd4c6711))


### Miscellaneous

* **release:** start at 0.1.0 ([e2aeacf](https://github.com/klarkc/govenv/commit/e2aeacfe5a3964f1ecf5c9a44fe38c18f1e207e3))
* **repo:** keep tooling metadata out of root ([fdfa742](https://github.com/klarkc/govenv/commit/fdfa742276b7e94fd74429b0b4d9b432d458731f))
