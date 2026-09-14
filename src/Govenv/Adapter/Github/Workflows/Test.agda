module Govenv.Adapter.Github.Workflows.Test where

open import Agda.Builtin.IO
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit
open import Govenv.Projection.Github.Workflows.Test using (render)

postulate
  putStr : String → IO ⊤

{-# FOREIGN GHC import qualified Data.Text.IO as Text #-}
{-# COMPILE GHC putStr = Text.putStr #-}

main : IO ⊤
main = putStr render
