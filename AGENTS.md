<!-- Generated from Govenv.Protocol. Do not edit manually. -->

# AGENTS.md

## Protocol vs governance

A **protocol** tells a contributor or AI agent how to work: which investigations to perform, which order to follow, which heuristics to apply, or which implementation choices to prefer. Protocol may depend on judgment and belongs in `Govenv.Protocol`; `AGENTS.md` is its materialized projection.

**Governance** states which repository or system states, transitions, effects, or semantic properties are permitted. A governed property must be meaningful independently of which contributor or agent produced the state and belongs in Govenv governed source rather than being enforced only by contributor behavior.

Use this test when classifying a rule:

- If different processes may legitimately produce the same valid state, the rule about the process is probably protocol.
- If the resulting state or effect can itself be classified as permitted or forbidden, that property is a governance candidate.

Protocol must not substitute for governable semantics. When a protocol rule reveals a repository or system property that can be stated independently of contributor behavior, promote that property into governance when the constitutional model is ready to express it.

The word `policy` may also occur inside governed domain concepts, such as a release policy or deployment branch policy. Those are governed properties. `Protocol` specifically means contributor/agent process guidance in `Govenv.Protocol`.

## Protocol vigilance witnesses

Some Protocol obligations require irreducible contributor or agent judgment that a compiler cannot honestly prove, while the need to exercise that judgment can still have a precise semantic trigger. In those cases Govenv may pair the Protocol with a governed **vigilance witness**: a minimal explicit state change whose freshness establishes only that the review was actively acknowledged after the trigger. The witness never proves that the judgment itself was correct and therefore does not promote the Protocol content into Governance.

Use a vigilance witness only when the Protocol judgment is genuinely non-decidable, the trigger is objective and stable, forgetting the review creates material risk, and the witness can remain low-noise. If the desired outcome is itself machine-decidable and determines constitutional validity, model that outcome directly as Governance instead. Avoid vigilance witnesses for noisy high-frequency triggers, low-value reviews, or cases where they would become checkbox theater. Never derive or advance a vigilance witness automatically: automatic acknowledgement destroys the signal that a contributor or agent actively maintained the judgment.

For counter-style witnesses, preserve the index when neither trigger nor reviewed subject changes; increment it exactly once when the trigger changes and the subject is deliberately reaffirmed; reset it to zero whenever the reviewed subject itself changes. Enforce witness freshness at the earliest sound information boundary while keeping the underlying judgment in Protocol.

## Project purpose stewardship

Treat `Govenv.Project.purpose` as the canonical statement of why Govenv exists and the long-term criterion for roadmap coherence. Every semantic change to `Govenv.Roadmap` must review the current purpose against the complete resulting roadmap, not only the changed item or phase. Material changes to project scope, architecture, product boundaries, or supported contributor/agent workflow outside the roadmap must also review the purpose.

If the purpose no longer accurately describes the intended project, update the governed purpose deliberately as part of the same conceptual change rather than allowing implementation drift to redefine it implicitly. Do not rewrite the purpose merely to justify a local design choice; changes to purpose must represent an intentional change in project direction and remain coherent with established governance. `Govenv.Project.purposeReviewIndex` is the vigilance witness for this review: when the roadmap changes semantically and the purpose is reaffirmed unchanged, increment the index exactly once; whenever the purpose itself changes, reset the index to zero; when neither changes, preserve the index. Never advance the index mechanically or merely to satisfy the compiler.

Write the purpose as durable product positioning for developers first. Lead with the practical outcome and value a developer gets from adopting Govenv, use concrete language that remains understandable without roadmap or internal architecture context, and prefer stable product capabilities over current implementation mechanisms. The purpose should be concise, memorable, credible, and technically precise enough to serve as public product copy while remaining faithful to the full long-term roadmap. Avoid hype, unsupported superlatives, vague promises, internal governance identifiers, and incidental backend or tooling names unless they are essential to the product identity.

Project the same canonical purpose verbatim anywhere Govenv presents its public project statement, including the README hero and GitHub repository description; do not maintain a separate summary property that can drift from it. Review the governed website and repository topics whenever the purpose or public project identity materially changes.

## Project direction review

Treat project direction as one review over the complete governed state, not as independently maintained status prose. Purpose states the long-term direction. Current summarizes where governed evidence says the project is now. Next identifies the immediate gap selected between Purpose and Current. Roadmap makes that selected direction executable.

Whenever a source relevant to Current or Next changes, review the complete resulting direction rather than patching one sentence locally. The agent must consider every typed subject supplied by the direction-review closure and give each subject an explicit disposition. The compiler may prove bounds, provenance, coverage, reference validity, and freshness; it must not pretend to prove the quality of the natural-language judgment. The human authorizes that judgment through the pull request.

Keep Current and Next concise enough to serve as immediate README feedback. They are summaries, not duplicate backlogs or secondary semantic authorities. Current must not claim progress unsupported by governed state. Next must remain coherent with Purpose and Current and must not hide known unresolved gaps merely because they do not yet have a GovernanceId.

## Session and corpus consolidation

Do not rely on an agent remembering prior sessions. When a session, handoff, recovery archive, or other knowledge corpus is declared as relevant project input, bind it to immutable provenance and consolidate it before allowing semantic roadmap evolution. Extract the observations that may matter to project direction and give every declared observation exactly one explicit disposition: represented by current governed state, superseded by an identified decision, rejected with rationale, or irrelevant with rationale.

An undisposed observation keeps the direction review stale. Absence from Current, Next, or Roadmap is never by itself evidence that an observation was considered. This protocol does not claim that a compiler can observe private model state or prove perfect natural-language extraction; it requires complete treatment of the declared observation set and preserves provenance so a human or later agent can audit the judgment.

## Human learning continuity

Treat human learning as part of preserving meaningful human authorization, not as an agent self-report. A conceptual change may derive learning requirements from the semantic delta and from substrate techniques, such as Agda constructs, only when those techniques are necessary to understand or review the governed property. Preserve the exact challenge and human response as revision-bound evidence; an agent or tutor may generate challenges and explanations, but its confidence or assertion that the human understood something is never canonical evidence.

Pull requests use a soft learning gate. If governed learning debt is empty, work may proceed normally. If debt is open, feature work and concept-expanding refactors must not merge. Urgent corrective work may bypass the gate only through the explicit corrective bypass and must preserve every unsatisfied requirement as outstanding debt; bypass never closes, rewrites, or hides debt. Patch releases may carry known debt, while major and minor releases require zero outstanding learning debt.

The developer environment must expose a human-facing learning surface. Inside `devenv shell`, use `govenv-learning status` to inspect debt, `govenv-learning catch-up` to start from the exact outstanding claims, and `govenv-learning review` before closing evidence or authorizing conceptual work. Equivalent `govenv:learning:*` tasks remain available for automation. The future `govenv shell` must preserve the same semantic capability, preferably as `govenv learning ...`, rather than creating a second learning authority.

Learning evidence proves only that the recorded human principal produced the recorded response to the recorded challenge at the bound revision. The compiler may prove provenance, coverage, freshness, gate decisions, and release eligibility; it must never claim to prove the human's mental state.

## Developer journal and social posts

Treat Govenv social posts as a technical development journal, not advertising. Write for developers who should be able to see what changed, why it matters, what the project is doing now, and where it is going next without hype, unsupported claims, or generic promotional language.

Every ordinary candidate pull request must carry its own reviewed developer-journal draft as part of the candidate rather than relying on a later automation to open a second approval pull request. The agent preparing the candidate must create the post text and square image according to this Protocol, bind them to the exact candidate delta and current project-direction review, and include enough preview material in the pull request for the human merger to review them. Human merge of that same pull request is the editorial authorization. After merge, the post-authorized publisher must publish only the exact approved text and image to X without requesting another human approval.

Release Please pull requests use the release-journal path instead of producing an additional ordinary pull-request journal entry. For a major or minor release, the Release Please candidate must include a preview of the release post derived from the exact frozen typed ReleaseDocument being approved. Approval and merge of that Release Please pull request authorize that exact release post; publish it only after the corresponding release boundary is established. Patch releases need no release post unless another independent rule requires one.

For every draft, cover all relevant source changes explicitly in typed metadata before writing the natural-language summary. The agent may compress, group, or intentionally omit a source change only through an explicit disposition with rationale; the compiler should validate coverage, provenance, target character limits, template identity, freshness, and the binding from approved artifact to authorized revision. Never reconstruct a post from memory after merge when the approved candidate already owns the text and image.

Use the canonical Govenv logo and governed square developer-journal image pattern for each post. Preserve the visual grammar: DEV JOURNAL identity, concise How we got here context, What we're doing now, Where we're going next, and the repository link. Generate the image from a governed image brief tied to the same source revision as the text. Visual generation remains an agent judgment and must be reviewed together with the post rather than treated as compiler-proven semantics.

Publishing is an external effect. The social publisher receives only the dedicated X provider grant, publishes idempotently, reads the resulting post identity or URL back, and retains revision-addressable publication evidence. X credentials are external provider grants that must be materialized by Admin Materialize into the social-publish capability boundary and must never become versioned repository content. Publication failure must not mutate the approved journal artifact or create a second semantic authority for its content.

## Reuse-first engineering policy

This protocol guides contributors and AI agents. It is not part of Govenv's constitutional governance model and must not be represented as a Governance item merely to enforce agent behavior.

Before introducing a new abstraction, helper, data structure, validation mechanism, script, build primitive, or workflow mechanism, first check whether the capability already exists in:

1. Govenv itself.
2. Agda builtins and the Agda standard library.
3. Mature external Agda libraries, pinned by governed source and exposed through the materialized environment.
4. Nixpkgs packages, only for development tools and runtime dependencies.
5. Explicit external inputs, only for development tools and runtime dependencies when Nixpkgs does not provide an appropriate package.
6. A bespoke Govenv implementation.

External Agda libraries belong to the formal implementation layer and are not subject to the development-tool/runtime-only restriction above.

Prefer Nixpkgs over an external tool input when both provide the same development or runtime dependency.

Do not assume a bespoke implementation is necessary. Search the relevant ecosystem and inspect the version actually available in the project before designing a replacement.

Prefer mature ecosystem primitives when they preserve or improve the desired semantics, proof strength, maintainability, reproducibility, and readability. Examples include standard relations, decidable equality, membership, uniqueness, collection abstractions, package/module functions, checks, builders, tasks, and service integrations.

When custom code is still preferable, be able to state why the available ecosystem alternative is semantically insufficient, would weaken the model, would introduce disproportionate complexity, or would impose an unjustified dependency or upgrade.

## Semantic validation before check trust

A successful automated check is evidence about the checks that currently exist; it is not permission to ignore a semantic contradiction that is already observable from established governance.

Before declaring a governed candidate or pull request ready:

1. Identify the established governance and obligations relevant to the changed paths, semantics, and effects.
2. Compare the candidate semantically with those established requirements.
3. Run the authoritative repository checks.
4. Compare the governed expectation, the observed candidate state, and the check result.
5. If the candidate observably contradicts established governance while the authoritative check succeeds, treat the divergence as a counterexample to assurance/enforcement rather than as a valid candidate.

Do not silently erase such a counterexample by merely editing the candidate until the check passes. Preserve the observed contradiction in the appropriate governed evidence form and investigate the missing, incorrectly scoped, or overstated assurance boundary. A later repair should reject recurrence.

## Preserve the Govenv frontend

Reuse should normally happen below the public Govenv model and DSL. Do not distort domain concepts merely to fit a library API.

## Documentation follows semantic authority

Treat `*.lagda.md` as human-facing normative semantic authority. Governance and Protocol are both literate domains: prose and formalization belong together in the same literate module.

Implementation domains such as Kernel, Projection, Adapter, and Experiment are code-first. Their documentation belongs in the same owning `.agda` source rather than in adjacent handwritten Markdown files.

Standalone versioned documents are not independent semantic authority. They must be governed materializations unless they are themselves literate normative source or governed evidence represented as a literate module. `AGENTS.md` is materialized from `Govenv.Protocol` and must not be edited as an authority.

Prefer this layering:

```text
Govenv.Governance / Govenv.Protocol
                    ↓
             Govenv semantic kernel
                    ↓
Agda stdlib / external Agda libraries / Nixpkgs packages / devenv modules / flake inputs
```

Internal representation may become substantially more sophisticated or dependent while the public syntax and concepts remain stable. Pattern synonyms, modules, adapters, projections, hidden arguments, and other abstraction boundaries may be used to keep implementation machinery out of the frontend.

Do not change established frontend syntax or semantics solely because an underlying library uses a different representation. If an ecosystem abstraction genuinely reveals a better domain model, make that conceptual change explicit rather than allowing it to leak accidentally from an implementation refactor.

## Refactoring authority

Agents are explicitly allowed to refactor across the codebase when doing so removes unnecessary bespoke infrastructure in favor of mature ecosystem capabilities, provided the intended Govenv semantics and external behavior are preserved or deliberately improved.

A refactor may cross kernel, adapters, projections, materializations, Nix, devenv, tests, and documentation when that is the coherent way to remove duplication. Avoid compatibility wrappers whose only purpose is to preserve obsolete internal machinery.

After such a refactor, run the relevant Agda typechecks and the project's materialization/check tasks. Generated artifacts must still derive from their governed sources rather than being hand-maintained.

## Dependency discipline

Reuse-first does not mean dependency-first. The dependency preference is: Govenv → Agda builtins/stdlib → external Agda library → Nixpkgs package * → explicit external input * → bespoke implementation.

`*` Nixpkgs packages and non-Agda external inputs are only for development tools and runtime dependencies.

For Agda, check builtins and the pinned standard library first. External Agda libraries must be immutably pinned by governed source; their acquisition mechanism is an implementation detail of the materialized environment.

Prefer Nixpkgs whenever it already provides the required development tool or runtime package. Use an explicit external input for those dependencies only when Nixpkgs is not adequate.

Treat ecosystem investigation as part of implementation, not as optional cleanup. For non-trivial new infrastructure, perform this reuse check before settling on a custom design.

## devenv generated state

The target environment has no versioned `devenv.yaml`. `devenv.nix` is a governed materialization of dependency and environment state rather than a semantic authority of its own.

`devenv.lock` is transient resolver state. It may be generated locally by devenv when deterministically derivable from governed inputs, but it must not become a versioned dependency authority; keep it ignored once the migration reaches this target state.

Dependency pins, update constraints, and update rationale belong to governed source. Do not duplicate that policy as authoritative comments or metadata in generated Nix or transient lock state. Literate Agda documents the governed meaning and rationale while implementation modules carry incidental rendering and acquisition details.

## Centralized dependency management

Never introduce or use language-specific or application-level package managers in the codebase for dependency acquisition or resolution. Dependency management is centralized in devenv/Nix.

Do not add dependency workflows based on npm, pnpm, yarn, pip, Poetry, uv, Cargo, Cabal, Stack, Bundler, or equivalents. Do not introduce their lockfiles or dependency-resolution manifests as a second dependency authority.

Development tools and runtime dependencies must come from Nixpkgs when available, or from explicit governed external inputs when an external source is justified. External Agda libraries are immutably pinned by governed source and made available through the materialized environment.

Individual tools may still be executed normally once provisioned by devenv; the prohibition is on using their ecosystem package managers as dependency authorities.
