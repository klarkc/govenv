module Govenv.Adapter.ReleaseGovernance.Changelog where

open import Agda.Builtin.Bool using (true; false)
open import Agda.Builtin.IO
open import Agda.Builtin.Maybe using (just; nothing)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit
open import Govenv.Adapter.ReleaseObservation
open import Govenv.Kernel.Release
open import Govenv.Materialization.ReleaseGovernance using
  ( candidateBoundary; changelog; document; emptyUnreleased; releaseEntry
  ; releaseNotes; frozenCandidate; unreleased )
open import Govenv.Projection.ReleaseGovernance using
  (renderChangelogMaterialization; renderError)
open import Govenv.Roadmap using (roadmap)

postulate
  putStr : String → IO ⊤
  failWith : String → IO ⊤

{-# FOREIGN GHC import qualified Data.Text.IO as Text #-}
{-# FOREIGN GHC import qualified Data.Text as Text #-}
{-# FOREIGN GHC import qualified System.Exit as Exit #-}
{-# COMPILE GHC putStr = Text.putStr #-}
{-# COMPILE GHC failWith = \message -> Exit.die (Text.unpack message) #-}

main : IO ⊤
main with governanceDelta previous references roadmap
... | invalidDelta error = failWith (renderError error)
... | validDelta delta with candidateVersion | includeCurrentRelease
...   | nothing | false =
  putStr (renderChangelogMaterialization (changelog emptyUnreleased historicalEntries))
...   | nothing | true =
  putStr (renderChangelogMaterialization
    (changelog
      (unreleased
        (releaseEntry
          (document baseRevision headRevision roadmap delta)
          (releaseNotes conventionalCommits)))
      historicalEntries))
...   | just version | true =
  putStr (renderChangelogMaterialization
    (changelog
      (frozenCandidate
        (candidateBoundary version releaseHeading candidateBaseRef candidateAuthorizedRevision)
        (releaseEntry
          (document baseRevision headRevision roadmap delta)
          (releaseNotes conventionalCommits)))
      historicalEntries))
...   | just version | false = failWith "A frozen release candidate must contain a release document."
