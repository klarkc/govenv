module Govenv.Adapter.Github.Workflows.Materialize where

open import Agda.Builtin.IO
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit
open import Govenv.Projection.Github.Workflows.Materialize using (render)

postulate
  putStr : String → IO ⊤

{-# FOREIGN GHC import qualified Data.Text.IO as Text #-}
{-# COMPILE GHC putStr = Text.putStr #-}

main : IO ⊤
main = putStr render
