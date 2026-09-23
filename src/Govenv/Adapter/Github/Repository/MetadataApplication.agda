module Govenv.Adapter.Github.Repository.MetadataApplication where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Projection.Github.Repository.Description using (renderDescription)
open import Govenv.Projection.Github.Repository.Topics using (renderTopics)
open import Govenv.Projection.Github.Repository.Website using (renderWebsite)

postulate
  applyRepositoryMetadata : String → String → List String → IO ⊤

{-# FOREIGN GHC
import qualified Data.List as List
import qualified Data.Text as Text
import qualified System.Environment as Environment
import qualified System.Exit as Exit
import qualified System.Process as Process

runGh :: [Text.Text] -> IO Text.Text
runGh arguments = do
  (code, stdoutText, stderrText) <-
    Process.readProcessWithExitCode "gh" (map Text.unpack arguments) ""
  case code of
    Exit.ExitSuccess -> pure (Text.strip (Text.pack stdoutText))
    _ -> Exit.die
      ("GitHub repository metadata adapter command failed: gh " ++
       unwords (map Text.unpack arguments) ++ "\n" ++ stderrText)

applyRepositoryMetadataImpl :: Text.Text -> Text.Text -> [Text.Text] -> IO ()
applyRepositoryMetadataImpl expectedDescription expectedWebsite expectedTopics = do
  repository <- Text.pack <$> Environment.getEnv "GITHUB_REPOSITORY"
  let endpoint = "repos/" <> repository
  _ <- runGh
    [ "api", "--method", "PATCH", endpoint
    , "--field", "description=" <> expectedDescription
    , "--field", "homepage=" <> expectedWebsite
    ]
  let topicFields = concatMap (\topic -> ["--field", "names[]=" <> topic]) expectedTopics
  _ <- runGh (["api", "--method", "PUT", endpoint <> "/topics"] ++ topicFields)
  observedDescription <- runGh ["api", endpoint, "--jq", ".description // \"\""]
  observedWebsite <- runGh ["api", endpoint, "--jq", ".homepage // \"\""]
  observedTopicsText <- runGh ["api", endpoint <> "/topics", "--jq", ".names[]"]
  let observedTopics = filter (not . Text.null) (Text.lines observedTopicsText)
  if observedDescription /= expectedDescription
    then Exit.die "Repository metadata read-back verification failed for description."
    else if observedWebsite /= expectedWebsite
      then Exit.die "Repository metadata read-back verification failed for website."
      else if List.sort observedTopics /= List.sort expectedTopics
        then Exit.die "Repository metadata read-back verification failed for topics."
        else pure ()
#-}

{-# COMPILE GHC applyRepositoryMetadata = applyRepositoryMetadataImpl #-}

main : IO ⊤
main = applyRepositoryMetadata renderDescription renderWebsite renderTopics
