{-# OPTIONS --safe #-}

module Govenv.Projection.Github.Repository.MainIntegrity where

open import Govenv.Materialization.Github.Repository.MainIntegrity using (state)
open import Govenv.Projection.Github.Repository.Ruleset using
  (RulesetProjection; integrityProjection)

plan : RulesetProjection
plan = integrityProjection state
