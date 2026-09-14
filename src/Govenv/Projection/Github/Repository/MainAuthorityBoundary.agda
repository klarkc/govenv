{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.MainAuthorityBoundary where

open import Govenv.Materialization.Github.Repository.MainAuthorityBoundary using (state)
open import Govenv.Projection.Github.Repository.Ruleset using
  (RulesetProjection; authorityBoundaryProjection)

plan : RulesetProjection
plan = authorityBoundaryProjection state
