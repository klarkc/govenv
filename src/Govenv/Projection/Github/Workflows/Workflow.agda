{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Workflows.Workflow where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using
  (String; primShowNat; primShowString; primStringAppend)
open import Govenv.Materialization.Github.Workflows.Workflow

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderBool : Bool → String
renderBool true = "true"
renderBool false = "false"

renderPermission : Permission → String
renderPermission none = ""
renderPermission read = "read"
renderPermission write = "write"

renderValue : Value → String
renderValue (literal value) = primShowString value
renderValue (expression value) = "${{ " ++ value ++ " }}"

renderMaybeId : Maybe String → String
renderMaybeId nothing = ""
renderMaybeId (just identifier) = "      id: " ++ identifier ++ "\n"

renderMaybeCondition : Maybe String → String
renderMaybeCondition nothing = ""
renderMaybeCondition (just condition) =
  "      if: ${{ " ++ condition ++ " }}\n"

renderBindings : String → List Binding → String
renderBindings indent [] = ""
renderBindings indent (binding key value ∷ rest) =
  indent ++ key ++ ": " ++ renderValue value ++ "\n" ++
  renderBindings indent rest

renderWith : List Binding → String
renderWith [] = ""
renderWith bindings =
  "      with:\n" ++ renderBindings "        " bindings

renderJobWith : List Binding → String
renderJobWith [] = ""
renderJobWith bindings =
  "    with:\n" ++ renderBindings "      " bindings

renderEnv : List Binding → String
renderEnv [] = ""
renderEnv bindings =
  "      env:\n" ++ renderBindings "        " bindings

renderActionPin : ActionPin → String
renderActionPin (actionPin repository revision versionLabel) =
  repository ++ "@" ++ revision ++ " # " ++ versionLabel


renderStep : Step → String
renderStep (usesStep name identifier condition action inputs) =
  "    - name: " ++ primShowString name ++ "\n" ++
  renderMaybeId identifier ++
  renderMaybeCondition condition ++
  "      uses: " ++ renderActionPin action ++ "\n" ++
  renderWith inputs
renderStep (runStep name identifier condition command environment) =
  "    - name: " ++ primShowString name ++ "\n" ++
  renderMaybeId identifier ++
  renderMaybeCondition condition ++
  "      run: " ++ primShowString command ++ "\n" ++
  renderEnv environment
renderSteps : List Step → String
renderSteps [] = ""
renderSteps (step ∷ rest) = renderStep step ++ renderSteps rest

renderPermissionLine : String → Permission → String
renderPermissionLine key none = ""
renderPermissionLine key level =
  "      " ++ key ++ ": " ++ renderPermission level ++ "\n"

renderTokenPermissions : WorkflowTokenCapabilities → String
renderTokenPermissions capabilities =
  "    permissions:\n" ++
  renderPermissionLine "actions" (WorkflowTokenCapabilities.actions capabilities) ++
  renderPermissionLine "contents" (WorkflowTokenCapabilities.contents capabilities) ++
  renderPermissionLine "issues" (WorkflowTokenCapabilities.issues capabilities) ++
  renderPermissionLine "pull-requests" (WorkflowTokenCapabilities.pullRequests capabilities) ++
  renderPermissionLine "pages" (WorkflowTokenCapabilities.pages capabilities) ++
  renderPermissionLine "id-token" (WorkflowTokenCapabilities.idToken capabilities)

renderEnvironmentGate :
  {source : SourceAuthority} → EnvironmentGate source → Maybe Value → String
renderEnvironmentGate ungatedCandidate nothing = ""
renderEnvironmentGate ungatedCandidate (just _) = ""
renderEnvironmentGate (authorizedEnvironment environment) nothing =
  "    environment: " ++ primShowString environment ++ "\n"
renderEnvironmentGate (authorizedEnvironment environment) (just url) =
  "    environment:\n" ++
  "      name: " ++ primShowString environment ++ "\n" ++
  "      url: " ++ renderValue url ++ "\n"

renderBranchesTail : List String → String
renderBranchesTail [] = ""
renderBranchesTail (branch ∷ rest) =
  ", " ++ primShowString branch ++ renderBranchesTail rest

renderBranches : List String → String
renderBranches [] = "[]"
renderBranches (branch ∷ rest) =
  "[" ++ primShowString branch ++ renderBranchesTail rest ++ "]"

renderDispatchOptions : List String → String
renderDispatchOptions [] = ""
renderDispatchOptions (option ∷ rest) =
  "          - " ++ primShowString option ++ "\n" ++ renderDispatchOptions rest

renderDispatchInput : DispatchInput → String
renderDispatchInput (choiceInput identifier description required options) =
  "      " ++ identifier ++ ":\n" ++
  "        description: " ++ primShowString description ++ "\n" ++
  "        required: " ++ renderBool required ++ "\n" ++
  "        type: choice\n" ++
  "        options:\n" ++ renderDispatchOptions options

renderDispatchInputs : List DispatchInput → String
renderDispatchInputs [] = ""
renderDispatchInputs inputs = "    inputs:\n" ++ go inputs
  where
  go : List DispatchInput → String
  go [] = ""
  go (input ∷ rest) = renderDispatchInput input ++ go rest

renderWorkflowCallInput : WorkflowCallInput → String
renderWorkflowCallInput (stringCallInput identifier required) =
  "      " ++ identifier ++ ":\n" ++
  "        required: " ++ renderBool required ++ "\n" ++
  "        type: string\n"

renderWorkflowCallInputs : List WorkflowCallInput → String
renderWorkflowCallInputs [] = ""
renderWorkflowCallInputs inputs = "    inputs:\n" ++ go inputs
  where
  go : List WorkflowCallInput → String
  go [] = ""
  go (input ∷ rest) = renderWorkflowCallInput input ++ go rest

renderTrigger : Trigger → String
renderTrigger (pushBranches branches) =
  "  push:\n    branches: " ++ renderBranches branches ++ "\n"
renderTrigger (workflowDispatch inputs) =
  "  workflow_dispatch:\n" ++ renderDispatchInputs inputs
renderTrigger (workflowCall inputs) =
  "  workflow_call:\n" ++ renderWorkflowCallInputs inputs
renderTrigger pullRequest = "  pull_request:\n"

renderTriggers : List Trigger → String
renderTriggers [] = ""
renderTriggers (trigger ∷ rest) = renderTrigger trigger ++ renderTriggers rest

renderSecurity : WorkflowSecurityProfile → Maybe Value → String
renderSecurity security environmentUrl =
  renderEnvironmentGate
    (WorkflowSecurityProfile.environmentGate security) environmentUrl ++
  renderTokenPermissions (WorkflowSecurityProfile.githubToken security)

renderJobCondition : Maybe String → String
renderJobCondition nothing = ""
renderJobCondition (just condition) =
  "    if: ${{ " ++ condition ++ " }}\n"

renderNeedsTail : List String → String
renderNeedsTail [] = ""
renderNeedsTail (identifier ∷ rest) =
  ", " ++ identifier ++ renderNeedsTail rest

renderNeeds : List String → String
renderNeeds [] = ""
renderNeeds (identifier ∷ []) = "    needs: " ++ identifier ++ "\n"
renderNeeds (identifier ∷ rest) =
  "    needs: [" ++ identifier ++ renderNeedsTail rest ++ "]\n"

renderJobOutputs : List Binding → String
renderJobOutputs [] = ""
renderJobOutputs outputs =
  "    outputs:\n" ++ renderBindings "      " outputs

renderJob : Job → String
renderJob
  (job identifier security condition needs outputs environmentUrl runner timeout steps) =
  "  " ++ identifier ++ ":\n" ++
  renderJobCondition condition ++
  renderNeeds needs ++
  renderJobOutputs outputs ++
  renderSecurity security environmentUrl ++
  "    runs-on: " ++ primShowString runner ++ "\n" ++
  "    timeout-minutes: " ++ primShowNat timeout ++ "\n" ++
  "    steps:\n" ++ renderSteps steps
renderJob
  (reusableJob identifier condition needs permissions workflowPath inputs) =
  "  " ++ identifier ++ ":\n" ++
  renderJobCondition condition ++
  renderNeeds needs ++
  renderTokenPermissions permissions ++
  "    uses: " ++ workflowPath ++ "\n" ++
  renderJobWith inputs

renderJobs : List Job → String
renderJobs [] = ""
renderJobs (current ∷ rest) = renderJob current ++ renderJobs rest

renderConcurrency : Concurrency → String
renderConcurrency (concurrency group cancelInProgress) =
  "concurrency:\n" ++
  "  group: " ++ primShowString group ++ "\n" ++
  "  cancel-in-progress: " ++ renderBool cancelInProgress ++ "\n"

renderMaybeConcurrency : Maybe Concurrency → String
renderMaybeConcurrency nothing = ""
renderMaybeConcurrency (just policy) = renderConcurrency policy ++ "\n"

renderWorkflow : Workflow → String
renderWorkflow (workflow name triggers concurrencyPolicy jobs) =
  "name: " ++ primShowString name ++ "\n\n" ++
  "on:\n" ++ renderTriggers triggers ++ "\n" ++
  renderMaybeConcurrency concurrencyPolicy ++
  "jobs:\n" ++ renderJobs jobs
