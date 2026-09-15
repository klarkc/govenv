module Govenv.Adapter.Github.Repository.MaterializerCredential where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Administration using
  (materializerCredentialName; materializerEnvironment)
open import Govenv.Projection.Github.Repository.MaterializerDeployKeys using
  (materializerReadOnly; materializerTitle)

postulate
  provisionMaterializerCredentialRaw :
    String → String → String → String → IO ⊤

{-# FOREIGN GHC
import qualified Control.Exception as Exception
import qualified Control.Monad as Monad
import qualified Data.List as List
import qualified Data.Text as Text
import qualified Data.Text.IO as TextIO
import qualified System.Directory as Directory
import qualified System.Environment as Environment
import qualified System.Exit as Exit
import qualified System.FilePath as FilePath
import qualified System.Process as Process

runCommandWithInput :: Text.Text -> String -> [Text.Text] -> IO Text.Text
runCommandWithInput input command arguments = do
  (code, stdoutText, stderrText) <-
    Process.readProcessWithExitCode
      command
      (map Text.unpack arguments)
      (Text.unpack input)
  case code of
    Exit.ExitSuccess -> pure (Text.strip (Text.pack stdoutText))
    _ -> Exit.die
      ("Administrative credential command failed: " ++ command ++
       " " ++ unwords (map Text.unpack arguments) ++
       "\n" ++ stderrText)

runGhWithInput :: Text.Text -> [Text.Text] -> IO Text.Text
runGhWithInput input = runCommandWithInput input "gh"

runGh :: [Text.Text] -> IO Text.Text
runGh = runGhWithInput Text.empty

observedLines :: Text.Text -> [Text.Text]
observedLines =
  List.sort .
  filter (not . Text.null) .
  map Text.strip .
  Text.lines

publicKeyIdentity :: Text.Text -> Text.Text
publicKeyIdentity = Text.unwords . take 2 . Text.words

normalizeDeployKeyObservation :: Text.Text -> Text.Text
normalizeDeployKeyObservation line =
  case Text.splitOn "\t" line of
    [observedTitle, observedReadOnly, observedKey] ->
      observedTitle <> "\t" <> observedReadOnly <> "\t" <>
      publicKeyIdentity observedKey
    _ -> line

removeIfPresent :: FilePath -> IO ()
removeIfPresent path = do
  exists <- Directory.doesFileExist path
  if exists then Directory.removeFile path else pure ()

provisionMaterializerCredentialImpl
  :: Text.Text
  -> Text.Text
  -> Text.Text
  -> Text.Text
  -> IO ()
provisionMaterializerCredentialImpl
  title readOnly environmentName secretName = do
    repository <- Text.pack <$> Environment.getEnv "GITHUB_REPOSITORY"
    runId <- Environment.lookupEnv "GITHUB_RUN_ID"
    temporaryDirectory <- Directory.getTemporaryDirectory
    let suffix = maybe "local" id runId
        privatePath = temporaryDirectory FilePath.</> ("govenv-materializer-" ++ suffix)
        publicPath = privatePath ++ ".pub"
        cleanup = removeIfPresent privatePath >> removeIfPresent publicPath
        keyEndpoint = "repos/" <> repository <> "/keys"

    cleanup
    (do
      _ <- runCommandWithInput Text.empty "ssh-keygen"
        ["-q", "-t", "ed25519", "-N", "", "-C", title, "-f", Text.pack privatePath]
      privateKey <- TextIO.readFile privatePath
      publicKey <- Text.strip <$> TextIO.readFile publicPath

      currentIds <- runGh
        ["api", keyEndpoint, "--paginate", "--jq", ".[].id"]
      Monad.forM_ (observedLines currentIds) $ \keyId -> do
        _ <- runGh
          ["api", "--method", "DELETE", keyEndpoint <> "/" <> keyId]
        pure ()

      _ <- runGh
        [ "api", "--method", "POST", keyEndpoint
        , "--raw-field", "title=" <> title
        , "--raw-field", "key=" <> publicKey
        , "--field", "read_only=" <> readOnly
        ]

      _ <- runGhWithInput privateKey
        [ "secret", "set", secretName
        , "--env", environmentName
        , "--repo", repository
        ]

      observed <- runGh
        [ "api", keyEndpoint, "--paginate", "--jq"
        , ".[] | [.title, (.read_only|tostring), .key] | @tsv"
        ]
      let expected =
            [title <> "\t" <> readOnly <> "\t" <> publicKeyIdentity publicKey]
          observedNormalized =
            List.sort (map normalizeDeployKeyObservation (observedLines observed))
      if observedNormalized == List.sort expected
        then pure ()
        else Exit.die
          ("Materializer deploy-key read-back verification failed.\n" ++
           "Expected: " ++ show (map Text.unpack expected) ++
           "\nObserved: " ++ show (map Text.unpack observedNormalized)))
      `Exception.finally` cleanup
#-}

{-# COMPILE GHC provisionMaterializerCredentialRaw =
  provisionMaterializerCredentialImpl #-}

main : IO ⊤
main = provisionMaterializerCredentialRaw
  materializerTitle
  materializerReadOnly
  materializerEnvironment
  materializerCredentialName
