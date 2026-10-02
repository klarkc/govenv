# Human learning evidence

This module stores exact human-produced review-contract/response evidence used
to close Govenv learning requirements. The capture tool may mechanically append
the human principal identity, governed requirement, exact current review
contract, and exact response, but it must not synthesize, rewrite, or grade the
response. Review-contract matching is evidence freshness, not proof of mental
state or response quality.

```agda
{-# OPTIONS --safe #-}

module Govenv.LearningEvidence where

open import Agda.Builtin.Equality using (refl)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String)
open import Govenv.Authorization using
  (HumanPrincipal; humanPrincipal; observedPrincipal; human)
open import Govenv.Kernel.Learning using
  (LearningRequirement; learningRequirement)

record DemonstratedLearning : Set where
  constructor demonstratedLearning
  field
    requirement : LearningRequirement
    principal : HumanPrincipal
    reviewContract : String
    response : String

claimedHumanPrincipal : String → HumanPrincipal
claimedHumanPrincipal identity =
  humanPrincipal (observedPrincipal identity human) refl

evidence : List DemonstratedLearning
evidence =
  -- govenv-learning-evidence:start
  demonstratedLearning
    (learningRequirement "Explain Govenv's purpose and why keeping agent speed behind meaningful human authority is part of the product rather than an informal convention." "eac603e07e6eae7b5dc7c2d762d422003c4459a4")
    (claimedHumanPrincipal "walkerleite490@gmail.com")
    "Review surface: Govenv.Project.purpose/purposeReviewIndex/purposeReviewRationale; Govenv.DirectionReview; src/Govenv/Kernel/Protocol.agda; Govenv.Assurance.GV110; Govenv.Assurance.GV110.Counterexample.MechanicalBump; Govenv.Materialization.ProjectPurposeSnapshot; src/Govenv/Adapter/PurposeVigilance.agda; src/Govenv/Adapter/roadmap-evolution.sh; Govenv.Materialization.Readme; src/Govenv/Adapter/Readme.agda; devenv.nix checkMaterializations README equality boundary | Semantic probe: In your own words: what failure is Govenv preventing, and why is human authority part of the product rather than merely a team convention? | Code probe: Locate the canonical purpose, trace one projection of it, and identify the code that makes a mechanical purpose-review counter bump insufficient. | Assurance probe: If README or a review counter changed while the governed purpose/review evidence did not, explain which checks should reject the candidate and what they do not prove."
    "1. O govenv tenta impedir que agentes tomem decisões que mudam o propósito do produto sem conhecimento do humano. Por esse motivo o humano faz parte do processo de criação e manutenção de GV's, com garantias usando provas formais que o software atende ao roadmap estabelecido e acordado com humano.\n2. Govenv.Project ele chega ao README via materialização e `protocolReviewFresh true false false 4 5` termina em false porque `reviewEvidenceFresh true false false` reduz para false.\n3. Edição manual do README é rejeitado pelo Adapter/CI, o bump mecânico de purposeReviewIndex é rejeitado por purposeReviewFresh reduzindo a false. Agda prova que o programa compila, Adapter/CI observa e valida mudança no README.md e a semântica do rationale é julgamento humano."
  ∷
  []
  -- govenv-learning-evidence:end
```
