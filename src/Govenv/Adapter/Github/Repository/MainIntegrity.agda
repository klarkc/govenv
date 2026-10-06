module Govenv.Adapter.Github.Repository.MainIntegrity where

open import Agda.Builtin.IO
open import Agda.Builtin.Unit
open import Govenv.Adapter.Github.Repository.Ruleset using (applyRuleset)
open import Govenv.Projection.Github.Repository.MainIntegrity using (plan)

main : IO ⊤
main = applyRuleset plan
