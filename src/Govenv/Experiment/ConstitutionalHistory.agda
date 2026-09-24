{-# OPTIONS --safe #-}

module Govenv.Experiment.ConstitutionalHistory where

-- Historical constitutional-history design experiments.
--
-- Baseline preserves the original bespoke Bool/list model. Stdlib rebuilds
-- that behavior with the pinned Agda standard library. Their scenarios remain
-- as design archaeology and regression references rather than constitutional
-- authority.
--
-- The proposition-first variant graduated from Experiment into
-- Govenv.Kernel.Constitution under GV116. Its authoritative scenarios now live
-- in Govenv.Assurance.GV116. Kernel must never depend on this Experiment
-- namespace.

data HistoricalVariant : Set where
  baseline stdlib : HistoricalVariant
