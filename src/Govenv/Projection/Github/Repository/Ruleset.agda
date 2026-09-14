{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.Ruleset where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using
  (String; primShowNat; primShowString; primStringAppend)
open import Govenv.Materialization.Github.Repository.Ruleset
open import Govenv.Materialization.Github.Repository.MainAuthorization
  using (MainAuthorizationRuleset; mainAuthorizationRuleset)
open import Govenv.Materialization.Github.Repository.MainAuthorityBoundary
  using (MainAuthorityBoundaryRuleset; mainAuthorityBoundaryRuleset)
open import Govenv.Materialization.Github.Repository.MainIntegrity
  using (MainIntegrityRuleset; mainIntegrityRuleset)

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

data GithubAppResolution (slug : String) : Set where
  resolvedGithubApp : Nat → GithubAppResolution slug
  unresolvedGithubApp : GithubAppResolution slug

data GithubUserResolution (login : String) : Set where
  resolvedGithubUser : Nat → GithubUserResolution login
  unresolvedGithubUser : GithubUserResolution login

data StatusCheckResolutions : List RequiredStatusCheck → Set where
  noStatusChecks : StatusCheckResolutions []
  resolvedStatusCheck :
    {check : RequiredStatusCheck} {rest : List RequiredStatusCheck} →
    GithubAppResolution (RequiredStatusCheck.sourceApp check) →
    StatusCheckResolutions rest →
    StatusCheckResolutions (check ∷ rest)

record AuthorizationResolution (ruleset : MainAuthorizationRuleset) : Set where
  constructor authorizationResolution
  field
    bypassApp :
      GithubAppResolution
        (GithubAppBypass.slug (MainAuthorizationRuleset.bypass ruleset))
    statusApps :
      StatusCheckResolutions
        (StatusChecksRequirement.checks
          (MainAuthorizationRuleset.statusChecks ruleset))

record AuthorityBoundaryResolution
  (ruleset : MainAuthorityBoundaryRuleset) : Set where
  constructor authorityBoundaryResolution
  field
    human :
      GithubUserResolution
        (GithubUserBypass.login
          (MainAuthorityBoundaryRuleset.humanBypass ruleset))
    materializer :
      GithubAppResolution
        (GithubAppBypass.slug
          (MainAuthorityBoundaryRuleset.materializerBypass ruleset))

appPlaceholder : String → String
appPlaceholder slug = "@github-app-id:" ++ slug

userPlaceholder : String → String
userPlaceholder login = "@github-user-id:" ++ login

renderAppResolution :
  {slug : String} → GithubAppResolution slug → String
renderAppResolution (resolvedGithubApp integrationId) = primShowNat integrationId
renderAppResolution {slug} unresolvedGithubApp = primShowString (appPlaceholder slug)

renderUserResolution :
  {login : String} → GithubUserResolution login → String
renderUserResolution (resolvedGithubUser userId) = primShowNat userId
renderUserResolution {login} unresolvedGithubUser = primShowString (userPlaceholder login)

unresolvedStatusChecks :
  (checks : List RequiredStatusCheck) → StatusCheckResolutions checks
unresolvedStatusChecks [] = noStatusChecks
unresolvedStatusChecks (check ∷ rest) =
  resolvedStatusCheck unresolvedGithubApp (unresolvedStatusChecks rest)

renderBool : Bool → String
renderBool true = "true"
renderBool false = "false"

renderEnforcement : Enforcement → String
renderEnforcement active = "active"

renderTarget : BranchTarget → String
renderTarget defaultBranch = "~DEFAULT_BRANCH"

renderBypassMode : BypassMode → String
renderBypassMode always = "always"
renderBypassMode pullRequestOnly = "pull_request"

renderMergeMethod : MergeMethod → String
renderMergeMethod rebase = primShowString "rebase"

renderMergeMethodsTail : List MergeMethod → String
renderMergeMethodsTail [] = ""
renderMergeMethodsTail (method ∷ rest) =
  "," ++ renderMergeMethod method ++ renderMergeMethodsTail rest

renderMergeMethods : List MergeMethod → String
renderMergeMethods [] = "[]"
renderMergeMethods (method ∷ rest) =
  "[" ++ renderMergeMethod method ++ renderMergeMethodsTail rest ++ "]"

renderPullRequest : PullRequestRequirement → String
renderPullRequest
  (pullRequestRequirement methods stale codeOwner lastPush approvals threads) =
  "{\"type\":\"pull_request\",\"parameters\":{" ++
  "\"allowed_merge_methods\":" ++ renderMergeMethods methods ++ "," ++
  "\"dismiss_stale_reviews_on_push\":" ++ renderBool stale ++ "," ++
  "\"require_code_owner_review\":" ++ renderBool codeOwner ++ "," ++
  "\"require_last_push_approval\":" ++ renderBool lastPush ++ "," ++
  "\"required_approving_review_count\":" ++ primShowNat approvals ++ "," ++
  "\"required_review_thread_resolution\":" ++ renderBool threads ++
  "}}"

renderConditions : BranchTarget → String
renderConditions target =
  "{\"ref_name\":{\"include\":[" ++ primShowString (renderTarget target) ++
  "],\"exclude\":[]}}"

renderStatusCheck :
  (check : RequiredStatusCheck) →
  GithubAppResolution (RequiredStatusCheck.sourceApp check) → String
renderStatusCheck (requiredStatusCheck context sourceApp) resolution =
  "{\"context\":" ++ primShowString context ++
  ",\"integration_id\":" ++
  renderAppResolution resolution ++ "}"

renderStatusCheckList :
  (checks : List RequiredStatusCheck) → StatusCheckResolutions checks → String
renderStatusCheckList [] noStatusChecks = "[]"
renderStatusCheckList (check ∷ rest)
  (resolvedStatusCheck resolution resolutions) =
  "[" ++ renderStatusCheck check resolution ++
  renderStatusCheckTail rest resolutions ++ "]"
  where
  renderStatusCheckTail :
    (remaining : List RequiredStatusCheck) →
    StatusCheckResolutions remaining → String
  renderStatusCheckTail [] noStatusChecks = ""
  renderStatusCheckTail (next ∷ remaining)
    (resolvedStatusCheck nextResolution nextResolutions) =
    "," ++ renderStatusCheck next nextResolution ++
    renderStatusCheckTail remaining nextResolutions

renderStatusChecks :
  (requirement : StatusChecksRequirement) →
  StatusCheckResolutions (StatusChecksRequirement.checks requirement) → String
renderStatusChecks
  (statusChecksRequirement checks strict doNotEnforceOnCreate) resolutions =
  "{\"type\":\"required_status_checks\",\"parameters\":{" ++
  "\"required_status_checks\":" ++ renderStatusCheckList checks resolutions ++ "," ++
  "\"strict_required_status_checks_policy\":" ++ renderBool strict ++ "," ++
  "\"do_not_enforce_on_create\":" ++ renderBool doNotEnforceOnCreate ++
  "}}"

renderAuthorizationRuleset :
  (ruleset : MainAuthorizationRuleset) → AuthorizationResolution ruleset → String
renderAuthorizationRuleset
  (mainAuthorizationRuleset name enforcement target bypass pullRequest statusChecks)
  (authorizationResolution bypassResolution statusResolutions) =
  "{" ++
  "\"name\":" ++ primShowString name ++ "," ++
  "\"target\":\"branch\"," ++
  "\"enforcement\":" ++ primShowString (renderEnforcement enforcement) ++ "," ++
  "\"bypass_actors\":[{" ++
    "\"actor_id\":" ++
      renderAppResolution bypassResolution ++ "," ++
    "\"actor_type\":\"Integration\"," ++
    "\"bypass_mode\":" ++
      primShowString (renderBypassMode (GithubAppBypass.mode bypass)) ++
  "}]," ++
  "\"conditions\":" ++ renderConditions target ++ "," ++
  "\"rules\":[" ++ renderPullRequest pullRequest ++ "," ++
  renderStatusChecks statusChecks statusResolutions ++ "]" ++
  "}"

renderIntegrityRules : Bool → Bool → String
renderIntegrityRules false false = "[]"
renderIntegrityRules true false = "[{\"type\":\"deletion\"}]"
renderIntegrityRules false true = "[{\"type\":\"non_fast_forward\"}]"
renderIntegrityRules true true =
  "[{\"type\":\"deletion\"},{\"type\":\"non_fast_forward\"}]"

renderIntegrityRuleset : MainIntegrityRuleset → String
renderIntegrityRuleset
  (mainIntegrityRuleset name enforcement target deletion forcePush) =
  "{" ++
  "\"name\":" ++ primShowString name ++ "," ++
  "\"target\":\"branch\"," ++
  "\"enforcement\":" ++ primShowString (renderEnforcement enforcement) ++ "," ++
  "\"bypass_actors\":[]," ++
  "\"conditions\":" ++ renderConditions target ++ "," ++
  "\"rules\":" ++ renderIntegrityRules deletion forcePush ++
  "}"

renderUpdateRestriction : UpdateRestriction → String
renderUpdateRestriction (updateRestriction allowFetchAndMerge) =
  "{\"type\":\"update\",\"parameters\":{" ++
  "\"update_allows_fetch_and_merge\":" ++ renderBool allowFetchAndMerge ++
  "}}"

renderAuthorityBoundaryRuleset :
  (ruleset : MainAuthorityBoundaryRuleset) →
  AuthorityBoundaryResolution ruleset → String
renderAuthorityBoundaryRuleset
  (mainAuthorityBoundaryRuleset name enforcement target humanBypass appBypass update)
  (authorityBoundaryResolution humanResolution appResolution) =
  "{" ++
  "\"name\":" ++ primShowString name ++ "," ++
  "\"target\":\"branch\"," ++
  "\"enforcement\":" ++ primShowString (renderEnforcement enforcement) ++ "," ++
  "\"bypass_actors\":[{" ++
  "\"actor_id\":" ++
    renderUserResolution humanResolution ++ "," ++
  "\"actor_type\":\"User\"," ++
  "\"bypass_mode\":" ++
    primShowString (renderBypassMode (GithubUserBypass.mode humanBypass)) ++
  "},{" ++
  "\"actor_id\":" ++
    renderAppResolution appResolution ++ "," ++
  "\"actor_type\":\"Integration\"," ++
  "\"bypass_mode\":" ++
    primShowString (renderBypassMode (GithubAppBypass.mode appBypass)) ++
  "}]," ++
  "\"conditions\":" ++ renderConditions target ++ "," ++
  "\"rules\":[" ++ renderUpdateRestriction update ++ "]" ++
  "}"

record RulesetProjection : Set where
  constructor rulesetProjection
  field
    name : String
    requestTemplate : String
    identityRequests : List String

appRequest : String → String
appRequest slug = "app:" ++ slug

userRequest : String → String
userRequest login = "user:" ++ login

authorizationProjection :
  (ruleset : MainAuthorizationRuleset) → RulesetProjection
authorizationProjection ruleset = rulesetProjection
  (MainAuthorizationRuleset.name ruleset)
  (renderAuthorizationRuleset ruleset
    (authorizationResolution
      unresolvedGithubApp
      (unresolvedStatusChecks
        (StatusChecksRequirement.checks
          (MainAuthorizationRuleset.statusChecks ruleset)))))
  (appRequest
      (GithubAppBypass.slug (MainAuthorizationRuleset.bypass ruleset))
    ∷ statusRequests
      (StatusChecksRequirement.checks
        (MainAuthorizationRuleset.statusChecks ruleset)))
  where
  statusRequests : List RequiredStatusCheck → List String
  statusRequests [] = []
  statusRequests (check ∷ rest) =
    appRequest (RequiredStatusCheck.sourceApp check) ∷ statusRequests rest

authorityBoundaryProjection :
  (ruleset : MainAuthorityBoundaryRuleset) → RulesetProjection
authorityBoundaryProjection ruleset = rulesetProjection
  (MainAuthorityBoundaryRuleset.name ruleset)
  (renderAuthorityBoundaryRuleset ruleset
    (authorityBoundaryResolution unresolvedGithubUser unresolvedGithubApp))
  (userRequest
      (GithubUserBypass.login (MainAuthorityBoundaryRuleset.humanBypass ruleset))
    ∷ appRequest
      (GithubAppBypass.slug
        (MainAuthorityBoundaryRuleset.materializerBypass ruleset))
    ∷ [])

integrityProjection : MainIntegrityRuleset → RulesetProjection
integrityProjection ruleset = rulesetProjection
  (MainIntegrityRuleset.name ruleset)
  (renderIntegrityRuleset ruleset)
  []
