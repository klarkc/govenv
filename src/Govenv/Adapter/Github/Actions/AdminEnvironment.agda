module Govenv.Adapter.Github.Actions.AdminEnvironment where

open import Agda.Builtin.IO
open import Agda.Builtin.Unit
open import Govenv.Adapter.Github.Actions.Environment using (applyEnvironment)
open import Govenv.Projection.Github.Actions.AdminEnvironment using (plan)

main : IO ⊤
main = applyEnvironment plan
