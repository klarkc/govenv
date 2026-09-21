# AGENTS.md

## Reuse-first engineering policy

This is an operational engineering policy for contributors and AI agents. It is not part of Govenv's constitutional governance model and must not be represented as a Governance item merely to enforce agent behavior.

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

## Preserve the Govenv frontend

Reuse should normally happen below the public Govenv model and DSL. Do not distort domain concepts merely to fit a library API.

## Literate Agda is for governance

Treat `*.lagda.md` as governed semantic documentation, not as an implementation manual. Literate Agda should express governance, governed domain facts, constitutional rationale, and the human-readable meaning of formal decisions. It may contain the Agda necessary to state or establish those governed facts, but it should not expose incidental implementation details, plumbing, backend mechanics, library-specific APIs, rendering algorithms, or materializer internals merely to explain how the implementation works.

Keep implementation detail in the appropriate kernel, projection, adapter, materializer, Nix, or other implementation module. When implementation details are needed to establish a governed property, expose only the semantic boundary needed by the governance layer.

`AGENTS.md` is the operational materialization of contributor and agent policy. Process guidance, reuse heuristics, coding conventions, implementation-selection policy, and similar non-constitutional instructions belong here rather than in literate Agda unless they are promoted into an actual governed property.

Prefer this layering:

```text
Govenv frontend / domain language
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
