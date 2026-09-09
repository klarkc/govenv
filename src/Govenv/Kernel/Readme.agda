{-# OPTIONS --safe #-}

module Govenv.Kernel.Readme where

open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Roadmap using (Roadmap)

record Readme (PhaseId : Set) : Set where
  field
    docsUrl : String
    agdaVersion : String
    releaseUrl : String
    licenseName : String
    currentSummary : String
    roadmapNote : String
    roadmap : Roadmap PhaseId
    gettingStartedTitle : String
    bootstrapSummary : String
    bootstrapPin : String
    materializeTitle : String
    materializeCommand : String
    materializeSummary : String
    administrationTitle : String
    administrationUrl : String
    administrationSummary : String
    testTitle : String
    testCommand : String
    testSummary : String
    docsTitle : String
    docsCommand : String
    docsSummary : String
