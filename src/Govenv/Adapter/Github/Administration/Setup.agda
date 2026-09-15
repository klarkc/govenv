module Govenv.Adapter.Github.Administration.Setup where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Projection.Github.Administration.Setup using (steps)

postulate
  applySetupRaw : List String → IO ⊤

{-# FOREIGN GHC
import qualified Control.Monad as Monad
import qualified Data.Text as Text
import qualified System.Exit as Exit
import qualified System.Process as Process

runStep :: Text.Text -> IO ()
runStep adapter = do
  code <- Process.rawSystem (Text.unpack adapter) []
  case code of
    Exit.ExitSuccess -> pure ()
    Exit.ExitFailure status -> Exit.die
      ("Admin setup adapter failed: " ++ Text.unpack adapter ++
       " (exit " ++ show status ++ ")")

applySetupImpl :: [Text.Text] -> IO ()
applySetupImpl = Monad.mapM_ runStep
#-}

{-# COMPILE GHC applySetupRaw = applySetupImpl #-}

main : IO ⊤
main = applySetupRaw steps
