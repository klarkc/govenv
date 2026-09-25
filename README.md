<!-- Generated from Govenv.Materialization.Readme. Do not edit manually. -->

<h1 align="center">Govenv</h1>

<p align="center">
  <strong>Turn every repository into a self-governing developer environment: define what valid means once, let agents move fast without outrunning human authority, and reproduce the same tooling, automation, and runtime anywhere.</strong>
</p>

<p align="center">
  <a href="https://klarkc.github.io/govenv/"><img src="https://img.shields.io/badge/docs-pages-brightgreen" alt="Docs" /></a>
  <img src="https://img.shields.io/badge/agda-2.8.0-blueviolet" alt="Agda 2.8.0" />
  <a href="https://github.com/klarkc/govenv/releases"><img src="https://img.shields.io/github/v/release/klarkc/govenv?display_name=tag&sort=semver" alt="Release" /></a>
  <img src="https://img.shields.io/badge/license-Apache--2.0-blue" alt="Apache-2.0" />
</p>

## Roadmap

**Current:** Govenv is in P1 with compiler-checked direction, consolidation closure, human-learning continuity, and Stage-0 GitHub collaboration available. Constitutional history remains partial; GV116 is the immediate gap, followed by dependency/environment authority in GV117 and the broader collaboration boundary in GV118.

**Next:** Complete GV116 by deriving the remaining roadmap and release lifecycle from append-only constitutional history, then resolve dependency/environment authority in GV117 and close GV118's governed collaboration boundary before broader runtime and journal work.

> Governance IDs are immutable historical references. Definitions and owning phases never change after introduction; abandoned work is cancelled, while corrections or changed intent require a newer GV and explicit supersession.

<details>
<summary>■ <strong>P0 — Bootstrap and project shape</strong></summary>

- ✓ **GV0** Literate `Govenv.lagda.md` closure root.
- ✓ **GV1** Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`.
- ✓ **GV2** Reproducible Stage 0 bootstrap, documentation site, and automated releases.

</details>

<details open>
<summary>▣ <strong>P1 — Formal governance model and repository closure</strong></summary>

- ✓ **GV3** `Verdict`: `holds`, `violated`, and `unknown`.
- ✓ **GV4** Minimal `Rule` abstraction.
- ✓ **GV5** Typed repository facts.
- ✓ **GV6** Dependency-indexed rules.
- ↪ **GV47** Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`○` item notation instead of raw `Nat` plus `done`/`todo`. → **GV68**
- ✓ **GV68** Type roadmap governance identifiers as `GovernanceId` and use readable `✓`/`◇` item notation instead of raw `Nat` plus `done`/`todo`.
- ↪ **GV49** Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▶`/`□`, and render phase/item state using the same operator glyphs. → **GV69**
- ✓ **GV69** Make roadmap phase progression structurally valid with exactly one active phase while in progress, declare phases with `■`/`▣`/`□`, and render phase/item state using the same operator glyphs.
- ✓ **GV50** Use generic typed identifiers with structural `BelongsTo`, and express the entire roadmap as one declarative tree with implementation mechanics hidden.
- ✓ **GV52** Enforce roadmap identity and completion integrity: phase and governance indices must be unique, phase indices must progress monotonically, and a finished phase may contain no pending governance items.
- ↪ **GV9** Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration. → **GV57**
- ↪ **GV57** Inventory repository behavior and policy, distinguishing governed semantics from irreducibly observational or effectful mechanisms. → **GV101**
- ↪ **GV10** Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention. → **GV58**
- ↪ **GV58** Require every inventory entry whose semantics can be expressed and checked by Govenv to be backed by governed data and a rule. → **GV101**
- ↪ **GV11** Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified. → **GV59**
- ↪ **GV59** Minimize the ungoverned surface to irreducible observation and effect execution; adapters may perform effects but must not introduce semantic content, policy, structure, ordering, or authorization decisions. → **GV101**
- ✓ **GV101** Partition project requirements and mechanisms into Governance, Protocol, and irreducible observation/effect execution: every expressible and checkable property of repository or system state, transition, effect, authorization, or semantic output that determines constitutional validity must be governed; contributor and agent process guidance remains Protocol even when machine-checkable, and compliance with that guidance must not itself determine repository validity, while Governance may independently require canonical Protocol materializations to match their source; adapters may only observe, apply, or verify effects and must not introduce semantic authority.
- ↪ **GV17** Govern architecture roles and dependency directions for constitution, kernel, projection, adapters, and generated artifacts. → **GV61**
- ↪ **GV61** Enforce architecture roles and dependency directions for constitution, materialization, kernel, projection, adapters, and generated artifacts. → **GV62**
- ↪ **GV62** Enforce architecture roles and dependency directions for the closure root, constitution, materialization, kernel, projection, adapters, and generated artifacts. → **GV98**
- ✓ **GV20** Keep `Govenv` as the canonical immutable project identity; white-label distributions may change branding projections, never the Govenv identity.
- ↪ **GV14** Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check. → **GV60**
- ✓ **GV60** Govern `README.md` as the canonical output of `Govenv.Materialization.Readme`; manual divergence must fail the project check.
- ✓ **GV15** Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible.
- ✓ **GV16** Materialize governed README sections from Agda rather than maintaining duplicate prose by hand.
- ✓ **GV111** Replace the mechanically derived README Current/Next status of GV94 with a governed project-direction review while preserving roadmap structural validity: Current is a bounded human-facing summary anchored by typed coverage of the exact governed project and roadmap state; Next is a bounded human-facing summary of the selected gap between Purpose and Current; every relevant source subject must receive an explicit typed disposition, source changes invalidate review freshness, and the compiler verifies bounds, provenance, coverage, references, and vigilance freshness while the agent supplies semantic judgment and the human authorizes that judgment through the pull request.
- ✓ **GV112** Require consolidation closure for every declared session, handoff, recovery corpus, or other project-knowledge snapshot before semantic roadmap evolution: bind the corpus to immutable provenance and require every declared observation to receive exactly one explicit disposition as represented by governed state, superseded by an identified decision, rejected with rationale, or irrelevant with rationale; any undisposed observation keeps project direction stale and blocks semantic roadmap evolution, without claiming that the compiler can prove completeness of unobservable model memory or natural-language extraction.
- ◇ **GV114** Generalize administrative bootstrap across independent external providers while preserving one human-facing convergent setup: model one human administrative authority with explicit irreducible provider grants only where one provider cannot derive another provider credential; each bootstrap grant may enter only the main-only `admin-materialization` boundary, and `Admin Materialize / setup` must deterministically create, restrict, populate, and read-back verify the least-privileged target capability boundary for that provider. Provider grant fields may be packaged as one opaque secret when they jointly represent one authorization; target jobs receive only their own provider grant and never `GOVENV_ADMIN_TOKEN` or unrelated grants. Provider credentials create no semantic authority, and provider identity must be read back when the provider exposes a sound verification boundary.
- ◇ **GV115** Simplify developer-journal authorization into the existing pull-request lifecycle: every ordinary candidate pull request must include its own journal post text and square image bound to the exact candidate delta and current project direction, with typed coverage/disposition for every relevant change; human merge of that same pull request is the sole editorial authorization, after which only the exact reviewed artifacts may be published automatically to X without a second approval pull request or environment approval. Release Please pull requests substitute a release-journal preview for the ordinary PR post: each major or minor release preview must derive from the exact frozen typed ReleaseDocument, approval/merge of that Release Please pull request authorizes the exact release post, and publication occurs only after the corresponding release boundary; patch releases may omit a release post unless another rule requires one. Publication must be idempotent through the dedicated social capability boundary and retain revision-addressable read-back evidence of the resulting X post.
- ◇ **GV116** Migrate governance lifecycle, roadmap status, snapshots, and release deltas to append-only constitutional history: give formal Propositions identity independent from GovernanceId, treat the GovernanceId description as the human contract rather than formal truth, establish Obligations only through Proposition evidence, represent declaration/establishment/abandonment/disposition/supersession as validated history events, require atomic supersession coverage of outgoing responsibility, derive governance lifecycle and glyphs from that history rather than stored ItemState, preserve history-prefix snapshots, and derive constitutional release deltas from introduced governance, establishments, dispositions, supersessions, and phase progress while keeping activity-only advancement outside constitutional delta.
- ◇ **GV117** Classify dependency and environment authority according to GV101: keep reuse preference, ecosystem investigation, and contributor dependency-selection guidance in Protocol, but move repository-validity properties into Governance when they determine canonical project state, including the target absence of versioned devenv.yaml, governed materialization ownership of devenv.nix, transient non-authoritative devenv.lock state, and the prohibition on competing package-manager dependency authority; materialization and runtime backends must project those governed decisions without re-owning them.
- ✓ **GV119** Keep human learning coupled to conceptual project evolution: represent revision-bound learning requirements, human-produced challenge/response evidence, and outstanding learning debt without claiming to prove a principal's mental state; pull-request learning is a soft gate that may be bypassed only explicitly for urgent corrective work while preserving the resulting debt, feature and concept-expanding refactor work is blocked while debt remains, patch releases may carry known debt, and major or minor releases require zero outstanding learning debt. Expose status, catch-up, and review entrypoints from the governed developer environment.
- ↪ **GV113** Govern the developer journal as an approved projection of project evolution: every semantic Next change requires a direction post bound to the exact project-direction delta, and every major or minor release requires a release post bound to the exact frozen typed ReleaseDocument. Each draft must stay within the target platform limit, carry typed coverage/disposition for every relevant source change, use the canonical Govenv logo and square journal-image brief, be reviewed in the authorizing pull request or release candidate, and only the exact approved text/image may be published after authorization; publication credentials remain external secrets and successful publication is read back into revision-addressable evidence. → **GV115**
- ↪ **GV51** Materialization closure: every state materialized by Govenv must have exactly one canonical `Govenv.Materialization.*` definition containing all semantic content, structure, ordering, inclusion, policy, and required capability decisions; projections encode only target-format representation, and adapters only observe, apply, or verify effects. → **GV102**
- ✓ **GV18** Allow versioned materializations to follow their governing source change in the immediately subsequent `chore(materialize)` commit; the final pushed or reviewed state must contain canonical materializations.
- ✓ **GV19** Require CI validation and publication workflows to materialize governed artifacts from the constitution and reject any resulting tracked drift before continuing.
- ↪ **GV21** Project the canonical Govenv description from `Govenv.Project` into repository-facing materializations. → **GV109**
- ↪ **GV22** Require admin-privileged external materializations to run only through the manual, target-restricted `Admin Materialize` workflow. → **GV108**
- ✓ **GV45** Require every admin materialization to read the target back after applying it, fail unless the observed value equals the governed expected value, and emit execution evidence tied to the constitution SHA, target, repository, and workflow run.
- ◇ **GV46** Model admin materialization evidence as typed governed data that can be consumed by a formal rule or assurance check rather than relying on workflow success alone.
- ↪ **GV23** Inventory every behavior currently encoded in GitHub Actions and extract it into explicit governance: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries. → **GV63**
- ◇ **GV63** Close the GitHub Actions portion of the governance inventory: triggers, permissions, concurrency, runners, timeouts, pinned actions, Nix runtime/cache, materialization, tests, Pages, releases, and admin boundaries.
- ◇ **GV24** CI projection closure rule: GitHub Actions workflows must contain no independent policy; every CI behavior must be traceable to governed project data and ultimately materializable from the constitution.
- ◇ **GV12** CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change.
- ◇ **GV13** CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change.
- ↪ **GV44** Automatically apply versioned non-admin materializations on `main` using only repository-scoped CI permission; validation and publication workflows run after Materialize completes, while admin materializations remain manual. → **GV108**
- ↪ **GV108** Separate administrative bootstrap from authorized materialization around exactly one human-supplied administrative root, `GOVENV_ADMIN_TOKEN`: keep `Admin Materialize` as the single manually invoked setup/recovery/rotation boundary, limited to establishing, reconciling, and rotating subordinate authority and capability state; derive all subordinate credentials and boundaries without any additional manually supplied credential, and rotate governed subordinate credentials on rerun. Ordinary project state must not be an Admin Materialize setup step. Automatically reconcile every deterministic non-bootstrap materialization of an `AuthorizedRevision`, including versioned artifacts and GitHub repository description, website, and topics, with target-specific read-back verification. Automatic GitHub repository administration may consume `GOVENV_ADMIN_TOKEN` only inside the main-only administrative environment when GitHub exposes no narrower credential derivable without a second human bootstrap; candidate, agent, release, Pages, and repository Git-materializer paths must never receive it. → **GV114**
- ↪ **GV48** Project every release governance delta from typed roadmap state and commit references, distinguishing completed, advanced, and introduced items plus phase progression while keeping SemVer independent. → **GV70**
- ✓ **GV70** Project release governance deltas from immutable typed roadmap snapshots and commit references, distinguishing introduced, advanced, completed, cancelled, and superseded items plus phase progression while rejecting identity mutation or removal and keeping SemVer independent.
- ✓ **GV54** Preserve immutable governance identity across roadmap evolution: once introduced, a `GovernanceId`, its definition, and its owning phase may never be removed, reused, or modified; obsolete or corrected governance must remain represented as cancelled or superseded, with supersession explicitly identifying a newer replacement `GovernanceId`.
- ↪ **GV71** Restrict handwritten versioned repository content to Agda and Markdown only. Any generated or governed materialization may use its required target format. Until GV38 is completed, the only handwritten bootstrap escape hatch is root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock`; all other implementation languages and handwritten configuration formats, including Nix elsewhere, are forbidden. → **GV96**
- ↪ **GV72** Require every versioned repository artifact not permitted as handwritten source by GV71, except the temporary root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock` bootstrap escape hatch, to be produced by exactly one governed `Govenv.Materialization.*` definition and verified against its materialized state; transient `.govenv` state is forbidden from being versioned. → **GV96**
- ◇ **GV96** Close versioned artifact authority: handwritten semantic authority is limited to code-first `.agda` modules and human-facing normative `.lagda.md` modules; implementation and experiment documentation must live in the owning `.agda`, while Governance, Protocol, and governed evidence keep prose and formalization together in the owning literate module. Every other versioned artifact must be produced by exactly one governed `Govenv.Materialization.*` definition and verified against it; transient `.govenv` state is forbidden from being versioned, with only the temporary root-level `devenv.nix`, `devenv.yaml`, and `devenv.lock` bootstrap escape hatch until GV38 completes.
- ◇ **GV97** Model `Govenv.Governance` and `Govenv.Protocol` as distinct human-facing literate normative domains: Governance defines constitutional validity, while Protocol guides contributor and agent process without independently invalidating repository state. Materialize `AGENTS.md` exclusively from `Govenv.Protocol` and reject tracked divergence.
- ◇ **GV98** Classify Agda semantic declarations by reflected `Name` into architectural roles for governance, protocol, assurance, materialization, kernel, experiment, projection, and adapters, and enforce allowed dependency directions between those roles. Source layout, the root closure, and generated artifacts are separate transport/composition concerns and must not determine semantic role. Experiments may depend on the reusable kernel, but kernel code must never depend on experiments.
- ◇ **GV99** Require every persisted counterexample to be governed literate evidence under `Govenv/Assurance/GV<n>/Counterexample/` for the assurance boundary it refutes. Any external fixture needed to exercise that counterexample must be a governed materialization of the canonical evidence rather than an independent handwritten authority.
- ↪ **GV100** Govern Govenv's canonical project purpose and public repository identity metadata: `Govenv.Project.purpose` states the long-term project direction and is projected in full into the README; `description` is a faithful summary limited to 250 characters; `purpose` is limited to 500 characters; and `website` plus `topics` are canonical project data materialized to GitHub with read-back verification. → **GV109**
- ✓ **GV109** Make `Govenv.Project.purpose` the single canonical public project statement: remove independent `description` state, limit `purpose` to 250 characters, project it verbatim as the README hero and GitHub repository description, and keep `website` plus `topics` as canonical project metadata materialized to GitHub with read-back verification.
- ✓ **GV110** Support governed vigilance witnesses for Protocol reviews whose judgment is intentionally non-constitutional but whose need for refresh has an objective semantic trigger: validation may require only a fresh explicit witness, never claim that the Protocol judgment itself is correct. Counter-style witnesses must remain unchanged without a trigger, advance exactly once on triggered reaffirmation, reset to zero when the reviewed subject changes, and never advance automatically. Apply this first to project-purpose stewardship: every semantic roadmap change must either reaffirm the unchanged purpose by advancing `purposeReviewIndex` or revise the purpose and reset the index, with freshness checked by Agda against governed predecessor snapshots.
- ◇ **GV102** Separate domain semantic authority from materialization binding: every state materialized by Govenv must have exactly one canonical `Govenv.Materialization.*` definition that binds authoritative semantic sources and any target-specific composition, ordering, or inclusion to its target, application mode, privilege, required authority, and verification; Governance, Protocol, and other governed project data retain ownership of their domain semantics and must not be duplicated or re-owned by materializations, projections, or adapters; projections encode target-format representation and adapters only observe, apply, or verify effects.
- ◇ **GV73** Require every persisted supporting artifact, including snapshots, fixtures, baselines, schemas, test vectors, and evidence, to be colocated with the module that semantically owns it; catch-all artifact directories are forbidden unless the artifact is genuinely project-global.
- ◇ **GV74** Make governance completion evidence-bearing and persistent: a governance item may transition to `done` only when governed evidence establishes its proposition for the candidate repository state, and every non-superseded `done` item, including items completed before this rule, must remain satisfied in every subsequent valid repository state.
- ◇ **GV84** Make observed invariant regressions counterexample-closing: once a contradiction to a governed or relied-upon invariant is recorded as an observed regression, its repair is incomplete until the counterexample is preserved as governed evidence, the missing or incorrectly scoped assurance boundary is corrected or overstated governance superseded, and candidate validation rejects recurrence before the affected workflow may succeed.
- ↪ **GV85** Treat the case-insensitive standalone word `fix` in governed commit messages as a conservative regression signal: candidate commit validation must reject it unless the commit references governed regression evidence or carries an explicit justified non-regression exemption; no exemption may discharge an unresolved observed regression. → **GV89**
- ◇ **GV86** Treat governance items as cumulative constitutional decisions: from introduction onward, every item is interpreted against the complete constitution at that revision, including `todo`, `done`, `superseded`, and `cancelled` history; lifecycle state determines operative effect rather than constitutional membership, completion records establishment rather than applicability, and explicit dependency relationships between governance items are neither required nor modeled.
- ◇ **GV87** Project the typed candidate governance delta of every governed pull request through a GitHub-native check derived from revision-aware governance state; workflow artifacts may provide transient inspection material, but finite external retention means they must never be the sole or authoritative governance evidence, and any evidence required for completion, regression closure, auditability, or future validation must persist in governed revision-addressable form from which transient projections can be reproduced.
- ◇ **GV90** Model human authorization as `AuthorizedRevision`: new semantic authority may originate only from the exact repository state accepted by an explicit human pull-request merge. Candidate revisions may perform unprivileged validation and transient non-authoritative projections, but automated candidate-authoring principals must be distinct from human authorizers and post-authorization materializers and must not receive capabilities that can alter executable automation, authorize or merge the candidate, mutate authoritative repository state, or mutate persistent governed external state; only after authorization may governed automation exercise the capabilities necessary to derive deterministic materialization revisions or external effects. Derived outcomes create no independent semantic authority, must not be treated as fresh human authorization, and must retain revision-addressable causal provenance to the authorizing revision.
- ◇ **GV91** Require authority-boundary migrations to be monotonic and non-self-locking: an enforcement or capability restriction may become active only after every authorized execution path required to operate, verify, and repair under that restriction is already present in an `AuthorizedRevision` and its prerequisite external capabilities have been applied and read-back verified; bootstrap stages must preserve a human-authorized recovery path, and no stage may depend on a capability whose establishment occurs only after the enforcement that requires it.
- ↪ **GV92** Require administrative bootstrap and continued administration to have exactly one human-supplied root authority, represented by `GOVENV_ADMIN_TOKEN`. Provisioning, replacing, or rotating the credential representing that root preserves the identity of the same administrative authority and must never constitute a new independent authority. From this root and an `AuthorizedRevision`, `Admin Materialize` must deterministically derive the required subordinate authority graph and must materialize, generate where cryptographic material is required, provision, rotate, order, and read-back verify every subordinate credential, capability boundary, identity, environment, variable, secret, policy, and persistent administrative effect required by Govenv. Generated credential material carries no independent semantic authority and must remain bound to governed identity and capability state. No additional manually supplied credential, token, key, secret, application identity, environment mutation, or per-target administrative intervention may become a prerequisite for normal operation. Any required authority that cannot be derived or materialized from this root must be treated as an architectural incompleteness unless a hosting-platform impossibility is explicitly governed. → **GV108**
- ◇ **GV93** When an authorized materializer relies on a GitHub ruleset bypass granted to the `DeployKey` actor class, govern the repository deploy-key set as a closed set containing only the materializer credential. No unmanaged or independently provisioned deploy key may coexist with that bypass. `Admin Materialize` must provision or rotate the materializer deploy key, remove stale or unauthorized deploy keys, and read-back verify the complete deploy-key set before the `DeployKey` bypass may become active.
- ↪ **GV94** Make roadmap current state derived and self-consistent: while governance work remains, the active phase must contain non-terminal governance work, finished phases must remain terminal, and a complete roadmap may contain no non-terminal work. Every `Current` projection, including README status and next-work information, must be derived from typed roadmap state and may contain no independently maintained progress summary. → **GV111**
- ◇ **GV75** Render release governance item changes as compact semantic diffs: remove redundant per-item progress labels, align before/after propositions for supersessions, visually distinguish only changed spans, and deterministically wrap or elide common context while preserving the full typed governance delta.
- ◇ **GV83** Render governance deltas sparsely: project only semantic dimensions whose values change, keep unchanged dimensions implicit, and retain only the identity and context required to unambiguously interpret the change.
- ↪ **GV76** Make governance references in Git-derived projections revision-aware and navigable: linked identities, lifecycle states and operators, transitions, and elisions must resolve to documentation derived from the immutable Git revision or delta they represent; before-state references use the base revision and after-state references use the candidate or head revision. → **GV78**
- ↪ **GV77** Make `CHANGELOG.md` the canonical versioned portable materialization of each typed release entry, while the Release Please pull request and published GitHub Release project the same typed release content through a shared enriched GitHub renderer; external GitHub Release application must be verified by read-back equality. → **GV95**
- ✓ **GV95** Make Govenv the sole semantic owner of the canonical changelog: derive the governed `Unreleased` state deterministically from the latest published release boundary to the current authorized revision, preserve every historical release entry immutably and reconstructibly, freeze that exact governed state into the Release Please candidate version before human approval, and preserve the approved freeze unchanged across the merge-to-publication boundary. Release Please may determine SemVer, analyze Conventional Commits, and coordinate the candidate/tag/release lifecycle, but its rendered notes are observational input rather than independent changelog authority; the pull-request body and published GitHub Release must project the same authorized typed release document and external publication must be verified by read-back equality.
- ◇ **GV78** Define revision-aware documentation references for governed identities, lifecycle states, operators, transitions, and Agda modules and symbols, so every reference can be resolved against the repository revision or delta it semantically represents.
- ◇ **GV79** Require every versioned Markdown artifact, including literate Agda, whether handwritten or materialized, to use valid navigable documentation references for governed concepts and Agda entities whenever such references are semantically exposed.
- ◇ **GV80** Make Agda documentation addressable by immutable repository revision so revision-aware documentation references never depend on mutable current documentation.
- ◇ **GV81** Require the Release Please pull request body to project governed and Agda documentation references using the revision-aware documentation reference model for the release delta it represents.
- ◇ **GV82** Require the published GitHub Release body to project the same revision-aware governed and Agda documentation references as its release document.
- ↪ **GV7** Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt. → **GV55**
- ◇ **GV55** Model the governed release-progress policy: major and minor releases require governance progress by completing at least one pending item or advancing to a later phase; patch releases are exempt.
- ↪ **GV8** Encode GV7 as Govenv's first self-governing repository rule. → **GV56**
- ◇ **GV56** Encode and enforce GV55 as Govenv's first self-governing `Rule` over typed release governance state.

</details>

<details>
<summary>□ <strong>P2 — Pure repository evaluator</strong></summary>

- ↪ **GV25** Evaluate facts, rules, verdicts, obligations, and diagnostics without IO. → **GV64**
- ◇ **GV64** Purely evaluate facts and rules into verdicts, obligations, and typed diagnostics without IO.
- ◇ **GV65** Purely associate governance diagnostics with governed repository provenance so consumers can produce source-mapped diagnostics without IO.

</details>

<details>
<summary>□ <strong>P3 — `govenv check` and commit governance</strong></summary>

- ◇ **GV26** Observe repository facts through a thin impure adapter.
- ↪ **GV27** Produce source-mapped governance diagnostics from the pure kernel. → **GV65**
- ◇ **GV53** Expose repository evaluation as `govenv check`, with deterministic exit status and source-mapped diagnostics while keeping observation and effects outside the pure evaluator.
- ↪ **GV28** Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer. → **GV66**
- ◇ **GV66** Model governed commit policy as project data with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`, and every governed commit must reference its related roadmap subitem(s) using a `Refs: GV…` footer.
- ◇ **GV89** Treat the case-insensitive standalone word `fix` in governed commit messages as a conservative regression signal: candidate commit validation must reject it unless the commit references governed regression evidence or carries an explicit justified non-regression exemption; no exemption may discharge an unresolved observed regression.
- ◇ **GV29** Validate the staged candidate repository state using the candidate governance before accepting a commit.
- ↪ **GV30** Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly. → **GV103**
- ◇ **GV103** Enforce staged candidate and commit governance transparently through a provider-neutral Git-hook boundary whose operational installation is supplied by the active runtime backend, with Stage 0 using devenv; Govenv owns the governed gate semantics while hook-manager and provider mechanics remain integration concerns.

</details>

<details>
<summary>□ <strong>P4 — Incremental governance</strong></summary>

- ◇ **GV31** Recheck only rules affected by changed facts and emit diagnostic deltas.
- ◇ **GV32** Prove incremental checking equivalent to full checking.
- ◇ **GV33** Expose the checker through an LSP/editor loop.
- ↪ **GV34** Expose governance context and diagnostic deltas through an MCP adapter for agent clients. → **GV107**
- ◇ **GV107** Keep MCP strictly optional and adapter-only: core Governance and Protocol semantics, `govenv check`, scoped advice, LSP/editor integration, Git boundaries, and coding-agent lifecycle integration must not depend on MCP availability; any MCP integration may project the same governed context or diagnostic/advisory deltas without becoming semantic authority.
- ◇ **GV104** Separate constitutional findings from non-constitutional Protocol advisories: `govenv check` remains the authoritative full Governance evaluation, while scoped advice is selected from Protocol by semantic focus or candidate delta and may guide contributors or agents without changing repository validity; applicability belongs to Protocol semantics and relevance/scoping belongs to projections rather than editor or agent transport.
- ◇ **GV105** Expose anticipatory Governance and Protocol context through provider-neutral coding-agent lifecycle boundaries: before-tool integration may gate or rewrite governed effects using the same semantic rules, after-tool integration may attach scoped Protocol advice and context, provider capability and wire differences remain adapter concerns, and unsupported agents fall back to the available LSP, Git-hook, and authoritative check boundaries without weakening validation.
- ◇ **GV88** Require every governable obligation to be enforced at its earliest sound information boundary while retaining `govenv check` as the authoritative repository evaluation and deriving every anticipatory enforcement from the same governed rule. Maintain an explicit enforcement inventory that anticipates, at minimum: construction-time Agda constraints for typed identities, roadmap/lifecycle validity, constitutional structure, evidence relationships, pure kernel boundaries, and projection/materialization structure; static candidate or incremental/LSP checks for governance evolution, immutable identity, architecture imports, handwritten-source restrictions, materialization ownership and drift, artifact colocation, documentation references, regression obligations, governance/release deltas, and release-progress classification; commit-boundary checks for staged candidate validity, commit policy, governance references, semantic commit classification, and regression signals; PR/CI checks only for information first available from GitHub or the remote candidate; and post-effect checks only for irreducible external observations such as read-back equality, publication state, admin effects, and runtime facts. Later stages may confirm earlier results but must not re-own, duplicate, or independently specify semantics that were soundly enforceable earlier.

</details>

<details>
<summary>□ <strong>P5 — Governed runtime compiler</strong></summary>

- ◇ **GV35** Define typed Environment/Runtime IR.
- ◇ **GV67** Keep runtime backends replaceable behind the typed IR boundary.
- ◇ **GV36** Compile valid projects through a devenv backend.
- ◇ **GV37** Expose `govenv shell`, `govenv test`, and `govenv up`.
- ◇ **GV106** Make `govenv shell` establish supported editor and coding-agent integrations through the active runtime backend for agents launched within that shell, including lifecycle hooks, LSP, and Git fallback boundaries, while never packaging or taking ownership of the coding-agent executable itself.
- ◇ **GV118** Make repository-collaboration tooling an explicit governed runtime capability: the active shell must provide the project-selected provider CLI needed for candidate publication, beginning with GitHub pull-request authoring through `gh` in the devenv backend and later through `govenv shell`; agents must be able to discover and use that capability from Protocol without depending on a ChatGPT connector, IDE integration, or other out-of-band tool, while authentication remains an external runtime concern and collaboration tooling creates no semantic or authorization authority beyond the governed candidate and explicit human merge boundaries.

</details>

<details>
<summary>□ <strong>P6 — Product bootstrap, self-hosting, and distribution</strong></summary>

- ◇ **GV38** Ship a standalone `govenv` entrypoint and managed runtime setup.
- ↪ **GV40** Keep runtime backends replaceable behind the typed IR boundary. → **GV67**
- ◇ **GV39** Make Govenv govern and build itself.
- ◇ **GV41** Support white-label distributions while keeping the formal kernel reusable and product-neutral.
- ◇ **GV42** Make repository bootstrap, integrations, secrets/environments setup, and privileged materialization declarative and reproducible through Govenv rather than repository-specific manual steps.
- ◇ **GV43** Make the final product ejectable from the Govenv codebase: a white-label distribution must be able to carry its governed project model, generated CI/materializations, and integrations without depending on `klarkc/govenv` repository-specific code.

</details>

<details>
<summary>□ <strong>P7 — Language-neutral Govenv applications</strong></summary>

- ◇ **GV120** Define a canonical, versioned, language-neutral Governance IR as the semantic boundary between Govenv's Agda reference formalization and Govenv applications: compile governed identities, obligations, transitions, capabilities, authorization, evidence/certificates, and environment/runtime requirements into the IR with semantic-preservation assurance; language-specific provers, checkers, and adapters may validate certificates or reconstruct local proofs from that IR but must not independently redefine governance semantics.
- ◇ **GV121** Provide Agda formatting and linting as an external Govenv application rather than core semantic authority: prefer adopting a mature ecosystem formatter/linter when one becomes available; otherwise, once Govenv is sufficiently mature, allow a separately distributed formatter/linter to be developed using Govenv itself, with treefmt-compatible formatting and Protocol-style diagnostics while preserving the distinction between formatting/advice and constitutional validity.

</details>

## Getting started

Govenv currently uses devenv only as its Stage 0 bootstrap environment.

The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`.

### Materialization

Materialize governed repository artifacts with:

```bash
nix run github:cachix/devenv/v2.3 -- tasks run govenv:materialize
```

On `main`, the Materialize workflow applies versioned non-admin projections automatically and commits any tracked drift as a subsequent `chore(materialize)` commit. The command above remains available for local materialization.

### Administrative materialization

Stage 0 administrative bootstrap, recovery, and credential rotation, including the `admin-materialization` environment and `GOVENV_ADMIN_TOKEN`, are documented as governed literate Agda rather than duplicated here. Ordinary project-state effects reconcile automatically after authorization. [Read the governed setup guide](https://klarkc.github.io/govenv/Govenv.Administration.html).

### Test

Run the test suite with the pinned devenv tag:

```bash
nix run github:cachix/devenv/v2.3 -- test
```

This type-checks the literate Agda entrypoint `Govenv.lagda.md`, its imported Govenv modules, and verifies governed generated artifacts such as `README.md`.

### Documentation

Build the literate Agda documentation locally with:

```bash
nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs
```

The static site is written to `_site/` and deployed to GitHub Pages from `main`.
