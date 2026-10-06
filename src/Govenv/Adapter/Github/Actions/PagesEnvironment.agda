module Govenv.Adapter.Github.Actions.PagesEnvironment where

open import Agda.Builtin.IO
open import Agda.Builtin.Unit
open import Govenv.Adapter.Github.Actions.Environment using (applyEnvironment)
open import Govenv.Projection.Github.Actions.PagesEnvironment using (plan)

main : IO ⊤
main = applyEnvironment plan
