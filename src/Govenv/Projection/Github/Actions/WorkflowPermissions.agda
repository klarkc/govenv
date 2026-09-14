{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Actions.WorkflowPermissions where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.String using
  (String; primStringAppend)
open import Govenv.Materialization.Github.Actions.WorkflowPermissions

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderBool : Bool → String
renderBool true = "true"
renderBool false = "false"

renderDefaultPermission : DefaultWorkflowPermission → String
renderDefaultPermission readDefault = "read"

renderState : WorkflowPermissionsState → String
renderState (workflowPermissionsState defaultPermission allowPr) =
  "{\"default_workflow_permissions\":\"" ++
  renderDefaultPermission defaultPermission ++
  "\",\"can_approve_pull_request_reviews\":" ++ renderBool allowPr ++ "}"
