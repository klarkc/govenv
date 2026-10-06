module Govenv.Adapter.Github.Repository.Ruleset where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.List using (List)
open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Projection.Github.Repository.Ruleset using (RulesetProjection)

postulate
  applyRulesetRaw : String → String → List String → IO ⊤

{-# FOREIGN GHC
import qualified Control.Monad as Monad
import qualified Data.List as List
import qualified Data.Text as Text
import qualified System.Environment as Environment
import qualified System.Exit as Exit
import qualified System.Process as Process

runProcessText :: String -> [Text.Text] -> Text.Text -> IO Text.Text
runProcessText executable arguments input = do
  (code, stdoutText, stderrText) <-
    Process.readProcessWithExitCode
      executable
      (map Text.unpack arguments)
      (Text.unpack input)
  case code of
    Exit.ExitSuccess -> pure (Text.strip (Text.pack stdoutText))
    _ -> Exit.die
      ("GitHub ruleset adapter command failed: " ++ executable ++ " " ++
       unwords (map Text.unpack arguments) ++
       "\n" ++ stderrText)

runGhRuleset :: [Text.Text] -> IO Text.Text
runGhRuleset arguments = runProcessText "gh" arguments Text.empty

runGhRulesetInput :: Text.Text -> [Text.Text] -> IO Text.Text
runGhRulesetInput input arguments = runProcessText "gh" arguments input

canonicalJson :: Text.Text -> IO Text.Text
canonicalJson = runProcessText "jq" ["-S", "-c", "."]

identityPlaceholder :: Text.Text -> Either String (Text.Text, Text.Text)
identityPlaceholder request
  | Just slug <- Text.stripPrefix "app:" request =
      Right ("@github-app-id:" <> slug, "apps/" <> slug)
  | Just login <- Text.stripPrefix "user:" request =
      Right ("@github-user-id:" <> login, "users/" <> login)
  | otherwise = Left ("Unsupported GitHub identity request: " ++ Text.unpack request)

resolveIdentity :: Text.Text -> Text.Text -> IO Text.Text
resolveIdentity template request =
  case identityPlaceholder request of
    Left message -> Exit.die message
    Right (placeholder, endpoint) -> do
      observedId <- runGhRuleset ["api", endpoint, "--jq", ".id"]
      if Text.null observedId || not (Text.all (`elem` ['0'..'9']) observedId)
        then Exit.die
          ("Invalid GitHub actor ID while resolving " ++ Text.unpack request ++
           ": " ++ Text.unpack observedId)
        else pure
          (Text.replace
            ("\"" <> placeholder <> "\"")
            observedId
            template)

resolveIdentities :: Text.Text -> [Text.Text] -> IO Text.Text
resolveIdentities = Monad.foldM resolveIdentity

parseRulesetEntry :: Text.Text -> Maybe (Text.Text, Text.Text)
parseRulesetEntry line =
  case Text.breakOn "\t" line of
    (identifier, rest)
      | not (Text.null identifier) && not (Text.null rest) ->
          Just (identifier, Text.drop 1 rest)
    _ -> Nothing

findRulesetIds :: Text.Text -> Text.Text -> IO [Text.Text]
findRulesetIds endpoint expectedName = do
  listing <- runGhRuleset
    ["api", endpoint, "--jq", ".[] | [.id, .name] | @tsv"]
  let entries = map parseRulesetEntry (filter (not . Text.null) (Text.lines listing))
  pure
    [ identifier
    | Just (identifier, name) <- entries
    , name == expectedName
    ]

readBackFilter :: Text.Text
readBackFilter =
  "{name:.name,target:.target,enforcement:.enforcement," <>
  "bypass_actors:[.bypass_actors[] | " <>
    "{actor_id:.actor_id,actor_type:.actor_type,bypass_mode:.bypass_mode}]," <>
  "conditions:{ref_name:{include:.conditions.ref_name.include," <>
    "exclude:.conditions.ref_name.exclude}}," <>
  "rules:[.rules[] | if has(\"parameters\") " <>
    "then {type:.type,parameters:.parameters} else {type:.type} end]}"

applyRulesetImpl :: Text.Text -> Text.Text -> [Text.Text] -> IO ()
applyRulesetImpl rulesetName requestTemplate identityRequests = do
  repository <- Text.pack <$> Environment.getEnv "GITHUB_REPOSITORY"
  let collectionEndpoint = "repos/" <> repository <> "/rulesets"

  request <- resolveIdentities requestTemplate identityRequests
  existingIds <- findRulesetIds collectionEndpoint rulesetName

  rulesetId <- case existingIds of
    [] -> runGhRulesetInput request
      [ "api", "--method", "POST", collectionEndpoint
      , "--input", "-", "--jq", ".id"
      ]
    [identifier] -> do
      _ <- runGhRulesetInput request
        [ "api", "--method", "PUT"
        , collectionEndpoint <> "/" <> identifier
        , "--input", "-"
        ]
      pure identifier
    _ -> Exit.die
      ("Multiple repository rulesets named " ++ Text.unpack rulesetName ++
       " exist; refusing ambiguous materialization.")

  let targetEndpoint = collectionEndpoint <> "/" <> rulesetId
  observed <- runGhRuleset
    ["api", targetEndpoint, "--jq", readBackFilter]
  expectedCanonical <- canonicalJson request
  observedCanonical <- canonicalJson observed

  if observedCanonical == expectedCanonical
    then pure ()
    else Exit.die
      ("Admin materialization verification failed for ruleset " ++
       Text.unpack rulesetName ++
       ".\nExpected: " ++ Text.unpack expectedCanonical ++
       "\nObserved: " ++ Text.unpack observedCanonical)
#-}

{-# COMPILE GHC applyRulesetRaw = applyRulesetImpl #-}

applyRuleset : RulesetProjection → IO ⊤
applyRuleset projection =
  applyRulesetRaw
    (RulesetProjection.name projection)
    (RulesetProjection.requestTemplate projection)
    (RulesetProjection.identityRequests projection)
