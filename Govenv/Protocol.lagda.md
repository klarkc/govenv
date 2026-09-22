# Protocol

Protocol is Govenv's non-constitutional normative domain for
contributor and agent process guidance. It may prescribe investigation order,
heuristics, implementation discipline, and review procedure, but it does not
make a repository state constitutionally invalid merely because a different
valid process produced it.

The values below are the canonical semantic source for the repository
`AGENTS.md` materialization.

```agda
{-# OPTIONS --safe #-}

module Govenv.Protocol where

open import Agda.Builtin.String using (String; primStringAppend)

private
  infixr 5 _++_

  _++_ : String → String → String
  _++_ = primStringAppend

generatedNotice : String
generatedNotice = "<!-- Generated from Govenv.Protocol. Do not edit manually. -->\n\n"

title : String
title = "# AGENTS.md\n\n"

protocolVsGovernance : String
protocolVsGovernance = "## Protocol vs governance\n\nA **protocol** tells a contributor or AI agent how to work: which investigations to perform, which order to follow, which heuristics to apply, or which implementation choices to prefer. Protocol may depend on judgment and belongs in `Govenv.Protocol`; `AGENTS.md` is its materialized projection.\n\n**Governance** states which repository or system states, transitions, effects, or semantic properties are permitted. A governed property must be meaningful independently of which contributor or agent produced the state and belongs in Govenv governed source rather than being enforced only by contributor behavior.\n\nUse this test when classifying a rule:\n\n- If different processes may legitimately produce the same valid state, the rule about the process is probably protocol.\n- If the resulting state or effect can itself be classified as permitted or forbidden, that property is a governance candidate.\n\nProtocol must not substitute for governable semantics. When a protocol rule reveals a repository or system property that can be stated independently of contributor behavior, promote that property into governance when the constitutional model is ready to express it.\n\nThe word `policy` may also occur inside governed domain concepts, such as a release policy or deployment branch policy. Those are governed properties. `Protocol` specifically means contributor/agent process guidance in `Govenv.Protocol`.\n\n"

projectPurposeStewardship : String
projectPurposeStewardship = "## Project purpose stewardship\n\nTreat `Govenv.Project.purpose` as the canonical statement of why Govenv exists and the long-term criterion for roadmap coherence. Before declaring a material change to project scope, architecture, product boundaries, roadmap direction, or supported contributor/agent workflow ready, compare the candidate direction with the current purpose.\n\nIf the purpose no longer accurately describes the intended project, update the governed purpose deliberately as part of the same conceptual change rather than allowing implementation drift to redefine it implicitly. Do not rewrite the purpose merely to justify a local design choice; changes to purpose must represent an intentional change in project direction and remain coherent with established governance.\n\nKeep the public project description as a concise faithful summary of the canonical purpose, keep the README projection of the full purpose synchronized through its governed materialization, and review the governed website and repository topics whenever the purpose or public project identity materially changes.\n\n"

reuseFirstEngineeringPolicy : String
reuseFirstEngineeringPolicy = "## Reuse-first engineering policy\n\nThis protocol guides contributors and AI agents. It is not part of Govenv's constitutional governance model and must not be represented as a Governance item merely to enforce agent behavior.\n\nBefore introducing a new abstraction, helper, data structure, validation mechanism, script, build primitive, or workflow mechanism, first check whether the capability already exists in:\n\n1. Govenv itself.\n2. Agda builtins and the Agda standard library.\n3. Mature external Agda libraries, pinned by governed source and exposed through the materialized environment.\n4. Nixpkgs packages, only for development tools and runtime dependencies.\n5. Explicit external inputs, only for development tools and runtime dependencies when Nixpkgs does not provide an appropriate package.\n6. A bespoke Govenv implementation.\n\nExternal Agda libraries belong to the formal implementation layer and are not subject to the development-tool/runtime-only restriction above.\n\nPrefer Nixpkgs over an external tool input when both provide the same development or runtime dependency.\n\nDo not assume a bespoke implementation is necessary. Search the relevant ecosystem and inspect the version actually available in the project before designing a replacement.\n\nPrefer mature ecosystem primitives when they preserve or improve the desired semantics, proof strength, maintainability, reproducibility, and readability. Examples include standard relations, decidable equality, membership, uniqueness, collection abstractions, package/module functions, checks, builders, tasks, and service integrations.\n\nWhen custom code is still preferable, be able to state why the available ecosystem alternative is semantically insufficient, would weaken the model, would introduce disproportionate complexity, or would impose an unjustified dependency or upgrade.\n\n"

semanticValidationBeforeCheckTrust : String
semanticValidationBeforeCheckTrust = "## Semantic validation before check trust\n\nA successful automated check is evidence about the checks that currently exist; it is not permission to ignore a semantic contradiction that is already observable from established governance.\n\nBefore declaring a governed candidate or pull request ready:\n\n1. Identify the established governance and obligations relevant to the changed paths, semantics, and effects.\n2. Compare the candidate semantically with those established requirements.\n3. Run the authoritative repository checks.\n4. Compare the governed expectation, the observed candidate state, and the check result.\n5. If the candidate observably contradicts established governance while the authoritative check succeeds, treat the divergence as a counterexample to assurance/enforcement rather than as a valid candidate.\n\nDo not silently erase such a counterexample by merely editing the candidate until the check passes. Preserve the observed contradiction in the appropriate governed evidence form and investigate the missing, incorrectly scoped, or overstated assurance boundary. A later repair should reject recurrence.\n\n"

preserveTheGovenvFrontend : String
preserveTheGovenvFrontend = "## Preserve the Govenv frontend\n\nReuse should normally happen below the public Govenv model and DSL. Do not distort domain concepts merely to fit a library API.\n\n"

documentationFollowsSemanticAuthority : String
documentationFollowsSemanticAuthority = "## Documentation follows semantic authority\n\nTreat `*.lagda.md` as human-facing normative semantic authority. Governance and Protocol are both literate domains: prose and formalization belong together in the same literate module.\n\nImplementation domains such as Kernel, Projection, Adapter, and Experiment are code-first. Their documentation belongs in the same owning `.agda` source rather than in adjacent handwritten Markdown files.\n\nStandalone versioned documents are not independent semantic authority. They must be governed materializations unless they are themselves literate normative source or governed evidence represented as a literate module. `AGENTS.md` is materialized from `Govenv.Protocol` and must not be edited as an authority.\n\nPrefer this layering:\n\n```text\nGovenv.Governance / Govenv.Protocol\n                    ↓\n             Govenv semantic kernel\n                    ↓\nAgda stdlib / external Agda libraries / Nixpkgs packages / devenv modules / flake inputs\n```\n\nInternal representation may become substantially more sophisticated or dependent while the public syntax and concepts remain stable. Pattern synonyms, modules, adapters, projections, hidden arguments, and other abstraction boundaries may be used to keep implementation machinery out of the frontend.\n\nDo not change established frontend syntax or semantics solely because an underlying library uses a different representation. If an ecosystem abstraction genuinely reveals a better domain model, make that conceptual change explicit rather than allowing it to leak accidentally from an implementation refactor.\n\n"

refactoringAuthority : String
refactoringAuthority = "## Refactoring authority\n\nAgents are explicitly allowed to refactor across the codebase when doing so removes unnecessary bespoke infrastructure in favor of mature ecosystem capabilities, provided the intended Govenv semantics and external behavior are preserved or deliberately improved.\n\nA refactor may cross kernel, adapters, projections, materializations, Nix, devenv, tests, and documentation when that is the coherent way to remove duplication. Avoid compatibility wrappers whose only purpose is to preserve obsolete internal machinery.\n\nAfter such a refactor, run the relevant Agda typechecks and the project's materialization/check tasks. Generated artifacts must still derive from their governed sources rather than being hand-maintained.\n\n"

dependencyDiscipline : String
dependencyDiscipline = "## Dependency discipline\n\nReuse-first does not mean dependency-first. The dependency preference is: Govenv → Agda builtins/stdlib → external Agda library → Nixpkgs package * → explicit external input * → bespoke implementation.\n\n`*` Nixpkgs packages and non-Agda external inputs are only for development tools and runtime dependencies.\n\nFor Agda, check builtins and the pinned standard library first. External Agda libraries must be immutably pinned by governed source; their acquisition mechanism is an implementation detail of the materialized environment.\n\nPrefer Nixpkgs whenever it already provides the required development tool or runtime package. Use an explicit external input for those dependencies only when Nixpkgs is not adequate.\n\nTreat ecosystem investigation as part of implementation, not as optional cleanup. For non-trivial new infrastructure, perform this reuse check before settling on a custom design.\n\n"

devenvGeneratedState : String
devenvGeneratedState = "## devenv generated state\n\nThe target environment has no versioned `devenv.yaml`. `devenv.nix` is a governed materialization of dependency and environment state rather than a semantic authority of its own.\n\n`devenv.lock` is transient resolver state. It may be generated locally by devenv when deterministically derivable from governed inputs, but it must not become a versioned dependency authority; keep it ignored once the migration reaches this target state.\n\nDependency pins, update constraints, and update rationale belong to governed source. Do not duplicate that policy as authoritative comments or metadata in generated Nix or transient lock state. Literate Agda documents the governed meaning and rationale while implementation modules carry incidental rendering and acquisition details.\n\n"

centralizedDependencyManagement : String
centralizedDependencyManagement = "## Centralized dependency management\n\nNever introduce or use language-specific or application-level package managers in the codebase for dependency acquisition or resolution. Dependency management is centralized in devenv/Nix.\n\nDo not add dependency workflows based on npm, pnpm, yarn, pip, Poetry, uv, Cargo, Cabal, Stack, Bundler, or equivalents. Do not introduce their lockfiles or dependency-resolution manifests as a second dependency authority.\n\nDevelopment tools and runtime dependencies must come from Nixpkgs when available, or from explicit governed external inputs when an external source is justified. External Agda libraries are immutably pinned by governed source and made available through the materialized environment.\n\nIndividual tools may still be executed normally once provisioned by devenv; the prohibition is on using their ecosystem package managers as dependency authorities.\n"

document : String
document =
  generatedNotice ++ title
  ++ protocolVsGovernance
  ++ projectPurposeStewardship
  ++ reuseFirstEngineeringPolicy
  ++ semanticValidationBeforeCheckTrust
  ++ preserveTheGovenvFrontend
  ++ documentationFollowsSemanticAuthority
  ++ refactoringAuthority
  ++ dependencyDiscipline
  ++ devenvGeneratedState
  ++ centralizedDependencyManagement
```
