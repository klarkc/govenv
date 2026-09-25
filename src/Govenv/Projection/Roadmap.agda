{-# OPTIONS --safe #-}

module Govenv.Projection.Roadmap where

open import Agda.Builtin.Maybe using (Maybe)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.String using (String)
open import Govenv.Kernel.Constitution using
  ( Constitution
  ; GovernanceLifecycle
  ; GovernanceGlyph
  ; constitutionLifecycle
  ; constitutionGlyph
  ; constitutionSuccessor
  )
open import Govenv.Kernel.Identifier using
  ( GovernanceId; GovernanceRef; PhaseId; indexOf )
open import Govenv.Kernel.Roadmap using
  ( Membership; membership )

-- Transitional projection boundary for GV116.
--
-- Membership still carries legacy ItemState while the roadmap frontend is being
-- migrated. This projection intentionally discards that stored state. Once a
-- valid Constitution exists, lifecycle, glyph, and supersession lineage are
-- derived exclusively from append-only constitutional history.

record GovernanceView : Set where
  constructor governanceView
  field
    {idx} : Nat
    {contract} : String
    governanceId : GovernanceId idx contract
    lifecycle : GovernanceLifecycle
    glyph : GovernanceGlyph
    successor : Maybe GovernanceRef

projectGovernance :
  {idx : Nat} {contract : String} →
  Constitution →
  GovernanceId idx contract →
  GovernanceView
projectGovernance c governanceId =
  governanceView
    governanceId
    (constitutionLifecycle c (indexOf governanceId))
    (constitutionGlyph c (indexOf governanceId))
    (constitutionSuccessor c (indexOf governanceId))

projectMembership :
  {phaseIdx : Nat} {phaseDescription : String}
  {phase : PhaseId phaseIdx phaseDescription} →
  Constitution →
  Membership phase →
  GovernanceView
projectMembership c (membership governanceId _ _) =
  projectGovernance c governanceId
