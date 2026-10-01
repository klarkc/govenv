# Learning continuity

Govenv preserves meaningful human authority by keeping conceptual project
evolution coupled to demonstrated human learning. Learning evidence is
revision-bound evidence that a human principal responded under an explicit
review contract; it is not a proof of the principal's mental state or of answer
quality.

Candidate learning assessment is an explicit Protocol judgment over the exact
candidate delta. Its classification is human-reviewable rather than compiler-
inferred: validation proves that the assessment was refreshed when candidate
state changed and that the governed gate follows from the recorded assessment,
requirements, evidence, debt, and bypass. It does not prove that a semantic
classification or natural-language rationale is correct.

The bootstrap baseline is likewise a Protocol judgment, pinned to the governed
pre-GV122 frontier. It reconstructs the minimum causal learning path needed to
review current Govenv semantics from zero rather than replaying every historical
commit or superseded governance item. Each lesson identifies a semantically
load-bearing review surface and separate semantic, code, and assurance probes.
Debt reduction is bound to the exact current review contract, so changing that
surface or those probes makes older evidence stale. The compiler proves this
binding and structural presence, not that the selected surface is pedagogically
sufficient or that the human understood it. Prospective candidate debt then
continues from that baseline without relying on prior chat or agent memory.

```agda
{-# OPTIONS --safe #-}

module Govenv.Learning where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.String using (String; primStringAppend; primStringEquality)
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
    reviewSurface : String
    semanticProbe : String
    codeProbe : String
    assuranceProbe : String
    requirement : LearningRequirement

private
  infixr 5 _++_
  infixr 4 _and_
  infixr 3 _or_

  _++_ : String → String → String
  _++_ = primStringAppend

  _and_ : Bool → Bool → Bool
  true and right = right
  false and right = false

  _or_ : Bool → Bool → Bool
  true or right = true
  false or right = right

stringPresent : String → Bool
stringPresent value with primStringEquality value ""
... | true = false
... | false = true

reviewContract : BootstrapLesson → String
reviewContract lesson =
  "Review surface: " ++ BootstrapLesson.reviewSurface lesson ++
  " | Semantic probe: " ++ BootstrapLesson.semanticProbe lesson ++
  " | Code probe: " ++ BootstrapLesson.codeProbe lesson ++
  " | Assurance probe: " ++ BootstrapLesson.assuranceProbe lesson

lessonReviewable : BootstrapLesson → Bool
lessonReviewable lesson =
  stringPresent (BootstrapLesson.reviewSurface lesson) and
  stringPresent (BootstrapLesson.semanticProbe lesson) and
  stringPresent (BootstrapLesson.codeProbe lesson) and
  stringPresent (BootstrapLesson.assuranceProbe lesson)

allLessonsReviewable : List BootstrapLesson → Bool
allLessonsReviewable [] = true
allLessonsReviewable (lesson ∷ rest) =
  lessonReviewable lesson and allLessonsReviewable rest

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


lessonEvidenced :
  BootstrapLesson →
  List DemonstratedLearning →
  Bool
lessonEvidenced lesson [] = false
lessonEvidenced lesson (candidate ∷ rest) =
  ( sameRequirement
      (BootstrapLesson.requirement lesson)
      (DemonstratedLearning.requirement candidate)
    and
    primStringEquality
      (reviewContract lesson)
      (DemonstratedLearning.reviewContract candidate) )
  or lessonEvidenced lesson rest

allLessonsEvidenced :
  List BootstrapLesson →
  List DemonstratedLearning →
  Bool
allLessonsEvidenced [] evidence = true
allLessonsEvidenced (lesson ∷ rest) evidence =
  lessonEvidenced lesson evidence and
  allLessonsEvidenced rest evidence

requirementEvidencedByLessons :
  LearningRequirement →
  List BootstrapLesson →
  List DemonstratedLearning →
  Bool
requirementEvidencedByLessons requirement [] evidence = false
requirementEvidencedByLessons requirement (lesson ∷ rest) evidence =
  ( sameRequirement requirement (BootstrapLesson.requirement lesson) and
    lessonEvidenced lesson evidence )
  or requirementEvidencedByLessons requirement rest evidence

allRequirementsEvidencedByLessons :
  LearningDebt →
  List BootstrapLesson →
  List DemonstratedLearning →
  Bool
allRequirementsEvidencedByLessons [] lessons evidence = true
allRequirementsEvidencedByLessons (requirement ∷ rest) lessons evidence =
  requirementEvidencedByLessons requirement lessons evidence and
  allRequirementsEvidencedByLessons rest lessons evidence

allRequirementsRepresentedByLessons :
  LearningDebt →
  List BootstrapLesson →
  List DemonstratedLearning →
  LearningDebt →
  Bool
allRequirementsRepresentedByLessons [] lessons evidence debt = true
allRequirementsRepresentedByLessons (requirement ∷ rest) lessons evidence debt =
  ( requirementEvidencedByLessons requirement lessons evidence or
    containsRequirement requirement debt )
  and
  allRequirementsRepresentedByLessons rest lessons evidence debt

pendingLessonRequirements :
  List BootstrapLesson →
  List DemonstratedLearning →
  LearningDebt
pendingLessonRequirements [] evidence = []
pendingLessonRequirements (lesson ∷ rest) evidence
  with lessonEvidenced lesson evidence
... | true = pendingLessonRequirements rest evidence
... | false =
  BootstrapLesson.requirement lesson ∷
  pendingLessonRequirements rest evidence

lessonRequirements : List BootstrapLesson → LearningDebt
lessonRequirements [] = []
lessonRequirements (lesson ∷ rest) =
  BootstrapLesson.requirement lesson ∷ lessonRequirements rest

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
    "Start with why Govenv exists. Before the code and assurance probes, teach the minimum Agda substrate needed to review this lesson: equality propositions (_≡_), refl, definitional reduction, and the meaning of the boolean arguments flowing into protocolReviewFresh. This primer is prerequisite instruction, not separate learning evidence."
    "Govenv.Project; Govenv.DirectionReview; Govenv.Kernel.Protocol; Govenv.Adapter.PurposeVigilance; Govenv.Assurance.GV110; Govenv.Assurance.GV110.Counterexample.MechanicalBump; Govenv.Materialization.Readme; Govenv.Materialization.ProjectPurposeSnapshot; Govenv.Adapter.Readme; roadmap-evolution adapter; governed materialization check"
    "Govenv.Project.purpose/purposeReviewIndex/purposeReviewRationale; Govenv.DirectionReview; src/Govenv/Kernel/Protocol.agda; Govenv.Assurance.GV110; Govenv.Assurance.GV110.Counterexample.MechanicalBump; Govenv.Materialization.ProjectPurposeSnapshot; src/Govenv/Adapter/PurposeVigilance.agda; src/Govenv/Adapter/roadmap-evolution.sh; Govenv.Materialization.Readme; src/Govenv/Adapter/Readme.agda; devenv.nix checkMaterializations README equality boundary"
    "In your own words: what failure is Govenv preventing, and why is human authority part of the product rather than merely a team convention?"
    "Locate the canonical purpose, trace one projection of it, and identify the code that makes a mechanical purpose-review counter bump insufficient."
    "If README or a review counter changed while the governed purpose/review evidence did not, explain which checks should reject the candidate and what they do not prove."
    purposeRequirement
boundariesLesson : BootstrapLesson
boundariesLesson =
  bootstrapLesson
    "boundaries"
    "2. Semantic boundaries"
    "Govenv gradually separated constitutional semantics from contributor judgment, deterministic projection, and evidence-bearing verification. This separation is the foundation for deciding what may be compiler-proven."
    "Govenv.Governance; Govenv.Protocol; Govenv.Materialization; Govenv.Assurance; GV51; GV74; GV101"
    "Govenv.Governance; Govenv.Protocol; Govenv.Materialization; Govenv.Assurance; Govenv.Kernel.Assurance"
    "Classify one example into each of Governance, Protocol, Materialization, and Assurance, and explain one thing each layer must not do."
    "Pick one declaration from each boundary module and explain why its type or role belongs there rather than in another layer."
    "Trace one governed property from semantic authority to materialization or assurance and identify where policy is forbidden from reappearing."
    boundariesRequirement
authorizationLesson : BootstrapLesson
authorizationLesson =
  bootstrapLesson
    "authorization"
    "3. Human authorization"
    "As automation expanded, Govenv made the pull-request merge the explicit semantic authorization event. Everything later produced by machines must retain provenance to that human-authorized revision without gaining independent authority."
    "Govenv.Authorization; Govenv.Github.Authorization; GV90; GV91"
    "Govenv.Authorization; Govenv.Github.Authorization; Govenv.Materialization.ApplicationAuthorization; Govenv.Assurance.GV90"
    "Trace a candidate PR through human merge, a derived materialization commit, and an external effect. Where exactly does semantic authority enter, and where does it not?"
    "Trace the constructors from candidate state through human pull-request merge and AuthorizedRevision to an authorized materialization application."
    "Show why a bot credential, derived commit, or external read-back cannot construct fresh semantic authority on its own."
    authorizationRequirement
constitutionLesson : BootstrapLesson
constitutionLesson =
  bootstrapLesson
    "constitution"
    "4. Constitutional history"
    "The roadmap evolved from mutable status into append-only constitutional history. A one-shot Genesis boundary imports the legacy lifecycle at cutover; later history remains append-only. Human GovernanceId contracts and machine-checkable propositions stay distinct so formal truth can mature without rewriting the original human decision."
    "Govenv.Kernel.Constitution; Govenv.Kernel.Constitution.Genesis; Govenv.Assurance.GV95; Govenv.Assurance.GV116"
    "Govenv.Kernel.Constitution; Govenv.Kernel.Constitution.Genesis; Govenv.Roadmap; Govenv.Assurance.GV116"
    "Explain the difference between the one-shot Genesis cutover and later history entries, then distinguish a GovernanceId contract from a Proposition and describe establish/supersede without treating history as mutable state."
    "Locate the types and constructors for Genesis and later history, and trace how GovernanceId contracts remain distinct from formal Propositions."
    "Identify one invariant preventing history rewrite or reopening and the assurance or counterexample that would expose a violation."
    constitutionRequirement
assuranceLesson : BootstrapLesson
assuranceLesson =
  bootstrapLesson
    "assurance"
    "5. Assurance and counterexamples"
    "Govenv learned repeatedly that a green check can coexist with a semantic contradiction. Counterexamples are therefore preserved and assurances are strengthened at the earliest boundary where the required information exists."
    "Govenv.Assurance; Govenv.Protocol semantic validation; GV74; GV84; GV88; GV99"
    "Govenv.Kernel.Assurance; Govenv.Assurance; Govenv.Assurance.GV84; Govenv.Assurance.*.Counterexample"
    "If CI is green but you can point to a governed invariant the candidate violates, what should happen next and why?"
    "Trace one completed governance item from its proposition through StaticEvidence or an observed Rule into completion coverage."
    "Given a green CI result that contradicts governance, identify what must become a counterexample and which enforcement boundary must be strengthened."
    assuranceRequirement
runtimeLesson : BootstrapLesson
runtimeLesson =
  bootstrapLesson
    "runtime"
    "6. Agent and runtime capabilities"
    "Agent tooling moved from host-specific convenience toward a governed environment boundary. Shells may provide tools, hooks, and provider credentials, but those capabilities remain operational and cannot authorize semantics."
    "Govenv.Github.Authorization; Govenv.Protocol repository collaboration; GV103; GV107; GV118"
    "Govenv.Protocol.repositoryCollaboration; Govenv.Github.Authorization; Govenv.Materialization; devenv.nix"
    "Explain what an authenticated coding agent may do through the Govenv environment and what still requires the human principal."
    "Trace how repository-collaboration tooling is supplied operationally while authorization remains represented separately in governed types."
    "Explain from the code why provider credentials or identity cannot construct human semantic authorization or merge authority."
    runtimeRequirement
learningLesson : BootstrapLesson
learningLesson =
  bootstrapLesson
    "learning"
    "7. Learning continuity"
    "Once agent throughput became faster than human review comprehension, learning itself became part of preserving meaningful authority. Evidence records human challenge/response; it never claims to prove mental state."
    "Govenv.Learning; Govenv.Kernel.Learning; GV119"
    "Govenv.Kernel.Learning; Govenv.Learning; Govenv.LearningEvidence; Govenv.Assurance.GV119"
    "Explain why an urgent corrective bypass must preserve debt, and why a later conceptual feature must wait until that debt is closed."
    "Trace a LearningRequirement from outstanding debt through evidence matching to candidateAllowed and releaseLearningAllowed."
    "Show where urgentCorrective permits a candidate while preserving debt, and where minor or major release remains closed."
    learningRequirementBaseline
agdaLesson : BootstrapLesson
agdaLesson =
  bootstrapLesson
    "agda"
    "8. Agda review literacy"
    "Govenv uses Agda as its current reference formalization. The roadmap now plans a later language-neutral Governance IR boundary, but until that exists the principal still needs enough Agda literacy to inspect the constructs carrying today's guarantees instead of trusting an agent's description of a proof."
    "Govenv.Kernel.*; Govenv.Assurance.*; representative data, record, indexed type, equality, and refl proofs"
    "Govenv.Kernel.Learning; Govenv.Authorization; Govenv.Assurance.GV123; representative refl proofs"
    "Pick one current Govenv guarantee and identify which part is data, which part is a proposition/type, which value is the proof/evidence, and which nearby judgment remains outside compiler proof."
    "For one guarantee, identify the data, proposition or type, constructor or value that inhabits it, and the equality/refl step if present."
    "Identify a nearby natural-language or Protocol judgment that those types cannot honestly prove."
    agdaRequirement
directionLesson : BootstrapLesson
directionLesson =
  bootstrapLesson
    "direction"
    "9. Current direction and vigilance"
    "After reconstructing the model, finish at the current frontier. Purpose and the exact Roadmap feed an explicit DirectionReview; triggered reviews require fresh rationale so counters cannot silently substitute for judgment. The nearer sequence remains GV116→GV117→GV118, while P7/GV120-GV121 records the later language-neutral application direction."
    "Govenv.DirectionReview; Govenv.Roadmap; Govenv.Project; GV110; GV111; GV112; GV120; GV121"
    "Govenv.Project; Govenv.Roadmap; Govenv.DirectionReview; Govenv.Assurance.GV110; Govenv.Assurance.GV111"
    "State the current nearer Next sequence and the later P7 direction, then explain why changing either requires a real Purpose/Direction review rather than only incrementing a witness."
    "Trace the governed inputs consumed by DirectionReview and the index/rationale fields used to establish review freshness."
    "Explain why changing only a review index cannot satisfy the current assurance when the review trigger fires."
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
bootstrapRequirements = lessonRequirements bootstrapLessons

bootstrapComplete : Bool
bootstrapComplete =
  allLessonsEvidenced bootstrapLessons evidence
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

reviewSurfaceBoundary : String
reviewSurfaceBoundary = "2674f71092aff25891b36fc9b24f1034d68659da"

reviewSurfaceRequirement : LearningRequirement
reviewSurfaceRequirement =
  learningRequirement
    "Review the semantically load-bearing code and assurance surface for each learning lesson before its evidence may reduce debt, while keeping curriculum quality as Protocol judgment and never claiming to prove understanding."
    reviewSurfaceBoundary

stackedCandidateBoundary : String
stackedCandidateBoundary = "6e68a11e4d2c89cf3c747c34667a87d21c80cf35"

stackedCandidateRequirement : LearningRequirement
stackedCandidateRequirement =
  learningRequirement
    "Explain the difference between candidate-to-candidate composition and authorization-boundary merge: stacked candidates must refresh and preserve learning requirements, while only a candidate targeting the governed authorized branch is subject to the hard debt-closure gate and can create an AuthorizedRevision."
    stackedCandidateBoundary
gateSemanticsLesson : BootstrapLesson
gateSemanticsLesson =
  bootstrapLesson
    "candidate-gate"
    "10. Candidate learning boundary"
    "After the historical baseline, learn the boundary introduced by the candidate gate: classification remains human-reviewable Protocol judgment while the resulting gate is governed and machine-checked."
    "Govenv.Learning; Govenv.Kernel.Learning; GV122"
    "Govenv.Kernel.Learning.candidateLearningAllowed; Govenv.Learning.assessment; src/Govenv/Adapter/LearningCandidateVigilance.agda; src/Govenv/Adapter/learning-candidate-gate.sh; Govenv.Assurance.GV122"
    "Explain why candidate learning classification remains a Protocol judgment while the resulting PR and release gates are governed."
    "Trace a substantive PR from learning snapshot fields through assessment vigilance and candidateAllowed to the CI success or failure boundary."
    "Identify which parts are machine-checked and which classification or rationale quality remains Protocol judgment."
    gateSemanticsRequirement
bypassDebtLesson : BootstrapLesson
bypassDebtLesson =
  bootstrapLesson
    "bypass-debt"
    "11. Corrective bypass debt"
    "Urgent corrective work may restore a broken enforcement boundary before learning is complete, but that exception must not silently erase what the human still needs to learn."
    "Govenv.Learning; Govenv.Kernel.Learning; GV119; GV122"
    "Govenv.Kernel.Learning.candidateLearningAllowed; Govenv.Learning.outstanding; Govenv.Assurance.GV119; Govenv.Assurance.GV122"
    "Explain why an urgent corrective bypass preserves learning debt and therefore blocks later conceptual expansion until catch-up closes it."
    "Follow the urgentCorrective branch and show how unsatisfied requirements remain represented in outstanding debt."
    "Show why a later feature or refactor cannot reuse that bypass to proceed while the debt remains open."
    bypassDebtRequirement
bootstrapMechanicsLesson : BootstrapLesson
bootstrapMechanicsLesson =
  bootstrapLesson
    "bootstrap-mechanics"
    "12. Bootstrap reconstruction"
    "The from-zero path is a pinned Protocol-curated reconstruction of effective semantics, not a replay of every historical commit. It joins the prospective debt model instead of creating a weaker parallel authority."
    "Govenv.Learning; Govenv.LearningEvidence; GV123"
    "Govenv.Learning.bootstrapLessons/outstanding; Govenv.LearningEvidence; src/Govenv/Adapter/learning-answer.sh; src/Govenv/Adapter/learning-candidate-gate.sh; Govenv.Assurance.GV123"
    "Explain why from-zero bootstrap is a pinned Protocol-curated baseline, why it teaches effective semantics rather than replaying every historical commit, and why outstanding debt is derived from bootstrap plus carried debt minus human evidence."
    "Trace one bootstrap lesson from governed curriculum rendering to exact human evidence and then to evidence-only debt reduction."
    "Explain why an evidence-only PR must reduce debt and why unrelated semantic changes make that path invalid."
    bootstrapMechanicsRequirement
reviewSurfaceLesson : BootstrapLesson
reviewSurfaceLesson =
  bootstrapLesson
    "review-surface"
    "13. Review-surface-bound learning"
    "Human review exposed that a semantic-only answer could reduce learning debt without the principal inspecting the semantically load-bearing code or assurance that carries the guarantee. Learning progress now binds evidence to an explicit review contract."
    "Govenv.Learning; Govenv.LearningEvidence; Govenv.Assurance.GV123; GV124"
    "Govenv.Learning.reviewContract/lessonEvidenced; Govenv.LearningEvidence; src/Govenv/Projection/LearningPromptCatalog.agda; src/Govenv/Adapter/learning-answer.sh; Govenv.Assurance.GV124"
    "Explain why a semantic-only answer is insufficient evidence for a lesson whose purpose is to make the principal capable of reviewing current effective semantics."
    "Trace how a lesson's review contract is rendered, captured, matched against evidence, and then used to derive outstanding debt."
    "Explain what the compiler can prove about review-contract freshness and what remains human judgment about whether the response demonstrates adequate understanding."
    reviewSurfaceRequirement

stackedCandidateLesson : BootstrapLesson
stackedCandidateLesson =
  bootstrapLesson
    "stacked-candidates"
    "14. Candidate composition and authorization"
    "Stacked pull requests exposed that the learning gate was treating every PR base as if it were already an authorization boundary. Candidate composition must remain reviewable and testable while preserving learning debt; only the governed authorized branch may turn a human merge into semantic authority."
    "Govenv.Authorization; Govenv.Kernel.Learning; Govenv.Materialization.Github.Workflows.Test; GV122; GV125"
    "Govenv.Authorization.PullRequestTarget/HumanPullRequestMerge/AuthorizedRevision; Govenv.Kernel.Learning.candidateCompositionAllowed/candidateBoundaryAllowed; src/Govenv/Adapter/LearningCandidateVigilance.agda; src/Govenv/Adapter/learning-candidate-gate.sh; Govenv.Materialization.Github.Workflows.Test; Govenv.Assurance.GV125; Govenv.Assurance.GV125.Counterexample.StackedPullRequestHardGate"
    "Explain why unresolved learning may block authorization without blocking candidate-to-candidate composition, and why evidence present only in an unmerged parent remains candidate state rather than authorized learning."
    "Trace github.event.pull_request.base.sha/base.ref through the Test workflow and learning adapter to candidateComposition versus authorizationBoundary, then show what changes when a stacked PR is retargeted to the authorized branch."
    "Show why composition still rejects lost requirements, why the same open debt is rejected at the authorization boundary, and why a merge to candidateTarget cannot construct AuthorizedRevision."
    stackedCandidateRequirement
carriedLessons : List BootstrapLesson
carriedLessons =
    gateSemanticsLesson
  ∷ bypassDebtLesson
  ∷ bootstrapMechanicsLesson
  ∷ reviewSurfaceLesson
  ∷ stackedCandidateLesson
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
    "Stacked PRs #62 and #63 showed that GV122 applied the authorization hard gate to candidate-to-candidate composition. GV125 separates comparison-base freshness from the authorized-branch boundary, preserves unsatisfied child requirements through composition, and keeps this new learning requirement as debt through the urgent corrective bypass."
    (stackedCandidateRequirement ∷ [])
    urgentCorrective
    2

carriedDebt : LearningDebt
carriedDebt = lessonRequirements carriedLessons

outstanding : LearningDebt
outstanding =
  pendingLessonRequirements allLearningPrompts evidence

assessmentRequirementsClosed : Bool
assessmentRequirementsClosed =
  allRequirementsEvidencedByLessons
    (CandidateLearningAssessment.requirements assessment)
    allLearningPrompts
    evidence

assessmentRequirementsPreserved : Bool
assessmentRequirementsPreserved =
  allRequirementsRepresentedByLessons
    (CandidateLearningAssessment.requirements assessment)
    allLearningPrompts
    evidence
    outstanding

candidateComposable : Bool
candidateComposable =
  candidateCompositionAllowed
    (CandidateLearningAssessment.kind assessment)
    (CandidateLearningAssessment.impact assessment)
    (requirementsPresent
      (CandidateLearningAssessment.requirements assessment))
    assessmentRequirementsClosed
    assessmentRequirementsPreserved
    (CandidateLearningAssessment.bypass assessment)

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

[executed on device: solo098 (ee17d3e4-8041-4f18-9fe7-4f36099458e3)]

[executed on device: solo098 (ee17d3e4-8041-4f18-9fe7-4f36099458e3)]

[executed on device: solo098 (ee17d3e4-8041-4f18-9fe7-4f36099458e3)]