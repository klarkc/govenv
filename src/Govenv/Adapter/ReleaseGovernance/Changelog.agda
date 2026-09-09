module Govenv.Adapter.ReleaseGovernance.Changelog where

open import Agda.Builtin.IO
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit
open import Govenv.Adapter.ReleaseObservation
open import Govenv.Kernel.Release
open import Govenv.Materialization.ReleaseGovernance using (changelog)
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
... | validDelta delta =
  putStr (renderChangelogMaterialization
    (changelog releasePullRequest baseRevision headRevision delta))
... | invalidDelta error = failWith (renderError error)
