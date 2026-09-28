# Learning continuity

Govenv preserves meaningful human authority by keeping conceptual project
evolution coupled to demonstrated human learning. Learning evidence is
revision-bound evidence that a human principal performed a challenge and
response; it is not a proof of the principal's mental state.

Candidate learning assessment is an explicit Protocol judgment over the exact
candidate delta. Its classification is human-reviewable rather than compiler-
inferred: validation proves that the assessment was refreshed when candidate
state changed and that the governed gate follows from the recorded assessment,
requirements, evidence, debt, and bypass. It does not prove that a semantic
classification or natural-language rationale is correct.

The bootstrap baseline is likewise a Protocol judgment, pinned to the governed
pre-GV122 frontier. It reconstructs the minimum causal learning path needed to
review current Govenv semantics from zero rather than replaying every historical
commit or superseded governance item. Superseded history is taught only when it
is needed to explain the effective model. Prospective candidate debt then
continues from that baseline without relying on prior chat or agent memory.

```agda
{-# OPTIONS --safe #-}

module Govenv.Learning where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringEquality)
open import Govenv.Kernel.Learning public
open import Govenv.LearningEvidence public using
  (DemonstratedLearning; evidence)

record BootstrapLesson : Set where
  constructor bootstrapLesson
  field
    key : String
    title : String
    context : String
    sources : String
    challenge : String
    requirement : LearningRequirement

private
  _and_ : Bool → Bool → Bool
  true and right = right
  false and right = false

  _or_ : Bool → Bool → Bool
  true or right = true
  false or right = right

sameRequirement : LearningRequirement → LearningRequirement → Bool
sameRequirement left right =
  primStringEquality
    (LearningRequirement.claim left)
    (LearningRequirement.claim right)
  and
  primStringEquality
    (LearningRequirement.sourceRevision left)
    (LearningRequirement.sourceRevision right)

containsRequirement : LearningRequirement → LearningDebt → Bool
containsRequirement requirement [] = false
containsRequirement requirement (candidate ∷ rest) =
  sameRequirement requirement candidate or
  containsRequirement requirement rest

requirementEvidenced :
  LearningRequirement →
  List DemonstratedLearning →
  Bool
requirementEvidenced requirement [] = false
requirementEvidenced requirement (candidate ∷ rest) =
  sameRequirement requirement (DemonstratedLearning.requirement candidate) or
  requirementEvidenced requirement rest

allRequirementsEvidenced :
  LearningDebt →
  List DemonstratedLearning →
  Bool
allRequirementsEvidenced [] evidence = true
allRequirementsEvidenced (requirement ∷ rest) evidence =
  requirementEvidenced requirement evidence and
  allRequirementsEvidenced rest evidence

allRequirementsRepresented :
  LearningDebt →
  List DemonstratedLearning →
  LearningDebt →
  Bool
allRequirementsRepresented [] evidence debt = true
allRequirementsRepresented (requirement ∷ rest) evidence debt =
  ( requirementEvidenced requirement evidence or
    containsRequirement requirement debt )
  and
  allRequirementsRepresented rest evidence debt

pendingRequirements :
  LearningDebt →
  List DemonstratedLearning →
  LearningDebt
pendingRequirements [] evidence = []
pendingRequirements (requirement ∷ rest) evidence
  with requirementEvidenced requirement evidence
... | true = pendingRequirements rest evidence
... | false = requirement ∷ pendingRequirements rest evidence

appendDebt : LearningDebt → LearningDebt → LearningDebt
appendDebt [] right = right
appendDebt (requirement ∷ rest) right =
  requirement ∷ appendDebt rest right

bootstrapBoundary : String
bootstrapBoundary =
  "eac603e07e6eae7b5dc7c2d762d422003c4459a4"

purposeRequirement : LearningRequirement
purposeRequirement =
  learningRequirement
    "Explain Govenv's purpose and why keeping agent speed behind meaningful human authority is part of the product rather than an informal convention."
    bootstrapBoundary

boundariesRequirement : LearningRequirement
boundariesRequirement =
  learningRequirement
    "Distinguish Governance, Protocol, Materialization, and Assurance, including what each layer may and may not claim as authority."
    bootstrapBoundary

authorizationRequirement : LearningRequirement
authorizationRequirement =
  learningRequirement
    "Explain the candidate-to-authorized-revision boundary: why human pull-request merge grants semantic authorization while derived revisions, effects, credentials, and agents do not."
    bootstrapBoundary

constitutionRequirement : LearningRequirement
constitutionRequirement =
  learningRequirement
    "Explain the append-only constitutional model: GovernanceId contracts, formal Propositions, Evidence, establishment, supersession, and why propositions may be introduced late only under governed conditions."
    bootstrapBoundary

assuranceRequirement : LearningRequirement
assuranceRequirement =
  learningRequirement
    "Explain why green CI is not semantic legitimacy, how counterexamples expose assurance holes, and why obligations should be enforced at the earliest sound boundary."
    bootstrapBoundary

runtimeRequirement : LearningRequirement
runtimeRequirement =
  learningRequirement
    "Explain Govenv's agent/runtime capability boundary: what devenv/govenv shell provides, how collaboration credentials remain external capability state, and why provider identity never grants semantic authority."
    bootstrapBoundary

learningRequirementBaseline : LearningRequirement
learningRequirementBaseline =
  learningRequirement
    "Explain Govenv learning continuity: human challenge/response evidence, learning debt, the urgent corrective bypass, and the hard minor/major release gate."
    bootstrapBoundary

agdaRequirement : LearningRequirement
agdaRequirement =
  learningRequirement
    "Read the Agda substrate used by Govenv well enough to distinguish data/records/indexed types/equality proofs from Protocol judgments that the compiler cannot prove."
    bootstrapBoundary

directionRequirement : LearningRequirement
directionRequirement =
  learningRequirement
    "Explain how Purpose and the exact Roadmap feed DirectionReview, why vigilance requires explicit rationale, and what the current Next sequence is."
    bootstrapBoundary

purposeLesson : BootstrapLesson
purposeLesson =
  bootstrapLesson
    "purpose"
    "1. Purpose and human authority"
    "Start with why Govenv exists. The current purpose is the compressed result of the project's early repository-validity work and the later realization that fast agents must not silently outrun the human principal."
    "Govenv.Project; Govenv.DirectionReview; GV109-GV112; GV119"
    "In your own words: what failure is Govenv preventing, and why is human authority part of the product rather than merely a team convention?"
    purposeRequirement

boundariesLesson : BootstrapLesson
boundariesLesson =
  bootstrapLesson
    "boundaries"
    "2. Semantic boundaries"
    "Govenv gradually separated constitutional semantics from contributor judgment, deterministic projection, and evidence-bearing verification. This separation is the foundation for deciding what may be compiler-proven."
    "Govenv.Governance; Govenv.Protocol; Govenv.Materialization; Govenv.Assurance; GV51; GV74; GV101"
    "Classify one example into each of Governance, Protocol, Materialization, and Assurance, and explain one thing each layer must not do."
    boundariesRequirement

authorizationLesson : BootstrapLesson
authorizationLesson =
  bootstrapLesson
    "authorization"
    "3. Human authorization"
    "As automation expanded, Govenv made the pull-request merge the explicit semantic authorization event. Everything later produced by machines must retain provenance to that human-authorized revision without gaining independent authority."
    "Govenv.Authorization; Govenv.Github.Authorization; GV90; GV91"
    "Trace a candidate PR through human merge, a derived materialization commit, and an external effect. Where exactly does semantic authority enter, and where does it not?"
    authorizationRequirement

constitutionLesson : BootstrapLesson
constitutionLesson =
  bootstrapLesson
    "constitution"
    "4. Constitutional history"
    "The roadmap evolved from mutable status into append-only constitutional history. A one-shot Genesis boundary imports the legacy lifecycle at cutover; later history remains append-only. Human GovernanceId contracts and machine-checkable propositions stay distinct so formal truth can mature without rewriting the original human decision."
    "Govenv.Kernel.Constitution; Govenv.Kernel.Constitution.Genesis; Govenv.Assurance.GV95; Govenv.Assurance.GV116"
    "Explain the difference between the one-shot Genesis cutover and later history entries, then distinguish a GovernanceId contract from a Proposition and describe establish/supersede without treating history as mutable state."
    constitutionRequirement

assuranceLesson : BootstrapLesson
assuranceLesson =
  bootstrapLesson
    "assurance"
    "5. Assurance and counterexamples"
    "Govenv learned repeatedly that a green check can coexist with a semantic contradiction. Counterexamples are therefore preserved and assurances are strengthened at the earliest boundary where the required information exists."
    "Govenv.Assurance; Govenv.Protocol semantic validation; GV74; GV84; GV88; GV99"
    "If CI is green but you can point to a governed invariant the candidate violates, what should happen next and why?"
    assuranceRequirement

runtimeLesson : BootstrapLesson
runtimeLesson =
  bootstrapLesson
    "runtime"
    "6. Agent and runtime capabilities"
    "Agent tooling moved from host-specific convenience toward a governed environment boundary. Shells may provide tools, hooks, and provider credentials, but those capabilities remain operational and cannot authorize semantics."
    "Govenv.Github.Authorization; Govenv.Protocol repository collaboration; GV103; GV107; GV118"
    "Explain what an authenticated coding agent may do through the Govenv environment and what still requires the human principal."
    runtimeRequirement

learningLesson : BootstrapLesson
learningLesson =
  bootstrapLesson
    "learning"
    "7. Learning continuity"
    "Once agent throughput became faster than human review comprehension, learning itself became part of preserving meaningful authority. Evidence records human challenge/response; it never claims to prove mental state."
    "Govenv.Learning; Govenv.Kernel.Learning; GV119"
    "Explain why an urgent corrective bypass must preserve debt, and why a later conceptual feature must wait until that debt is closed."
    learningRequirementBaseline

agdaLesson : BootstrapLesson
agdaLesson =
  bootstrapLesson
    "agda"
    "8. Agda review literacy"
    "Govenv uses Agda as its current reference formalization. The roadmap now plans a later language-neutral Governance IR boundary, but until that exists the principal still needs enough Agda literacy to inspect the constructs carrying today's guarantees instead of trusting an agent's description of a proof."
    "Govenv.Kernel.*; Govenv.Assurance.*; representative data, record, indexed type, equality, and refl proofs"
    "Pick one current Govenv guarantee and identify which part is data, which part is a proposition/type, which value is the proof/evidence, and which nearby judgment remains outside compiler proof."
    agdaRequirement

directionLesson : BootstrapLesson
directionLesson =
  bootstrapLesson
    "direction"
    "9. Current direction and vigilance"
    "After reconstructing the model, finish at the current frontier. Purpose and the exact Roadmap feed an explicit DirectionReview; triggered reviews require fresh rationale so counters cannot silently substitute for judgment. The nearer sequence remains GV116→GV117→GV118, while P7/GV120-GV121 records the later language-neutral application direction."
    "Govenv.DirectionReview; Govenv.Roadmap; Govenv.Project; GV110; GV111; GV112; GV120; GV121"
    "State the current nearer Next sequence and the later P7 direction, then explain why changing either requires a real Purpose/Direction review rather than only incrementing a witness."
    directionRequirement

bootstrapLessons : List BootstrapLesson
bootstrapLessons =
    purposeLesson
  ∷ boundariesLesson
  ∷ authorizationLesson
  ∷ constitutionLesson
  ∷ assuranceLesson
  ∷ runtimeLesson
  ∷ learningLesson
  ∷ agdaLesson
  ∷ directionLesson
  ∷ []

bootstrapRequirements : LearningDebt
bootstrapRequirements =
    purposeRequirement
  ∷ boundariesRequirement
  ∷ authorizationRequirement
  ∷ constitutionRequirement
  ∷ assuranceRequirement
  ∷ runtimeRequirement
  ∷ learningRequirementBaseline
  ∷ agdaRequirement
  ∷ directionRequirement
  ∷ []

bootstrapComplete : Bool
bootstrapComplete =
  allRequirementsEvidenced bootstrapRequirements evidence

candidateBoundary : String
candidateBoundary =
  "eac603e07e6eae7b5dc7c2d762d422003c4459a4"

gateSemanticsRequirement : LearningRequirement
gateSemanticsRequirement =
  learningRequirement
    "Explain why candidate learning classification remains a Protocol judgment while the resulting PR and release gates are governed."
    candidateBoundary

bypassDebtRequirement : LearningRequirement
bypassDebtRequirement =
  learningRequirement
    "Explain why an urgent corrective bypass preserves learning debt and therefore blocks later conceptual expansion until catch-up closes it."
    candidateBoundary

bootstrapMechanicsRequirement : LearningRequirement
bootstrapMechanicsRequirement =
  learningRequirement
    "Explain why from-zero bootstrap is a pinned Protocol-curated baseline, why it teaches effective semantics rather than replaying every historical commit, and why outstanding debt is derived from bootstrap plus carried debt minus human evidence."
    candidateBoundary

gateSemanticsLesson : BootstrapLesson
gateSemanticsLesson =
  bootstrapLesson
    "candidate-gate"
    "10. Candidate learning boundary"
    "After the historical baseline, learn the boundary introduced by this candidate: classification remains human-reviewable Protocol judgment while the resulting gate is governed and machine-checked."
    "Govenv.Learning; Govenv.Kernel.Learning; GV122"
    (LearningRequirement.claim gateSemanticsRequirement)
    gateSemanticsRequirement

bypassDebtLesson : BootstrapLesson
bypassDebtLesson =
  bootstrapLesson
    "bypass-debt"
    "11. Corrective bypass debt"
    "Urgent corrective work may restore a broken enforcement boundary before learning is complete, but that exception must not silently erase what the human still needs to learn."
    "Govenv.Learning; Govenv.Kernel.Learning; GV119; GV122"
    (LearningRequirement.claim bypassDebtRequirement)
    bypassDebtRequirement

bootstrapMechanicsLesson : BootstrapLesson
bootstrapMechanicsLesson =
  bootstrapLesson
    "bootstrap-mechanics"
    "12. Bootstrap reconstruction"
    "The from-zero path is a pinned Protocol-curated reconstruction of effective semantics, not a replay of every historical commit. It joins the prospective debt model instead of creating a weaker parallel authority."
    "Govenv.Learning; Govenv.LearningEvidence; GV123"
    (LearningRequirement.claim bootstrapMechanicsRequirement)
    bootstrapMechanicsRequirement

carriedLessons : List BootstrapLesson
carriedLessons =
    gateSemanticsLesson
  ∷ bypassDebtLesson
  ∷ bootstrapMechanicsLesson
  ∷ []

appendLessons : List BootstrapLesson → List BootstrapLesson → List BootstrapLesson
appendLessons [] right = right
appendLessons (lesson ∷ rest) right =
  lesson ∷ appendLessons rest right

allLearningPrompts : List BootstrapLesson
allLearningPrompts =
  appendLessons bootstrapLessons carriedLessons

assessment : CandidateLearningAssessment
assessment =
  candidateLearningAssessment
    corrective
    expands
    "GV119 promised a soft PR learning gate but candidate CI did not enforce it; GV122 adds the missing PR boundary and GV123 makes that gate reachable from zero through a governed bootstrap baseline. This corrective candidate preserves all new learning requirements as debt through the urgent corrective bypass."
    ( gateSemanticsRequirement
    ∷ bypassDebtRequirement
    ∷ bootstrapMechanicsRequirement
    ∷ [] )
    urgentCorrective
    0

carriedDebt : LearningDebt
carriedDebt =
  gateSemanticsRequirement
  ∷ bypassDebtRequirement
  ∷ bootstrapMechanicsRequirement
  ∷ []

outstanding : LearningDebt
outstanding =
  pendingRequirements
    (appendDebt bootstrapRequirements carriedDebt)
    evidence

assessmentRequirementsClosed : Bool
assessmentRequirementsClosed =
  allRequirementsEvidenced
    (CandidateLearningAssessment.requirements assessment)
    evidence

assessmentRequirementsPreserved : Bool
assessmentRequirementsPreserved =
  allRequirementsRepresented
    (CandidateLearningAssessment.requirements assessment)
    evidence
    outstanding

candidateAllowed : Bool
candidateAllowed =
  candidateLearningAllowed
    (CandidateLearningAssessment.kind assessment)
    (CandidateLearningAssessment.impact assessment)
    (requirementsPresent
      (CandidateLearningAssessment.requirements assessment))
    assessmentRequirementsClosed
    assessmentRequirementsPreserved
    outstanding
    (CandidateLearningAssessment.bypass assessment)
```
