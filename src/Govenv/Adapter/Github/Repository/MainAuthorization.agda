module Govenv.Adapter.Github.Repository.MainAuthorization where

open import Agda.Builtin.IO
open import Agda.Builtin.Unit
open import Govenv.Adapter.Github.Repository.Ruleset using (applyRuleset)
open import Govenv.Projection.Github.Repository.MainAuthorization using (plan)

main : IO ⊤
main = applyRuleset plan
