# Project Design: Phase 3 Pivotal Trial and Competitor Network Meta-Analysis for a GLP-1 Obesity Therapy

2026-09-20 · Project Lead: Sue

## Project Overview

This project designs a "dual-track evidence generation" plan for a candidate GLP-1 receptor agonist (or GLP-1/GIP dual-agonist) in the obesity indication. Track 1 is a Phase 3 confirmatory randomized controlled trial (RCT) supporting regulatory registration; Track 2 is a competitor network meta-analysis (NMA) aimed at payer/reimbursement negotiations. The two tracks advance in parallel and are evidentially complementary: the RCT addresses the internal-validity question of "is the drug efficacious and safe," while the NMA addresses the external-comparison question of "how does it rank against existing and pipeline competitors." Together they support the full evidence chain from FDA/NMPA registration through post-launch reimbursement negotiations.

I serve as Lead Biostatistician / Statistical Consultant on this project, responsible for statistical methodology design, SAP authorship, NMA methodological oversight, and cross-functional coordination with the clinical, regulatory affairs, and HEOR teams. The target indication is long-term weight management in adults with obesity/overweight and at least one weight-related comorbidity.

| Dimension | Part A: Phase 3 Pivotal RCT | Part B: Network Meta-Analysis |
|---|---|---|
| Evidence type | Internal validity (prospective randomized comparison) | External comparison (indirect comparison, evidence synthesis) |
| Core question | Is the drug superior to placebo and safe? | How does the drug rank in relative efficacy against competitors? |
| Primary use | FDA/NMPA registration submission | Reimbursement access, payer value proposition (HEOR), academic publication |
| Timeline | ~30–36 months (including 68-week treatment period + follow-up) | ~6–9 months (can proceed in parallel with RCT data, post-unblinding) |
| Key outputs | CSR; efficacy/safety conclusions under the Estimand framework | SUCRA ranking plots, indirect comparison effect sizes, HTA evidence package |

## Background and Rationale

GLP-1 receptor agonists have become the dominant drug class in obesity treatment. Approved products include once-weekly semaglutide 2.4mg (Novo Nordisk, Wegovy) and tirzepatide (Eli Lilly, Zepbound, a GLP-1/GIP dual agonist). In the pipeline, the oral small-molecule GLP-1 agonist orforglipron (Eli Lilly, Phase 3 ATTAIN-1, ~14.7% weight reduction at 72 weeks), the GLP-1/GIP/glucagon triple agonist retatrutide (Eli Lilly, Phase 2, ~24% reduction at 48 weeks), the GLP-1/amylin dual agonist CagriSema (Novo Nordisk, Phase 3 REDEFINE-1, ~22% reduction at 68 weeks), and the once-monthly MariTide (Amgen, Phase 2, ~20% reduction at 52 weeks) are all in Phase 3 or pre-submission stages, with approvals anticipated through 2026–2027 (figures are third-party pipeline-tracker approximations as of April 2026; see the [GLP-1 Pipeline Tracker](https://www.weightsherpa.com/pipeline) for details). Competition in this space has shifted from "does it work" to a multidimensional contest over magnitude of effect, dosing convenience (oral vs. injectable, weekly vs. monthly), and safety/tolerability alongside long-term cardiometabolic benefit.

On the regulatory front, the FDA issued a draft industry guidance in January 2025, *"Obesity and Overweight: Developing Drugs and Biological Products for Weight Reduction"* ([Federal Register original](https://www.federalregister.gov/documents/2025/01/08/2025-00237/obesity-and-overweight-developing-drugs-and-biological-products-for-weight-reduction-draft-guidance); [Medpace summary](https://www.medpace.com/blog/new-fda-guidance-developing-drugs-and-biological-products-for-weight-reduction/)). Key changes include:

1. Total trial duration must exceed 1 year (including a dose-titration period and at least a 1-year maintenance period).
2. The primary endpoint remains centered on percent change in body weight (continuous), but the guidance recommends also reporting responder analyses at 5%/10%/15% weight-loss thresholds, while cautioning that such categorical endpoints may overstate efficacy.
3. Inclusion criteria are broadened to BMI ≥30 kg/m² (with adequate representation of the BMI ≥40 severe-obesity subgroup) or BMI ≥27 kg/m² with at least one weight-related comorbidity; the pediatric enrollment age floor is lowered to 6 years.
4. Safety database requirements call for ≥3,000 subjects on active treatment and ≥1,500 on placebo who have completed at least 1 year at the maintenance dose.
5. Missing-data handling should favor Multiple Imputation over Last Observation Carried Forward (LOCF), with a Treatment Policy Estimand as the default.

This regulatory shift directly shapes the endpoint hierarchy, sample-size assumptions, and statistical analysis strategy for the Phase 3 trial in this project (see Part A). At the same time, because head-to-head trials among competitors remain scarce despite the crowded competitive field, indirect-comparison evidence (NMA) becomes an indispensable complement to support product positioning and payer negotiations.

## Project Objectives and Overall Design Strategy

**Overall objective:** Within 24 months, complete unblinding of the key data from a Phase 3 confirmatory RCT and, in parallel, produce a network meta-analysis evidence package suitable for reimbursement/HTA submission — together forming a complete evidence chain from regulatory registration to market access for the candidate drug.

**Specific objectives:**

1. Confirm, via the Phase 3 RCT, the candidate drug's superiority over placebo in 52/68-week weight reduction, responder proportions, and cardiometabolic markers, meeting the efficacy and safety evidence requirements for FDA/NMPA registration.
2. Quantify, via the NMA, the candidate drug's indirect-comparison efficacy and safety ranking relative to semaglutide, tirzepatide, oral GLP-1 agents, and next-generation triple agonists, to support product differentiation.
3. Establish a unified statistical methodology governance framework (Estimand consistency, endpoint-definition consistency) so that the evidence produced by Part A and Part B corroborates rather than conflicts with itself across regulatory communications and payer materials.

**Target population definition:** Adults (≥18 years) with BMI ≥30 kg/m², or BMI ≥27 kg/m² with at least one weight-related comorbidity (prediabetes, hypertension, dyslipidemia, obstructive sleep apnea); excluding subjects with an established diagnosis of type 2 diabetes (reserved for a separate indication study), a recent history of bariatric surgery, or an endocrine cause of obesity.

**Design synergy logic:** Patient-level data (IPD) from Part A will serve as the "anchor trial" for this product's arm in the NMA, ensuring the two tracks are as comparable as possible in population characteristics and endpoint definitions, thereby improving the internal consistency of the indirect comparisons (see Part B feasibility assessment).

## Part 1 — Phase 3 Pivotal Registration Trial Design

### Study Design Overview

| Element | Design choice |
|---|---|
| Design type | Multicenter, randomized, double-blind, placebo-controlled, parallel-group Phase 3 confirmatory trial |
| Randomization ratio | Active drug : Placebo = 2:1 (increases safety database exposure to meet the FDA's ≥3,000-subject exposure requirement) |
| Treatment duration | 4-week dose-titration period + 68-week maintenance period, 72 weeks total, plus a 4-week safety follow-up |
| Stratification factors | Baseline BMI (<35 / ≥35 kg/m²), prediabetes status, region |
| Concomitant intervention | A uniform lifestyle-intervention (diet + exercise counseling) background, identical across both arms |
| Primary sites / regions | Global multiregional clinical trial (MRCT) spanning North America, Europe, China, and Asia-Pacific, supporting simultaneous global submission |

### ICH E9(R1) Estimand Framework

The **Treatment Policy Strategy** is adopted as the intercurrent-event handling strategy for the primary Estimand, consistent with the FDA's 2025 draft guidance recommendation:

- **Population:** All subjects who meet eligibility criteria and undergo randomization (ITT population)
- **Variable:** Percent change in body weight from baseline at Week 68
- **Intercurrent events and handling strategies:**
  - Early discontinuation of study drug with continued follow-up → Treatment policy strategy (post-discontinuation data included)
  - Withdrawal due to bariatric surgery or pregnancy → Composite variable strategy (counted as treatment failure regardless of subsequent weight change)
  - Use of prohibited concomitant medication (e.g., another weight-loss drug) → Treatment policy strategy
- **Summary measure:** Least-squares mean difference (LS Mean Difference) between arms in Week-68 percent weight change, with 95% CI

A supplementary **Hypothetical Strategy Estimand** is designed as a key secondary analysis, estimating the effect under the scenario "if subjects had remained adherent to treatment and had not used prohibited medications," to inform clinical discussion and product labeling.

## Endpoint Hierarchy and Sample Size Estimation

### Endpoint Hierarchy

**Primary endpoint:** Percent change in body weight from baseline at Week 68 (continuous)

**Key secondary endpoints (ranked by multiplicity testing hierarchy):**

1. Proportion of subjects achieving ≥5% weight loss at Week 68 (responder analysis)
2. Proportion of subjects achieving ≥10% weight loss at Week 68
3. Proportion of subjects achieving ≥15% weight loss at Week 68
4. Change in waist circumference from baseline at Week 68
5. Change in systolic blood pressure from baseline at Week 68
6. Change in fasting glucose and HbA1c from baseline at Week 68 (prediabetes subgroup)
7. Patient-reported outcome: change in Impact of Weight on Quality of Life (IWQOL-Lite) score

**Exploratory endpoints:** Change in obstructive sleep apnea AHI index, change in physical function scale scores (aligned with the FDA's newly added "fit-for-purpose" clinical outcome assessment requirements).

### Sample Size Estimation

| Parameter | Assumption |
|---|---|
| Primary endpoint effect size | Between-arm difference of −8.0% (active vs. placebo), SD 9.0% |
| Test method | Two-sided t-test approximation, α=0.05 |
| Target power | 90% |
| Expected dropout rate | 20% (68-week long treatment duration) |
| Randomization ratio | 2:1 |
| Estimated completers required | ~270 per arm (placebo) / 540 (active), ~810 completers total |
| Enrollment target after accounting for dropout | ~1,020 total (680 active arm, 340 placebo arm) |

Safety database exposure: since the active arm already reaches 680 subjects with full 68-week exposure, meeting the FDA guidance's suggestion of "≥3,000 subjects with 1-year exposure" will require pooling exposure data through a long-term open-label extension study or across other indication studies (e.g., an already-approved T2D indication population); the pooled-exposure analysis plan should be described in the SAP.

## Statistical Analysis Plan (SAP) Highlights

**Analysis population definitions:**

- ITT population: All randomized subjects who received at least one dose of study drug, used for the primary and key secondary endpoint analyses
- PP population: Subjects who completed 68 weeks of treatment with ≥80% protocol adherence, used for sensitivity analysis of the Hypothetical Strategy Estimand
- Safety population: All subjects who received at least one dose of study drug

**Missing data handling strategy:** The primary analysis uses a Multiple Imputation (MI)-based method to handle missing weight data — subjects who discontinued treatment but remain in the study are imputed using their own observed data (consistent with the treatment policy strategy); subjects with complete loss to follow-up are conservatively imputed using Jump-to-Reference (J2R), serving as a sensitivity check for the primary analysis.

**Multiplicity control strategy:** A graphical testing procedure (Bretz et al.) is used to control the family-wise error rate across the 7 key secondary endpoints, allocating α=0.05 between the primary endpoint and each key secondary endpoint according to pre-specified weights and propagation rules, ensuring the overall Type I error rate is controlled.

**Primary model:** Mixed-effects Model for Repeated Measures (MMRM), with covariates including baseline weight, stratification factors (baseline BMI group, prediabetes status, region), visit, and treatment × visit interaction; an unstructured covariance matrix is used.

**Analysis of key secondary (binary responder) endpoints:** Cochran-Mantel-Haenszel test or logistic regression, adjusted for stratification factors.

## Interim Analysis, DSMB, and Subgroup/Sensitivity Analyses

**Independent Data Safety Monitoring Board (DSMB):** A DSMB independent of the sponsor is established to periodically review unblinded safety data, meeting every 6 months, with a focus on:

- Incidence and severity of gastrointestinal adverse events (nausea, vomiting, diarrhea)
- Signals of thyroid C-cell hyperplasia/medullary carcinoma (based on background rodent toxicology signals)
- Incidence of acute pancreatitis
- Suicidal ideation/behavior (Columbia-Suicide Severity Rating Scale, C-SSRS)
- Gallbladder/biliary tract disease events

**Interim analysis:** A single interim analysis is conducted at approximately 50% information fraction, using an O'Brien-Fleming alpha-spending function to control the overall Type I error rate across the interim and final analyses; the interim analysis evaluates only a futility-stopping boundary, with no early stopping for superiority, in order to protect the long-term accumulation of complete safety data.

**Subgroup analyses:** Pre-specified subgroups include baseline BMI stratum (30–<35 / 35–<40 / ≥40 kg/m²), prediabetes status, age stratum (18–64 / ≥65 years), sex, and race/region, presented via forest plots showing treatment effects and interaction test p-values within each subgroup (for exploring consistency only, not for confirmatory inference).

**Sensitivity analyses:** Include (1) a PP-population analysis under the Hypothetical Strategy Estimand; (2) an analysis excluding data from periods of COVID-19 pandemic impact or major protocol deviation; and (3) multiple-robustness testing across different missing-data imputation methods (MI vs. J2R vs. extreme-scenario imputation).

## Part 2 — Network Meta-Analysis Design

### Research Question and PICOS Framework

| Element | Definition |
|---|---|
| Population (P) | Adults with obesity/overweight and a weight-related comorbidity, BMI ≥27 kg/m² |
| Intervention (I) | Candidate drug (trial dose) |
| Comparators (C) | Semaglutide 2.4mg, tirzepatide 5/10/15mg, orforglipron, CagriSema, MariTide, placebo, conventional weight-loss agents (orlistat, naltrexone/bupropion) |
| Outcomes (O) | Percent weight change at Week 68, ≥5%/10%/15% responder rates, incidence of gastrointestinal adverse events, treatment discontinuation rate |
| Study design (S) | Randomized controlled trials (RCTs), duration ≥52 weeks |

### Systematic Search and Evidence Network Feasibility

A systematic search will cover PubMed, Embase, Cochrane CENTRAL, and major regulatory-agency review documents (FDA drug review packages, EMA EPARs), supplemented by a ClinicalTrials.gov search for ongoing Phase 3 trial data; no start-date limit is applied to the search, with a cutoff 3 months before analysis initiation.

**Evidence network feasibility / heterogeneity assessment points:**

- Assess the comparability of baseline characteristics (baseline BMI, prediabetes proportion, regional distribution) across included trial populations, identifying potential effect modifiers
- Assess whether a closed evidence loop exists among the comparator drugs, and identify whether placebo is needed as a common comparator arm linking the direct comparisons
- Because head-to-head trials are scarce, most comparisons in the network are expected to be indirect, requiring a pre-specified justification of the transitivity assumption at the protocol stage

## NMA Statistical Methodology and Outputs

**Model selection:** A Bayesian hierarchical random-effects NMA is adopted, with the posterior distribution estimated via Markov Chain Monte Carlo (MCMC); weakly informative priors are used for treatment effect parameters, and half-normal or uniform priors are used for the heterogeneity variance parameter, with accompanying sensitivity analyses.

**Consistency checking:** For comparisons within closed loops, node-splitting is used to test the consistency of direct and indirect evidence; overall inconsistency is assessed using a design-by-treatment interaction model.

**Key outputs:**

- Pairwise indirect-comparison effect sizes between all drugs (mean difference in weight change with 95% credible intervals)
- SUCRA (Surface Under the Cumulative Ranking curve) plots, showing the probability of the candidate drug's ranking relative to all comparators across efficacy and safety dimensions
- Forest plots showing direct/indirect comparison results of the candidate drug versus each comparator
- Ranking-vs-efficacy scatter plots (illustrating the efficacy-vs-tolerability trade-off)

**Evidence package design for HTA submission:** Following the NICE DSU (Decision Support Unit) TSD series of methodological guidance and the ISPOR-AMCP-NPC good practice principles for indirect comparisons, outputs are tailored to the technical requirements of the primary target markets (e.g., UK NICE, Canadian CADTH, China's NMPA/National Healthcare Security Administration) for indirect-comparison evidence, including a complete evidence network diagram, a heterogeneity/inconsistency diagnostic report, and a methodological transparency statement.

## Integration of the Two Evidence Tracks and Strategic Value

Part A (RCT) and Part B (NMA) are not two isolated projects but a progressive evidence chain running from "internal validity" to "external relative positioning":

**Regulatory submission stage (FDA/NMPA):** The RCT provides the pivotal efficacy and safety evidence supporting approval; the NMA is included as background material (non-confirmatory evidence) in the clinical overview, helping regulators understand the candidate drug's relative positioning among similar products — particularly providing supportive argumentation for labeling-language requests (e.g., "efficacy magnitude comparable to/superior to a given drug class").

**Reimbursement access and payer negotiation stage (HEOR):** In the absence of head-to-head trials, most payers rely on NMA-derived indirect-comparison effect sizes as efficacy inputs for economic models (e.g., cost-effectiveness analysis, budget impact models). The effect sizes produced by this project's NMA will feed directly into subsequent health economics models, supporting key arguments in value proposition materials such as "weight loss per unit of spend."

**Academic publication and market education:** The RCT's primary results are planned for submission to top-tier journals such as NEJM/Lancet/JAMA; the NMA results are suitable for submission to specialty journals such as *Diabetes, Obesity and Metabolism* and *Obesity*, and can be developed by the Medical Affairs team into evidence materials for academic conferences (ADA, EASD, ObesityWeek).

**Risk note:** The persuasiveness of the NMA's conclusions depends heavily on whether the transitivity assumption underlying the evidence network holds. If competitor trial populations differ substantially (e.g., BMI thresholds in Asian populations differing from those in Western populations), subgroup network meta-analyses or meta-regression adjustments should be planned in advance in the protocol, with limitations clearly flagged in the interpretation of results, to avoid misleading "superior efficacy" claims that could invite regulatory or academic methodological challenge.

## Team Structure, Timeline, and Risk Management

### Team Structure

| Role | Responsibilities |
|---|---|
| Lead Biostatistician / Statistical Consultant (myself) | Statistical methodology design, SAP/NMA analysis plan authorship, cross-functional coordination, regulatory communication support |
| Statistical Programmer | SDTM/ADaM dataset programming, TLF production, CDISC compliance |
| Clinical Trial Physician | Protocol medical content, safety event adjudication, DSMB communication |
| Epidemiologist / HEOR Lead | NMA evidence search and screening, health economics model integration |
| Regulatory Affairs Lead | FDA/NMPA communication strategy, guidance compliance review |
| Medical Writer | Protocol, CSR, and manuscript authorship |
| Data Management Lead | EDC system, data quality review, database lock |

### Key Milestones

| Milestone | Timing |
|---|---|
| Protocol and SAP finalized | Months 1–3 |
| First patient in (FPI) | Month 4 |
| NMA systematic search initiated | Month 4 (in parallel with the RCT) |
| Last patient in (LPI) | Month 12 |
| Interim analysis (~50% information fraction) | Month 16 |
| Last patient completes Week-68 follow-up (LPLV) | Month 20 |
| Database lock | Month 21 |
| Primary analysis unblinding and NMA evidence package finalized | Month 22 |
| CSR finalized and regulatory submission | Month 24 |

### Key Risks and Mitigations

| Risk | Mitigation strategy |
|---|---|
| Enrollment lagging behind schedule (intense competitive recruitment in the obesity space) | Establish multiregional sites early; expand collaborations with eligible-patient databases; monitor competitor trial recruitment intelligence |
| Dropout rate exceeding expectations, undermining statistical power | Build in sample-size margin for a 20% dropout rate at the design stage; strengthen subject retention measures (remote follow-up, patient support programs) |
| Failure of the NMA evidence network's transitivity assumption | Pre-specify subgroup NMA and meta-regression sensitivity analyses; proactively discuss methodological limitations with key opinion leaders (KOLs) and regulators |
| A competitor gaining approval ahead of schedule and reshaping the competitive landscape during the project timeline | Maintain a dynamic-update mechanism for the NMA evidence network (a "living NMA"), refreshing included studies every 6 months |
| Further revision of the FDA guidance during the project timeline | Maintain a quarterly communication cadence with the regulatory affairs team; retain flexibility for protocol amendments |

## Deliverables

| Deliverable | Phase | Purpose |
|---|---|---|
| Clinical Trial Protocol | Part A initiation | IRB/ethics committee and regulatory filing |
| Statistical Analysis Plan (SAP) | Finalized before Part A start | Guides the confirmatory analysis after database lock |
| NMA Analysis Plan | Finalized before Part B start | Guides the systematic review and indirect-comparison analysis |
| TLF Shells (table, listing, and figure templates) | Before database lock | Statistical programming and QC baseline |
| Clinical Study Report (CSR) | Part A completion | Core regulatory submission document |
| NMA technical report / publication manuscript | Part B completion | HTA submission, academic publication |
| Health economics model efficacy input package | After Part B completion | Feeds the HEOR team's budget-impact/cost-effectiveness models |

### References

- [Obesity and Overweight: Developing Drugs and Biological Products for Weight Reduction; Draft Guidance (Federal Register, 2025-01-08)](https://www.federalregister.gov/documents/2025/01/08/2025-00237/obesity-and-overweight-developing-drugs-and-biological-products-for-weight-reduction-draft-guidance)
- [New FDA Guidance: Developing Drugs and Biological Products for Weight Reduction — Medpace summary](https://www.medpace.com/blog/new-fda-guidance-developing-drugs-and-biological-products-for-weight-reduction/)
- [GLP-1 Pipeline 2026: Retatrutide, Orforglipron, CagriSema, MariTide Tracker — WeightSherpa](https://www.weightsherpa.com/pipeline)

Note: The efficacy percentages cited above are approximations aggregated by a third-party pipeline-tracking tool (as of April 2026), provided for background context only; actual citations should rely on each product's official prescribing information or regulatory review documents.
