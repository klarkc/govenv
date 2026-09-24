# Consolidation

Govenv does not rely on model memory as project state. A declared knowledge
corpus is an immutable external input plus a finite, human-reviewable extracted
observation type. Consolidation is complete only when every declared
observation has exactly one explicit disposition.

The compiler proves closure of the declared observation set. It does not claim
to prove that an LLM exposed all private memory or that natural-language
extraction from an archive was perfect. Immutable provenance and pull-request
review keep that irreducible judgment auditable.

```agda
{-# OPTIONS --safe #-}

module Govenv.Consolidation where

open import Agda.Builtin.List using (List; []; _∷_)
open import Govenv.Consolidation.Baseline20260923 using (registered)
open import Govenv.Kernel.Consolidation using (DeclaredConsolidation)
open import Govenv.Roadmap using (roadmap)

declaredCorpora : List (DeclaredConsolidation roadmap)
declaredCorpora = registered ∷ []
```
