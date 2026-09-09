{-# OPTIONS --safe #-}

module Govenv.Roadmap.DSL where

open import Govenv.Kernel.Identifier public using (P; GV; GVR)
open import Govenv.Kernel.Roadmap public using
  (Roadmap; _■; _▣; _□; _✓; _◇; _×; _↪_; _├_; _┬_; _╟_; roadmapOf)
