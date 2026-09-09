# README materialization

This module is the canonical semantic definition of the repository `README.md`. It owns content, structure, ordering, inclusion, application, privilege, and verification; projection owns only target-format representation.

```agda
{-# OPTIONS --safe #-}

module Govenv.Materialization.Readme where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.String using (String; primStringAppend)
open import Govenv.Kernel.Identifier using (SomePhaseId; someIdentifier)
open import Govenv.Kernel.Readme
open Readme
open import Govenv.Kernel.Roadmap using (Roadmap; progressing; complete; phaseNode)
open import Govenv.Materialization
open import Govenv.Project using (name; description)
open import Govenv.Readme using (readme)

private
  infixr 5 _++_

  _++_ : String → String → String
  _++_ = primStringAppend

data HeadingLevel : Set where
  title section subsection : HeadingLevel

data Alignment : Set where
  normal centered : Alignment

data Inline : Set where
  text strong code : String → Inline
  link : String → String → Inline

record Badge : Set where
  constructor badge
  field
    imageUrl : String
    alt : String
    targetUrl : Maybe String

data Current : Set where
  activeCurrent : String → SomePhaseId → String → Current
  roadmapComplete : String → String → Current

data Block : Set where
  comment : String → Block
  heading : HeadingLevel → Alignment → String → Block
  paragraph : Alignment → List Inline → Block
  badges : List Badge → Block
  current : Current → Block
  blockQuote : String → Block
  roadmapTree : Roadmap → Block
  codeBlock : String → String → Block

Document : Set
Document = List Block

currentOf : String → Roadmap → Current
currentOf summary (progressing _ (phaseNode phaseId _) _) =
  activeCurrent "Current" (someIdentifier phaseId) summary
currentOf summary (complete _) =
  roadmapComplete "Current" "Roadmap complete."

materialization : Materialization Document
materialization = materialized
  (repositoryFile "README.md")
  versionedApplication
  versionedPrivilege
  trackedEquality
  ( comment "Generated from Govenv.Materialization.Readme. Do not edit manually."
  ∷ heading title centered name
  ∷ paragraph centered (strong description ∷ [])
  ∷ badges
      ( badge "https://img.shields.io/badge/docs-pages-brightgreen" "Docs" (just (docsUrl readme))
      ∷ badge ("https://img.shields.io/badge/agda-" ++ agdaVersion readme ++ "-blueviolet") ("Agda " ++ agdaVersion readme) nothing
      ∷ badge "https://img.shields.io/github/v/release/klarkc/govenv?display_name=tag&sort=semver" "Release" (just (releaseUrl readme))
      ∷ badge "https://img.shields.io/badge/license-Apache--2.0-blue" (licenseName readme) nothing
      ∷ [] )
  ∷ heading section normal "Roadmap"
  ∷ current (currentOf (currentSummary readme) (roadmap readme))
  ∷ blockQuote (roadmapNote readme)
  ∷ roadmapTree (roadmap readme)
  ∷ heading section normal (gettingStartedTitle readme)
  ∷ paragraph normal (text (bootstrapSummary readme) ∷ [])
  ∷ paragraph normal (text (bootstrapPin readme) ∷ [])
  ∷ heading subsection normal (materializeTitle readme)
  ∷ paragraph normal (text "Materialize governed repository artifacts with:" ∷ [])
  ∷ codeBlock "bash" (materializeCommand readme)
  ∷ paragraph normal (text (materializeSummary readme) ∷ [])
  ∷ heading subsection normal (administrationTitle readme)
  ∷ paragraph normal
      ( text (administrationSummary readme)
      ∷ text " "
      ∷ link "Read the governed setup guide" (administrationUrl readme)
      ∷ text "."
      ∷ [] )
  ∷ heading subsection normal (testTitle readme)
  ∷ paragraph normal (text "Run the test suite with the pinned devenv tag:" ∷ [])
  ∷ codeBlock "bash" (testCommand readme)
  ∷ paragraph normal (text (testSummary readme) ∷ [])
  ∷ heading subsection normal (docsTitle readme)
  ∷ paragraph normal (text "Build the literate Agda documentation locally with:" ∷ [])
  ∷ codeBlock "bash" (docsCommand readme)
  ∷ paragraph normal (text (docsSummary readme) ∷ [])
  ∷ [] )
```
