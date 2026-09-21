{-# OPTIONS --safe #-}

module Govenv.Experiment.ConstitutionalHistory where

-- Constitutional-history redesign experiment.
--
-- This namespace is intentionally experimental and is not part of the reusable
-- Govenv kernel. It compares three implementations before any kernel migration:
--
--   Baseline       behavioral reference with bespoke Bool/list machinery.
--   Stdlib         the same behavior rebuilt from Agda stdlib primitives.
--   Propositional  preferred direction: constitutional validity in Set,
--                  decision procedures in Dec, Bool only at executable edges.
--
-- Matching *Scenarios modules preserve the compile-time examples and
-- regressions used to compare the variants. EcosystemReuse records stdlib APIs
-- checked against the dependency pinned by the Govenv environment.
--
-- The experiment currently favors Propositional. Promotion into Kernel requires
-- a separate semantic decision; Kernel must never depend on Experiment.

data Variant : Set where
  baseline stdlib propositional : Variant

preferred : Variant
preferred = propositional
