# Roadmap

The roadmap is governed project data. Its README projection intentionally exposes only two levels: phases and their direct items.

```agda
{-# OPTIONS --safe #-}

module Govenv.Roadmap where

open import Agda.Builtin.Bool
open import Agda.Builtin.List
open import Agda.Builtin.String

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

record Item : Set where
  constructor item
  field
    itemId : String
    itemTitle : String
    itemDone : Bool

record Phase : Set where
  constructor phase
  field
    phaseId : String
    phaseTitle : String
    phaseDone : Bool
    phaseCurrent : Bool
    phaseItems : List Item

checkbox : Bool → String
checkbox true = "[x]"
checkbox false = "[ ]"

phaseMark : Bool → String
phaseMark true = "☑"
phaseMark false = "☐"

openAttribute : Bool → String
openAttribute true = " open"
openAttribute false = ""

currentMark : Bool → String
currentMark true = " ← current"
currentMark false = ""

renderItem : Item → String
renderItem (item identifier title done) =
  "- " ++ checkbox done ++ " **" ++ identifier ++ "** " ++ title ++ "\n"

renderItems : List Item → String
renderItems [] = ""
renderItems (x ∷ xs) = renderItem x ++ renderItems xs

renderPhase : Phase → String
renderPhase (phase identifier title done current items) =
  "<details" ++ openAttribute current ++ ">\n" ++
  "<summary>" ++ phaseMark done ++ " <strong>" ++ identifier ++ " — " ++ title ++ "</strong>" ++ currentMark current ++ "</summary>\n\n" ++
  renderItems items ++ "\n</details>\n\n"

renderPhases : List Phase → String
renderPhases [] = ""
renderPhases (x ∷ xs) = renderPhase x ++ renderPhases xs

roadmap : List Phase
roadmap =
  phase "R0" "Bootstrap and project shape" true false
    ( item "R0-01" "Literate `Govenv.lagda.md` closure root." true
    ∷ item "R0-02" "Project governance under `Govenv/`; reusable kernel under `Govenv.Kernel.*`." true
    ∷ item "R0-03" "Reproducible Stage 0 bootstrap, documentation site, and automated releases." true
    ∷ [] )
  ∷ phase "R1" "Formal governance kernel" false true
    ( item "R1-01" "`Verdict`: `holds`, `violated`, and `unknown`." true
    ∷ item "R1-02" "Minimal `Rule` abstraction." true
    ∷ item "R1-03" "Typed repository facts." true
    ∷ item "R1-04" "Dependency-indexed rules." false
    ∷ item "R1-05" "Roadmap release rule: every major or minor release must advance the roadmap by completing at least one unchecked item or moving `Current` to a later phase; patch releases are exempt." false
    ∷ item "R1-06" "Encode R1-05 as Govenv's first self-governing repository rule." false
    ∷ item "R1-07" "Extract governance rules from behavior, conventions, and infrastructure already implemented in the repository so existing decisions become explicit rather than remaining implicit in code or configuration." false
    ∷ item "R1-08" "Governance coverage rule: every project property that can be expressed and checked by Govenv must become a governance rule rather than remain an unenforced convention." false
    ∷ item "R1-09" "Minimize the ungoverned surface: keep only unavoidable observation, IO, and adapter effects outside governance, and make every remaining exception explicit and justified." false
    ∷ item "R1-10" "CI governance rule: Govenv CI must run on Determinate Nix; changing the Nix runtime requires an explicit governance change." false
    ∷ item "R1-11" "CI cache governance rule: every Govenv CI workflow that evaluates or builds Nix must use a local GitHub Actions Nix cache through `magic-nix-cache-action`; removing or replacing it requires an explicit governance change." false
    ∷ item "R1-12" "Govern the README as a canonical materialization of `Govenv.Readme`; manual divergence must fail the project check." true
    ∷ item "R1-13" "Keep the README roadmap projection to exactly two visible levels, `Phase → Item`, with phases collapsible." true
    ∷ item "R1-14" "Materialize governed README sections from Agda rather than maintaining duplicate prose by hand." true
    ∷ [] )
  ∷ phase "R2" "Pure repository evaluator" false false
    ( item "R2-01" "Evaluate facts, rules, verdicts, obligations, and diagnostics without IO." false
    ∷ [] )
  ∷ phase "R3" "`govenv check` and commit governance" false false
    ( item "R3-01" "Observe repository facts through a thin impure adapter." false
    ∷ item "R3-02" "Produce source-mapped governance diagnostics from the pure kernel." false
    ∷ item "R3-03" "Define governed commit policy with a simplified Conventional Commits vocabulary; governance changes must use `gov(...)`." false
    ∷ item "R3-04" "Validate the staged candidate repository state using the candidate governance before accepting a commit." false
    ∷ item "R3-05" "Enforce commit governance transparently through a Git hook; Stage 0 installs it through devenv, and Govenv later owns the integration directly." false
    ∷ [] )
  ∷ phase "R4" "Incremental governance" false false
    ( item "R4-01" "Recheck only rules affected by changed facts and emit diagnostic deltas." false
    ∷ item "R4-02" "Prove incremental checking equivalent to full checking." false
    ∷ item "R4-03" "Expose the checker through an LSP/editor loop." false
    ∷ item "R4-04" "Expose governance context and diagnostic deltas through an MCP adapter for agent clients." false
    ∷ [] )
  ∷ phase "R5" "Governed runtime compiler" false false
    ( item "R5-01" "Define typed Environment/Runtime IR." false
    ∷ item "R5-02" "Compile valid projects through a devenv backend." false
    ∷ item "R5-03" "Expose `govenv shell`, `govenv test`, and `govenv up`." false
    ∷ [] )
  ∷ phase "R6" "Product bootstrap and self-hosting" false false
    ( item "R6-01" "Ship a standalone `govenv` entrypoint and managed runtime setup." false
    ∷ item "R6-02" "Make Govenv govern and build itself." false
    ∷ item "R6-03" "Keep runtime backends replaceable behind the typed IR boundary." false
    ∷ item "R6-04" "Support white-label distributions while keeping the formal kernel reusable and product-neutral." false
    ∷ [] )
  ∷ []

renderRoadmap : String
renderRoadmap =
  "## Roadmap\n\n" ++
  "**Current:** R1 — Formal governance kernel. `Verdict`, typed `Fact`, and the current `Rule` model are in place; dependency-indexed rules and the first self-governing rule are next.\n\n" ++
  "> This roadmap is subject to change as Govenv's architecture evolves. IDs are intended to remain stable references whenever practical.\n\n" ++
  renderPhases roadmap
```
