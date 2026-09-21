{-# OPTIONS --safe #-}

module Govenv.Kernel.ConstitutionalHistorySpike.ConstitutionalHistoryPropositionalScenarios where

open import Agda.Builtin.Equality using (_≡_; refl)
open import Agda.Builtin.List using ([]; _∷_)
open import Agda.Builtin.Nat using (Nat)
open import Agda.Builtin.Unit using (⊤; tt)
open import Relation.Nullary using (¬_)
open import Relation.Nullary.Decidable using (From-yes; from-yes; from-no)
open import Govenv.Kernel.ConstitutionalHistorySpike.ConstitutionalHistoryPropositional

decideValid : (h : History) → (entry : HistoryEntry) → From-yes (validEntry? h entry)
decideValid h entry = from-yes (validEntry? h entry)

prop : (n : Nat) → Proposition n
prop n = proposition (Prop n) ⊤

evidenceFor : {n : Nat} → Evidence (prop n)
evidenceFor = evidence tt

-- 1. Simple establishment => check

p1 : Proposition 1
p1 = prop 1

g1 : GovernanceDeclaration
g1 = governanceDeclaration 1 "simple establishment" 1
  (someProposition p1 ∷ [])

e1 : Establishment
e1 = establishment p1 evidenceFor

h1 : History
h1 = ε ▻ declare g1 ▻ establish e1
h1-valid : ValidHistory h1
h1-valid =
  extend
    (extend empty (declare g1) (decideValid ε (declare g1)))
    (establish e1)
    (decideValid (ε ▻ declare g1) (establish e1))

h1-glyph : governanceGlyph h1 1 ≡ check
h1-glyph = refl

-- 2. Established + abandoned subjects => mixed

p2 : Proposition 2
p2 = prop 2

p3 : Proposition 3
p3 = prop 3

g2 : GovernanceDeclaration
g2 = governanceDeclaration 2 "mixed resolution" 1
  (someProposition p2 ∷ someProposition p3 ∷ [])

e2 : Establishment
e2 = establishment p2 evidenceFor

h2 : History
h2 = ε ▻ declare g2 ▻ establish e2 ▻ abandon 3
h2-valid : ValidHistory h2
h2-valid =
  extend
    (extend
      (extend empty (declare g2) (decideValid ε (declare g2)))
      (establish e2)
      (decideValid (ε ▻ declare g2) (establish e2)))
    (abandon 3)
    (decideValid (ε ▻ declare g2 ▻ establish e2) (abandon 3))

h2-glyph : governanceGlyph h2 2 ≡ mixed
h2-glyph = refl

-- 3. GV47 reformulates Prop17 into Prop23 in GV68 => check / check

p17 : Proposition 17
p17 = prop 17

p23 : Proposition 23
p23 = prop 23

g47 : GovernanceDeclaration
g47 = governanceDeclaration 47 "old contract" 1
  (someProposition p17 ∷ [])

g68 : GovernanceDeclaration
g68 = governanceDeclaration 68 "reformulated contract" 1
  (someProposition p23 ∷ [])
e17 : Establishment
e17 = establishment p17 (evidenceFor)

e23 : Establishment
e23 = establishment p23 (evidenceFor)

s47-68 : Supersession
s47-68 = supersession 47 68
  (e23 ∷ [])
  (dispositionOf 17 (reformulated (23 ∷ [])) ∷ [])

h47-68 : History
h47-68 =
  ε
  ▻ declare g47
  ▻ establish e17
  ▻ declare g68
  ▻ supersede s47-68

h47-68-valid : ValidHistory h47-68
h47-68-valid =
  extend
    (extend
      (extend
        (extend empty (declare g47) (decideValid ε (declare g47)))
        (establish e17)
        (decideValid (ε ▻ declare g47) (establish e17)))
      (declare g68)
      (decideValid (ε ▻ declare g47 ▻ establish e17) (declare g68)))
    (supersede s47-68)
    (decideValid (ε ▻ declare g47 ▻ establish e17 ▻ declare g68) (supersede s47-68))
gv47-glyph : governanceGlyph h47-68 47 ≡ check
gv47-glyph = refl

gv68-glyph : governanceGlyph h47-68 68 ≡ check
gv68-glyph = refl

-- 4. GV77 abandons pending Prop41 while GV95 introduces pending Prop60

p41 : Proposition 41
p41 = prop 41

p60 : Proposition 60
p60 = prop 60

g77 : GovernanceDeclaration
g77 = governanceDeclaration 77 "superseded pending contract" 1
  (someProposition p41 ∷ [])

g95 : GovernanceDeclaration
g95 = governanceDeclaration 95 "successor contract" 1
  (someProposition p60 ∷ [])

s77-95 : Supersession
s77-95 = supersession 77 95 []
  (dispositionOf 41 abandoned ∷ [])

h77-95 : History
h77-95 =
  ε
  ▻ declare g77
  ▻ declare g95
  ▻ supersede s77-95
h77-95-valid : ValidHistory h77-95
h77-95-valid =
  extend
    (extend
      (extend empty (declare g77) (decideValid ε (declare g77)))
      (declare g95)
      (decideValid (ε ▻ declare g77) (declare g95)))
    (supersede s77-95)
    (decideValid (ε ▻ declare g77 ▻ declare g95) (supersede s77-95))

gv77-glyph : governanceGlyph h77-95 77 ≡ cross
gv77-glyph = refl

gv95-glyph : governanceGlyph h77-95 95 ≡ diamond
gv95-glyph = refl

e60 : Establishment
e60 = establishment p60 (evidenceFor)

h95-established : History
h95-established = h77-95 ▻ establish e60

h95-established-valid : ValidHistory h95-established
h95-established-valid =
  extend h77-95-valid (establish e60) (decideValid h77-95 (establish e60))

gv95-established-glyph : governanceGlyph h95-established 95 ≡ mixed
gv95-established-glyph = refl

-- Stdlib-backed declaration validity rejects duplicate Proposition IDs.

p70a : Proposition 70
p70a = prop 70

p70b : Proposition 70
p70b = prop 70

duplicateDeclaration : GovernanceDeclaration
duplicateDeclaration =
  governanceDeclaration 70 "duplicate ids" 1
    (someProposition p70a ∷ someProposition p70b ∷ [])

duplicateIdsRejected :
  ¬ ValidEntry ε (declare duplicateDeclaration)
duplicateIdsRejected =
  from-no (validEntry? ε (declare duplicateDeclaration))

-- Supersession coverage is set-like rather than list-order-sensitive.

p80 : Proposition 80
p80 = prop 80

p81 : Proposition 81
p81 = prop 81

g80 : GovernanceDeclaration
g80 = governanceDeclaration 80 "two pending propositions" 1
  (someProposition p80 ∷ someProposition p81 ∷ [])

g81 : GovernanceDeclaration
g81 = governanceDeclaration 81 "empty successor" 1 []

s80-81-reordered : Supersession
s80-81-reordered =
  supersession 80 81 []
    ( dispositionOf 81 abandoned
    ∷ dispositionOf 80 abandoned
    ∷ [])

h80-81-reordered : History
h80-81-reordered =
  ε
  ▻ declare g80
  ▻ declare g81
  ▻ supersede s80-81-reordered

h80-81-reordered-valid : ValidHistory h80-81-reordered
h80-81-reordered-valid =
  extend
    (extend
      (extend empty (declare g80) (decideValid ε (declare g80)))
      (declare g81)
      (decideValid (ε ▻ declare g80) (declare g81)))
    (supersede s80-81-reordered)
    (decideValid (ε ▻ declare g80 ▻ declare g81) (supersede s80-81-reordered))

s80-81-duplicate-disposition : Supersession
s80-81-duplicate-disposition =
  supersession 80 81 []
    ( dispositionOf 80 abandoned
    ∷ dispositionOf 80 abandoned
    ∷ dispositionOf 81 abandoned
    ∷ [])

duplicateDispositionRejected :
  ¬ ValidEntry
    (ε ▻ declare g80 ▻ declare g81)
    (supersede s80-81-duplicate-disposition)
duplicateDispositionRejected =
  from-no
    (validEntry?
      (ε ▻ declare g80 ▻ declare g81)
      (supersede s80-81-duplicate-disposition))

-- Embedded establishments are constitutional establishments too:
-- they must be pending before the atomic supersession and unique.

s47-68-duplicate-establishment : Supersession
s47-68-duplicate-establishment =
  supersession 47 68
    (e23 ∷ e23 ∷ [])
    (dispositionOf 17 (reformulated (23 ∷ [])) ∷ [])

duplicateEmbeddedEstablishmentRejected :
  ¬ ValidEntry
    (ε ▻ declare g47 ▻ establish e17 ▻ declare g68)
    (supersede s47-68-duplicate-establishment)
duplicateEmbeddedEstablishmentRejected =
  from-no
    (validEntry?
      (ε ▻ declare g47 ▻ establish e17 ▻ declare g68)
      (supersede s47-68-duplicate-establishment))

h47-68-preestablished : History
h47-68-preestablished =
  ε
  ▻ declare g47
  ▻ establish e17
  ▻ declare g68
  ▻ establish e23

s47-68-reestablish-active : Supersession
s47-68-reestablish-active =
  supersession 47 68
    (e23 ∷ [])
    (dispositionOf 17 (reformulated (23 ∷ [])) ∷ [])

activeEmbeddedEstablishmentRejected :
  ¬ ValidEntry h47-68-preestablished (supersede s47-68-reestablish-active)
activeEmbeddedEstablishmentRejected =
  from-no
    (validEntry?
      h47-68-preestablished
      (supersede s47-68-reestablish-active))
