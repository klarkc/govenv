{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.MainAuthorization where

open import Govenv.Materialization.Github.Repository.MainAuthorization using (state)
open import Govenv.Projection.Github.Repository.Ruleset using
  (RulesetProjection; authorizationProjection)

plan : RulesetProjection
plan = authorizationProjection state
