module Govenv.Adapter.Agents where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Projection.Agents using (renderAgents)

postulate
  putStr : String → IO ⊤

{-# FOREIGN GHC import qualified Data.Text.IO as Text #-}
{-# COMPILE GHC putStr = Text.putStr #-}

main : IO ⊤
main = putStr renderAgents
