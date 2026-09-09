module Govenv.Adapter.RoadmapEvolution where

open import Agda.Builtin.IO
open import Agda.Builtin.List using ([])
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit
open import Govenv.Adapter.RoadmapEvolutionObservation
open import Govenv.Kernel.Release
open import Govenv.Projection.ReleaseGovernance using (renderError)
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
main with governanceDelta previous [] roadmap
... | validDelta delta = putStr ""
... | invalidDelta error = failWith (renderError error)
