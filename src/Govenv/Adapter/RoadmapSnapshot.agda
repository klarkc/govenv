module Govenv.Adapter.RoadmapSnapshot where

open import Agda.Builtin.IO
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit
open import Govenv.Projection.RoadmapSnapshot using (renderSnapshot)

postulate
  putStr : String → IO ⊤

{-# FOREIGN GHC import qualified Data.Text.IO as Text #-}
{-# COMPILE GHC putStr = Text.putStr #-}

main : IO ⊤
main = putStr renderSnapshot
