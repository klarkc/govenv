# GV116 constitutional release-delta assurance

This assurance establishes the constitutional release-delta semantics before the
legacy release adapters are migrated. The delta consumes only an exact
`HistoryPrefix` proof and therefore has no commit-reference or mutable
`ItemState` input.

Constitutional impact is event-shaped:

- GovernanceId introduction records immutable governance and phase identity.
- Proposition establishment and standalone abandonment resolve the responsible
  GovernanceId from the history immediately before the event.
- Supersession remains one atomic impact carrying its embedded establishments
  and exact proposition dispositions.
- Explicit or implicit phase identity introduction is retained.
- Current/phase progress is derived from the prefix and head histories.

`propose` intentionally produces no release impact by itself: it introduces
formal truth for an existing human contract but does not establish, dispose, or
supersede responsibility. Likewise, activity-only `Refs: GV…` advancement is
absent by construction because the constitutional delta has no references
parameter.

```agda
{-# OPTIONS --safe #-}

module Govenv.Assurance.GV116.ReleaseDelta where

open import Agda.Builtin.Bool using (false)
open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Maybe using (just)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.Unit using (⊤; tt)
open import Data.Product.Base using (_,_)
open import Data.List.Relation.Unary.All
  using (All)
  renaming ([] to all[]; _∷_ to _all∷_)
open import Relation.Nullary.Decidable using (from-yes)
open import Govenv.Kernel.Identifier using
  (P; GV; GVR; someIdentifier)
open import Govenv.Kernel.Constitution
open import Govenv.Kernel.Constitution.Snapshot
open import Govenv.Kernel.Constitution.Release

valid :
  (h : History) →
  (entry : HistoryEntry) →
  EntryReady h entry →
  EntryEvidence h entry →
  ValidEntry h entry
valid h entry ready evidence = ready , evidence

extendWith :
  {h : History} →
  ValidHistory h →
  (entry : HistoryEntry) →
  EntryReady h entry →
  EntryEvidence h entry →
  ValidHistory (h ▻ entry)
extendWith {h} historyValid entry ready evidence =
  extend historyValid entry (valid h entry ready evidence)

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

p10 : Proposition 10
p10 = prop 10

g1 : GovernanceDeclaration
g1 =
  governanceDeclaration
    (GV 1 "phase-one constitutional work")
    (P 1 "foundation")
    (someProposition p10 ∷ [])

h1 : History
h1 = ε ▻ declare g1

h1Valid : ValidHistory h1
h1Valid =
  extendWith
    empty
    (declare g1)
    (from-yes (entryReady? ε (declare g1)))
    tt

phase2 : PhaseDeclaration
phase2 = phaseDeclaration (P 2 "applications")

g2 : GovernanceDeclaration
g2 =
  governanceDeclaration
    (GV 2 "phase-two constitutional work")
    (P 2 "applications")
    []

e10 : Establishment
e10 = establishment 10

h2 : History
h2 =
  h1
  ▻ establish e10
  ▻ declarePhase phase2
  ▻ declare g2

h2Valid : ValidHistory h2
h2Valid =
  extendWith
    (extendWith
      (extendWith
        h1Valid
        (establish e10)
        (from-yes (entryReady? h1 (establish e10)))
        tt)
      (declarePhase phase2)
      (from-yes
        (entryReady?
          (h1 ▻ establish e10)
          (declarePhase phase2)))
      tt)
    (declare g2)
    (from-yes
      (entryReady?
        (h1 ▻ establish e10 ▻ declarePhase phase2)
        (declare g2)))
    tt

h1ToH2 : HistoryPrefix h1 h2
h1ToH2 =
  appendPrefix
    (appendPrefix
      (appendPrefix
        samePrefix
        (establish e10))
      (declarePhase phase2))
    (declare g2)

establishmentIntroductionAndPhaseProgressAreExact :
  constitutionalDelta h1ToH2 ≡
  validConstitutionalDelta
    (constitutionalDeltaValue
      ( propositionEstablished (GVR 1) 10
      ∷ phaseIdentityIntroduced (someIdentifier (P 2 "applications"))
      ∷ governanceIntroduced
          (someIdentifier (GV 2 "phase-two constitutional work"))
          (someIdentifier (P 2 "applications"))
      ∷ [] )
      (currentAdvanced
        (someIdentifier (P 1 "foundation"))
        (someIdentifier (P 2 "applications"))))
establishmentIntroductionAndPhaseProgressAreExact = refl

snapshotBridgeUsesTheSamePrefixDelta :
  snapshotConstitutionalDelta
    (snapshotConstitution
      "release-base"
      (constitution h1 h1Valid))
    (constitution h2 h2Valid)
    h1ToH2 ≡
  constitutionalDelta h1ToH2
snapshotBridgeUsesTheSamePrefixDelta = refl

-- No event means no constitutional change. There is intentionally no Refs input
-- that could manufacture the legacy "advanced" class.

sameHistoryHasNoConstitutionalImpact :
  constitutionalDelta (samePrefix {history = h1}) ≡
  validConstitutionalDelta
    (constitutionalDeltaValue
      []
      (currentUnchanged (just (someIdentifier (P 1 "foundation")))))
sameHistoryHasNoConstitutionalImpact = refl

sameHistoryDeltaIsUnchanged :
  constitutionalDeltaChanged
    (constitutionalDeltaValue
      []
      (currentUnchanged (just (someIdentifier (P 1 "foundation"))))) ≡
  false
sameHistoryDeltaIsUnchanged = refl

-- Late formal Proposition introduction is constitutional history, but GV116's
-- release-impact boundary starts only when responsibility is introduced,
-- established, disposed, superseded, or phase progress changes.

gFormalization : GovernanceDeclaration
gFormalization =
  governanceDeclaration
    (GV 10 "legacy human contract")
    (P 1 "foundation")
    []

hFormalization : History
hFormalization = ε ▻ declare gFormalization

p100 : Proposition 100
p100 = prop 100

lateProposal : PropositionDeclaration
lateProposal =
  propositionDeclaration (GVR 10) (someProposition p100)

formalizationOnly : HistoryPrefix
  hFormalization
  (hFormalization ▻ propose lateProposal)
formalizationOnly =
  appendPrefix samePrefix (propose lateProposal)

formalizationAloneHasNoReleaseImpact :
  constitutionalDelta formalizationOnly ≡
  validConstitutionalDelta
    (constitutionalDeltaValue
      []
      (currentUnchanged (just (someIdentifier (P 1 "foundation")))))
formalizationAloneHasNoReleaseImpact = refl

-- Standalone abandonment names the GovernanceId that owned the proposition
-- immediately before abandonment and can close the roadmap.

abandonmentOnly : HistoryPrefix h1 (h1 ▻ abandon 10)
abandonmentOnly =
  appendPrefix samePrefix (abandon 10)

abandonmentImpactIsExact :
  constitutionalDelta abandonmentOnly ≡
  validConstitutionalDelta
    (constitutionalDeltaValue
      (propositionAbandoned (GVR 1) 10 ∷ [])
      (roadmapCompleted (someIdentifier (P 1 "foundation"))))
abandonmentImpactIsExact = refl

-- Supersession is one atomic constitutional impact. Embedded establishment and
-- disposition observations stay inside that impact instead of being double
-- counted as independent history events.

p17 : Proposition 17
p17 = prop 17

p23 : Proposition 23
p23 = prop 23

g47 : GovernanceDeclaration
g47 =
  governanceDeclaration
    (GV 47 "old contract")
    (P 1 "foundation")
    (someProposition p17 ∷ [])

g68 : GovernanceDeclaration
g68 =
  governanceDeclaration
    (GV 68 "replacement contract")
    (P 1 "foundation")
    (someProposition p23 ∷ [])

e17 : Establishment
e17 = establishment 17

e23 : Establishment
e23 = establishment 23

s47-68 : Supersession
s47-68 =
  supersession
    (GVR 47)
    (GVR 68)
    (e23 ∷ [])
    (dispositionOf 17 (reformulated (23 ∷ [])) ∷ [])

beforeSupersession : History
beforeSupersession =
  ε
  ▻ declare g47
  ▻ declare g68
  ▻ establish e17

beforeSupersessionValid : ValidHistory beforeSupersession
beforeSupersessionValid =
  extendWith
    (extendWith
      (extendWith
        empty
        (declare g47)
        (from-yes (entryReady? ε (declare g47)))
        tt)
      (declare g68)
      (from-yes
        (entryReady? (ε ▻ declare g47) (declare g68)))
      tt)
    (establish e17)
    (from-yes
      (entryReady?
        (ε ▻ declare g47 ▻ declare g68)
        (establish e17)))
    tt

afterSupersession : History
afterSupersession =
  beforeSupersession ▻ supersede s47-68

afterSupersessionValid : ValidHistory afterSupersession
afterSupersessionValid =
  extendWith
    beforeSupersessionValid
    (supersede s47-68)
    (from-yes
      (entryReady? beforeSupersession (supersede s47-68)))
    (tt all∷ all[])

supersessionOnly : HistoryPrefix beforeSupersession afterSupersession
supersessionOnly =
  appendPrefix samePrefix (supersede s47-68)

supersessionImpactIsAtomicAndExact :
  constitutionalDelta supersessionOnly ≡
  validConstitutionalDelta
    (constitutionalDeltaValue
      ( governanceSuperseded
          (GVR 47)
          (GVR 68)
          (23 ∷ [])
          (dispositionOf 17 (reformulated (23 ∷ [])) ∷ [])
      ∷ [] )
      (roadmapCompleted (someIdentifier (P 1 "foundation"))))
supersessionImpactIsAtomicAndExact = refl
```
