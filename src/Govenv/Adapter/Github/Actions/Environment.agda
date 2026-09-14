module Govenv.Adapter.Github.Actions.Environment where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Projection.Github.Actions.Environment using (EnvironmentProjection)

postulate
  applyEnvironmentRaw :
    String → String → List String → List String → List String →
    List String → List String → IO ⊤

{-# FOREIGN GHC
import qualified Control.Monad as Monad
import qualified Data.List as List
import qualified Data.Text as Text
import qualified System.Environment as Environment
import qualified System.Exit as Exit
import qualified System.Process as Process

runGhWithInput :: Text.Text -> [Text.Text] -> IO Text.Text
runGhWithInput input arguments = do
  (code, stdoutText, stderrText) <-
    Process.readProcessWithExitCode
      "gh"
      (map Text.unpack arguments)
      (Text.unpack input)
  case code of
    Exit.ExitSuccess -> pure (Text.strip (Text.pack stdoutText))
    _ -> Exit.die
      ("GitHub adapter command failed: gh " ++
       unwords (map Text.unpack arguments) ++
       "\n" ++ stderrText)

runGh :: [Text.Text] -> IO Text.Text
runGh = runGhWithInput Text.empty

observedLines :: Text.Text -> [Text.Text]
observedLines =
  List.sort .
  filter (not . Text.null) .
  map Text.strip .
  Text.lines

verifyLines :: String -> [Text.Text] -> Text.Text -> IO ()
verifyLines label expected observed =
  let expectedSorted = List.sort expected
      observedSorted = observedLines observed
  in if expectedSorted == observedSorted
       then pure ()
       else Exit.die
         ("Admin materialization verification failed for " ++ label ++
          ".\nExpected: " ++ show (map Text.unpack expectedSorted) ++
          "\nObserved: " ++ show (map Text.unpack observedSorted))

applyEnvironmentImpl
  :: Text.Text
  -> Text.Text
  -> [Text.Text]
  -> [Text.Text]
  -> [Text.Text]
  -> [Text.Text]
  -> [Text.Text]
  -> IO ()
applyEnvironmentImpl
  environmentName
  request
  branchRequests
  expectedBoundary
  expectedBranches
  expectedSecrets
  expectedVariables = do
    repository <- Text.pack <$> Environment.getEnv "GITHUB_REPOSITORY"
    let endpoint =
          "repos/" <> repository <> "/environments/" <> environmentName
        branchEndpoint = endpoint <> "/deployment-branch-policies"

    _ <- runGhWithInput request
      ["api", "--method", "PUT", endpoint, "--input", "-"]

    currentPolicyIds <- runGh
      ["api", branchEndpoint, "--jq", ".branch_policies[].id"]
    Monad.forM_ (observedLines currentPolicyIds) $ \policyId -> do
      _ <- runGh
        ["api", "--method", "DELETE", branchEndpoint <> "/" <> policyId]
      pure ()

    Monad.forM_ branchRequests $ \branchRequest -> do
      _ <- runGhWithInput branchRequest
        ["api", "--method", "POST", branchEndpoint, "--input", "-"]
      pure ()

    boundary <- runGh
      [ "api", endpoint, "--jq"
      , ".deployment_branch_policy.protected_branches, " <>
        ".deployment_branch_policy.custom_branch_policies, " <>
        "([.protection_rules[] | select(.type == \"wait_timer\")] | length), " <>
        "([.protection_rules[] | select(.type == \"required_reviewers\")] | length)"
      ]
    verifyLines "environment boundary" expectedBoundary boundary

    branches <- runGh
      ["api", branchEndpoint, "--jq", ".branch_policies[].name"]
    verifyLines "deployment branch policies" expectedBranches branches

    secrets <- runGh
      ["api", endpoint <> "/secrets", "--jq", ".secrets[].name"]
    verifyLines "environment secret names" expectedSecrets secrets

    variables <- runGh
      ["api", endpoint <> "/variables", "--jq", ".variables[].name"]
    verifyLines "environment variable names" expectedVariables variables
#-}

{-# COMPILE GHC applyEnvironmentRaw = applyEnvironmentImpl #-}

applyEnvironment : EnvironmentProjection → IO ⊤
applyEnvironment projection =
  applyEnvironmentRaw
    (EnvironmentProjection.name projection)
    (EnvironmentProjection.request projection)
    (EnvironmentProjection.branchRequests projection)
    (EnvironmentProjection.boundaryObservation projection)
    (EnvironmentProjection.governedBranchNames projection)
    (EnvironmentProjection.governedSecretNames projection)
    (EnvironmentProjection.governedVariableNames projection)
