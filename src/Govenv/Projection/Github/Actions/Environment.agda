{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Actions.Environment where

open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using
  (String; primShowString; primStringAppend)
open import Govenv.Materialization.Github.Actions.Environment

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderReviewPolicy : DeploymentReviewPolicy → String
renderReviewPolicy noDeploymentReview =
  "\"wait_timer\":0," ++
  "\"prevent_self_review\":false," ++
  "\"reviewers\":[]"

renderBranchPolicyMode : DeploymentBranchPolicy → String
renderBranchPolicyMode (customBranches branches) =
  "{\"protected_branches\":false," ++
  "\"custom_branch_policies\":true}"

renderEnvironmentRequest : EnvironmentBoundaryState → String
renderEnvironmentRequest
  (environmentBoundaryState name branchPolicy reviewPolicy secrets variables) =
  "{" ++ renderReviewPolicy reviewPolicy ++ "," ++
  "\"deployment_branch_policy\":" ++ renderBranchPolicyMode branchPolicy ++
  "}"

renderBranchRequest : String → String
renderBranchRequest branch =
  "{\"name\":" ++ primShowString branch ++ ",\"type\":\"branch\"}"

renderBranchRequests : DeploymentBranchPolicy → List String
renderBranchRequests (customBranches []) = []
renderBranchRequests (customBranches (branch ∷ rest)) =
  renderBranchRequest branch ∷ renderBranchRequests (customBranches rest)

credentialSecrets : EnvironmentBoundaryState → List String
credentialSecrets
  (environmentBoundaryState name branchPolicy reviewPolicy secrets variables) =
  secrets

credentialVariables : EnvironmentBoundaryState → List String
credentialVariables
  (environmentBoundaryState name branchPolicy reviewPolicy secrets variables) =
  variables

branchNames : DeploymentBranchPolicy → List String
branchNames (customBranches branches) = branches

renderStringsTail : List String → String
renderStringsTail [] = ""
renderStringsTail (value ∷ rest) =
  "," ++ primShowString value ++ renderStringsTail rest

renderStrings : List String → String
renderStrings [] = "[]"
renderStrings (value ∷ rest) =
  "[" ++ primShowString value ++ renderStringsTail rest ++ "]"

renderBranchRequestsTail : List String → String
renderBranchRequestsTail [] = ""
renderBranchRequestsTail (request ∷ rest) =
  "," ++ request ++ renderBranchRequestsTail rest

renderBranchRequestArray : DeploymentBranchPolicy → String
renderBranchRequestArray policy with renderBranchRequests policy
... | [] = "[]"
... | request ∷ rest =
  "[" ++ request ++ renderBranchRequestsTail rest ++ "]"

renderEnvironmentPlan : EnvironmentBoundaryState → String
renderEnvironmentPlan state =
  "{" ++
  "\"environment\":" ++ renderEnvironmentRequest state ++ "," ++
  "\"branch_policies\":" ++
    renderBranchRequestArray (EnvironmentBoundaryState.branchPolicy state) ++ "," ++
  "\"secret_names\":" ++ renderStrings (credentialSecrets state) ++ "," ++
  "\"variable_names\":" ++ renderStrings (credentialVariables state) ++
  "}"

record EnvironmentProjection : Set where
  constructor environmentProjection
  field
    name : String
    request : String
    branchRequests : List String
    governedBranchNames : List String
    governedSecretNames : List String
    governedVariableNames : List String
    boundaryObservation : List String

projectEnvironment : EnvironmentBoundaryState → EnvironmentProjection
projectEnvironment state = environmentProjection
  (EnvironmentBoundaryState.name state)
  (renderEnvironmentRequest state)
  (renderBranchRequests (EnvironmentBoundaryState.branchPolicy state))
  (branchNames (EnvironmentBoundaryState.branchPolicy state))
  (credentialSecrets state)
  (credentialVariables state)
  ("false" ∷ "true" ∷ "0" ∷ "0" ∷ [])
