module Govenv.Adapter.Github.Repository.DescriptionApplication where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Projection.Github.Repository.Description using (renderDescription)

postulate
  applyDescription : String → IO ⊤

{-# FOREIGN GHC
import qualified Data.Text as Text
import qualified System.Environment as Environment
import qualified System.Exit as Exit
import qualified System.Process as Process

runGhDescription :: [Text.Text] -> IO Text.Text
runGhDescription arguments = do
  (code, stdoutText, stderrText) <-
    Process.readProcessWithExitCode
      "gh"
      (map Text.unpack arguments)
      ""
  case code of
    Exit.ExitSuccess -> pure (Text.strip (Text.pack stdoutText))
    _ -> Exit.die
      ("GitHub description adapter command failed: gh " ++
       unwords (map Text.unpack arguments) ++
       "\n" ++ stderrText)

applyDescriptionImpl :: Text.Text -> IO ()
applyDescriptionImpl expected = do
  repository <- Text.pack <$> Environment.getEnv "GITHUB_REPOSITORY"
  let endpoint = "repos/" <> repository
  _ <- runGhDescription
    ["api", "--method", "PATCH", endpoint, "--field", "description=" <> expected]
  observed <- runGhDescription
    ["api", endpoint, "--jq", ".description // \"\""]
  if observed == expected
    then pure ()
    else Exit.die
      ("Admin materialization verification failed for repository description.\n" ++
       "Expected: " ++ Text.unpack expected ++
       "\nObserved: " ++ Text.unpack observed)
#-}

{-# COMPILE GHC applyDescription = applyDescriptionImpl #-}

main : IO ⊤
main = applyDescription renderDescription
