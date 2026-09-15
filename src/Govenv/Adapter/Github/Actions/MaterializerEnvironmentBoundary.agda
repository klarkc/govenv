module Govenv.Adapter.Github.Actions.MaterializerEnvironmentBoundary where

open import Agda.Builtin.IO
open import Agda.Builtin.Unit
open import Govenv.Adapter.Github.Actions.Environment using
  (applyEnvironmentBoundary)
open import Govenv.Projection.Github.Actions.MaterializerEnvironment using (plan)

main : IO ⊤
main = applyEnvironmentBoundary plan
