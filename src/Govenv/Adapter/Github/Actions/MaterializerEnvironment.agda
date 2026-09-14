module Govenv.Adapter.Github.Actions.MaterializerEnvironment where

open import Agda.Builtin.IO
open import Agda.Builtin.Unit
open import Govenv.Adapter.Github.Actions.Environment using (applyEnvironment)
open import Govenv.Projection.Github.Actions.MaterializerEnvironment using (plan)

main : IO ⊤
main = applyEnvironment plan
