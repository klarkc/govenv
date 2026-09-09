# Roadmap

The roadmap is governed project data. Its README projection intentionally exposes only two levels: phases and their direct items.

```agda
{-# OPTIONS --safe #-}

module Govenv.Roadmap where

open import Agda.Builtin.Bool
open import Agda.Builtin.List
open import Agda.Builtin.Nat using (Nat; _<_)
open import Agda.Builtin.String

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

data PhaseId : Set where
  R0 R1 R2 R3 R4 R5 R6 : PhaseId

data ItemState : Set where
  done todo : ItemState

data PhaseState : Set where
  finished active future : PhaseState

record Item (owner : PhaseId) : Set where
  constructor item
  field
    itemNumber : Nat
    itemTitle : String
    itemState : ItemState

record Phase : Set where
  constructor phase
  field
    phaseId : PhaseId
    phaseTitle : String
    phaseState : PhaseState
    phaseItems : List (Item phaseId)

renderPhaseId : PhaseId → String
renderPhaseId R0 = "R0"
renderPhaseId R1 = "R1"
renderPhaseId R2 = "R2"
renderPhaseId R3 = "R3"
renderPhaseId R4 = "R4"
renderPhaseId R5 = "R5"
renderPhaseId R6 = "R6"

renderOrdinal : Nat → String
renderOrdinal n with n < 10
... | true = "0" ++ primShowNat n
... | false = primShowNat n

checkbox : ItemState → String
checkbox done = "[x]"
checkbox todo = "[ ]"

phaseMark : PhaseState → String
phaseMark finished = "☑"
phaseMark active = "☐"
phaseMark future = "☐"

openAttribute : PhaseState → String
openAttribute active = " open"
openAttribute _ = ""

currentMark : PhaseState → String
currentMark active = " ← current"
currentMark _ = ""

renderItem : {owner : PhaseId} → Item owner → String
renderItem {owner} (item number title state) =
  "- " ++ checkbox state ++ " **" ++ renderPhaseId owner ++ "-" ++ renderOrdinal number ++ "** " ++ title ++ "\n"

renderItems : {owner : PhaseId} → List (Item owner) → String
renderItems [] = ""
renderItems (x ∷ xs) = renderItem x ++ renderItems xs

renderPhase : Phase → String
renderPhase (phase identifier title state items) =
  "<details" ++ openAttribute state ++ ">\n" ++
  "<summary>" ++ phaseMark state ++ " <strong>" ++ renderPhaseId identifier ++ " — " ++ title ++ "</strong>" ++ currentMark state ++ "</summary>\n\n" ++
  renderItems items ++ "\n</details>\n\n"

renderPhases : List Phase → String
renderPhases [] = ""
renderPhases (x ∷ xs) = renderPhase x ++ renderPhases xs

phase0 : Phase
phase0 = phase R0 "Bootstrap and project shape" finished
  ( item 1 "Literate `Govenv.lagda.md` closure root." done
  ∷ item 2 "Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`." done
  ∷ item 3 "Reproducible Stage 0 bootstrap, documentation site, and automated releases." done
  ∷ [] )

phase1 : Phase
phase1 = phase R1 "Formal governance kernel" active
  ( item 1 "`Verdict`: `holds`, `violated`, and `unknown`." done
  ∷ item 2 "Minimal `Rule` abstraction." done
  ∷ item 3 "Typed repository facts." done
  ∷ item 4 "Dependency-indexed rules." todo
  ∷ item 5 "Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt." todo
  ∷ item 6 "Encode R1-05 as Govenv's first self-governing repository rule." todo
  ∷ item 7 "Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration." todo
  ∷ item 8 "Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention." todo
  ∷ item 9 "Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified." todo
  ∷ item 10 "CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change." todo
  ∷ item 11 "CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change." todo
  ∷ item 12 "Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check." done
  ∷ item 13 "Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible." done
  ∷ item 14 "Materialize governed README sections from Agda rather than maintaining duplicate prose by hand." done
  ∷ [] )

phase2 : Phase
phase2 = phase R2 "Pure repository evaluator" future
  ( item 1 "Evaluate facts, rules, verdicts, obligations, and diagnostics without IO." todo
  ∷ [] )

phase3 : Phase
phase3 = phase R3 "`govenv check` and commit governance" future
  ( item 1 "Observe repository facts through a thin impure adapter." todo
  ∷ item 2 "Produce source-mapped governance diagnostics from the pure kernel." todo
  ∷ item 3 "Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`." todo
  ∷ item 4 "Validate the staged candidate repository state using the candidate governance before accepting a commit." todo
  ∷ item 5 "Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly." todo
  ∷ [] )

phase4 : Phase
phase4 = phase R4 "Incremental governance" future
  ( item 1 "Recheck only rules affected by changed facts and emit diagnostic deltas." todo
  ∷ item 2 "Prove incremental checking equivalent to full checking." todo
  ∷ item 3 "Expose the checker through an LSP/editor loop." todo
  ∷ item 4 "Expose governance context and diagnostic deltas through an MCP adapter for agent clients." todo
  ∷ [] )

phase5 : Phase
phase5 = phase R5 "Governed runtime compiler" future
  ( item 1 "Define typed Environment/Runtime IR." todo
  ∷ item 2 "Compile valid projects through a devenv backend." todo
  ∷ item 3 "Expose `govenv shell`, `govenv test`, and `govenv up`." todo
  ∷ [] )

phase6 : Phase
phase6 = phase R6 "Product bootstrap and self-hosting" future
  ( item 1 "Ship a standalone `govenv` entrypoint and managed runtime setup." todo
  ∷ item 2 "Make Govenv govern and build itself." todo
  ∷ item 3 "Keep runtime backends replaceable behind the typed IR boundary." todo
  ∷ item 4 "Support white-label distributions while keeping the formal kernel reusable and product-neutral." todo
  ∷ [] )

roadmap : List Phase
roadmap = phase0 ∷ phase1 ∷ phase2 ∷ phase3 ∷ phase4 ∷ phase5 ∷ phase6 ∷ []

renderCurrent : Phase → String
renderCurrent (phase identifier title _ _) =
  "**Current:** " ++ renderPhaseId identifier ++ " — " ++ title ++ ". `Verdict`, typed `Fact`, and the current `Rule` model are in place; dependency-indexed rules and the first self-governing rule are next.\n\n"

renderRoadmap : String
renderRoadmap =
  "## Roadmap\n\n" ++
  renderCurrent phase1 ++
  "> This roadmap is subject to change as Govenv's architecture evolves. IDs are intended to remain stable references whenever practical.\n\n" ++
  renderPhases roadmap
```
