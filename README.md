# GLP-1 Obesity Evidence Toolkit

An R project that works through two questions a sponsor would ask before
starting a Phase 3 obesity trial in the GLP-1 / dual-agonist space:

1. How many patients does the confirmatory trial need?
2. Based on published trial results, where would a new candidate rank
   against semaglutide, tirzepatide and liraglutide?

I got the idea from reading how CROs frame obesity development strategy for
sponsors, in particular
[Parexel's *Navigating to 2030* playbook](https://www.parexel.com/insights/playbook/navigating-to-2030-a-playbook-for-differentiating-next-generation-obesity-therapies),
[Certara's CODEX GLP-1 outcomes database](https://www.certara.com/fact-sheet/weight-loss-glp-1-clinical-outcomes-database-fact-sheet/)
and [IQVIA's obesity trials coverage](https://www.iqvia.com/blogs/2026/02/obesity-clinical-trials).
The full study design (Phase 3 RCT plus a competitor network meta-analysis)
is written up in [`project-design.md`](project-design.md). This repo has the
code that goes with it.

## Repository layout

```
project-design.md              Phase 3 RCT + NMA design document
data/
  glp1_trials_armlevel.csv     Arm-level results from 4 published Phase 3 trials
R/
  sample_size.R                Efficacy-based vs. FDA safety-exposure sample size
  nma_helpers.R                Contrast-based (GLS) network meta-analysis
analysis/
  01_sample_size_scenarios.R   Sample-size scenario grid
  02_nma_analysis.R            NMA: forest plot, league table, SUCRA
  report.Rmd                   HTML report combining both analyses
shiny/
  app.R                        Sample-size calculator + NMA explorer
```

## Quick start

```r
# from the repository root
install.packages(c("shiny", "ggplot2", "rmarkdown", "DT", "MASS"))  # if needed

# 1. Sample size scenarios
source("R/sample_size.R")
plan_sample_size(delta = 8, sd = 10, power = 0.9, ratio = 2, dropout = 0.2)
scenario_table()

# 2. Network meta-analysis
source("analysis/02_nma_analysis.R")

# 3. HTML report
rmarkdown::render("analysis/report.Rmd")

# 4. Shiny app
shiny::runApp("shiny")
```

## Part A: sample size

`R/sample_size.R` compares two numbers:

- the **efficacy-based** per-arm N from the usual two-sample power formula
  for a continuous endpoint (% change in body weight), and
- the **safety exposure requirement** in FDA's 2025 draft guidance
  *Obesity and Overweight: Developing Drugs and Biological Products for
  Weight Reduction*
  ([Federal Register](https://www.federalregister.gov/documents/2025/01/08/2025-00237/obesity-and-overweight-developing-drugs-and-biological-products-for-weight-reduction-draft-guidance);
  summary from [Medpace](https://www.medpace.com/blog/new-fda-guidance-developing-drugs-and-biological-products-for-weight-reduction/)):
  at least 3,000 participants on drug and 1,500 on placebo for 1 year or
  more at the maintenance dose.

Across every effect size in `scenario_table()`, the safety requirement is
the larger number by a wide margin. This matches what happened in practice:
STEP 1 (n = 1,961) and SURMOUNT-1 (n = 2,539) enrolled far more patients
than their primary endpoints required.

## Part B: network meta-analysis

`R/nma_helpers.R` fits a fixed-effect, contrast-based NMA (Lu & Ades 2004;
White 2011) across four trials connected through placebo, plus one direct
head-to-head comparison:

| Trial | Comparison | Weight change at ~68-72 weeks | Source |
|---|---|---|---|
| STEP 1 (2021, NEJM) | Semaglutide 2.4 mg vs Placebo | -14.9% vs -2.4% | [NEJM](https://www.nejm.org/doi/full/10.1056/NEJMoa2032183) |
| STEP 8 (2022, JAMA) | Semaglutide 2.4 mg vs Liraglutide 3.0 mg vs Placebo | -15.8% / -6.4% / -1.9% | [JAMA](https://jamanetwork.com/journals/jama/fullarticle/2787907) |
| SURMOUNT-1 (2022, NEJM) | Tirzepatide 5/10/15 mg vs Placebo | -15.0% / -19.5% / -20.9% vs -3.1% | [NEJM](https://www.nejm.org/doi/full/10.1056/NEJMoa2206038) |
| SURMOUNT-5 (2025, NEJM) | Tirzepatide (MTD) vs Semaglutide 2.4 mg | -20.2% vs -13.7% | [NEJM](https://www.nejm.org/doi/10.1056/NEJMoa2410819) |

SURMOUNT-5 compares tirzepatide and semaglutide directly, so the direct
estimate can be checked against the indirect one through placebo. With only
one closed loop this is a limited consistency check, but it follows the
node-splitting approach in the design document.

I implemented the NMA directly in base R + MASS instead of calling
`netmeta`, mainly to keep the GLS steps visible and the dependencies small.
The results can be cross-checked with `netmeta::netmeta()` using the
commented block at the end of `analysis/02_nma_analysis.R`.

### Limitations

See the Limitations section of `analysis/report.Rmd` before using any of
these numbers. In short:

- Per-arm SDs are not all published, so 10 percentage points is assumed for
  every arm (the report explains why).
- The model is fixed-effect; the design document specifies a Bayesian
  random-effects model.
- The four trials were picked to form a connected network, not from a
  systematic search.

## License

MIT, see `LICENSE`. Trial results are summary estimates taken from the
published sources listed above and in `data/glp1_trials_armlevel.csv`.

## Disclaimer

This is a portfolio project that demonstrates methods on public data with
simplifying assumptions. It is not a regulatory-grade evidence package and
is not affiliated with any of the companies or trials mentioned.
