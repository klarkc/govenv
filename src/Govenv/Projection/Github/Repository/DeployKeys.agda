{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.DeployKeys where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using
  (String; primShowString; primStringAppend)
open import Govenv.Materialization.Github.Repository.DeployKeys

infixr 5 _++_

_++_ : String → String → String
_++_ = primStringAppend

renderBool : Bool → String
renderBool true = "true"
renderBool false = "false"

renderDeployKey : DeployKeyState → String
renderDeployKey (deployKeyState title writable) =
  "{\"title\":" ++ primShowString title ++
  ",\"writable\":" ++ renderBool writable ++ "}"

renderDeployKeyTail : List DeployKeyState → String
renderDeployKeyTail [] = ""
renderDeployKeyTail (key ∷ rest) =
  "," ++ renderDeployKey key ++ renderDeployKeyTail rest

renderDeployKeySet : DeployKeySet → String
renderDeployKeySet (deployKeySet []) = "[]"
renderDeployKeySet (deployKeySet (key ∷ rest)) =
  "[" ++ renderDeployKey key ++ renderDeployKeyTail rest ++ "]"
