# GLP-1 Obesity Evidence Toolkit

**Market positioning determines trial design.** This repository is a small,
fully reproducible R project inspired by how CROs and biostatistics
consultancies pitch obesity-drug development strategy to sponsors
(see [Parexel's *"Navigating to 2030"* playbook](https://www.parexel.com/insights/playbook/navigating-to-2030-a-playbook-for-differentiating-next-generation-obesity-therapies),
[Certara's CODEX GLP-1 outcomes database](https://www.certara.com/fact-sheet/weight-loss-glp-1-clinical-outcomes-database-fact-sheet/),
and [IQVIA's obesity therapeutics coverage](https://www.iqvia.com/blogs/2026/02/obesity-clinical-trials)).
It turns that pitch into code: given the GLP-1 / dual-agonist obesity
landscape, (1) how large does a Phase 3 confirmatory trial actually need to
be, and (2) where would a candidate rank against the drugs already on the
market, based on publicly reported trial results?


## What's here

```
data/
  glp1_trials_armlevel.csv     Arm-level results from 4 public Phase 3 trials
R/
  sample_size.R                Efficacy-driven vs. FDA-safety-floor sample size
  nma_helpers.R                From-scratch contrast-based (GLS) network meta-analysis
analysis/
  01_sample_size_scenarios.R   Sample-size scenario grid, script + console output
  02_nma_analysis.R            NMA: forest plot, league table, SUCRA ranking
  report.Rmd                   Knits the two analyses into one HTML report
shiny/
  app.R                        Interactive sample-size calculator + NMA explorer
```

## Quick start

```r
# from the repository root
install.packages(c("shiny", "ggplot2", "rmarkdown", "DT", "MASS"))  # if needed

# 1. Sample size scenarios (console output)
source("R/sample_size.R")
plan_sample_size(delta = 8, sd = 10, power = 0.9, ratio = 2, dropout = 0.2)
scenario_table()

# 2. Network meta-analysis (console output + plots)
Rscript analysis/02_nma_analysis.R     # or source() it interactively

# 3. Full HTML report
rmarkdown::render("analysis/report.Rmd")

# 4. Interactive app
shiny::runApp("shiny")
```

## Part A -- how big does the trial need to be?

`R/sample_size.R` compares two, usually very different, numbers:

- an **efficacy-driven** per-arm N from the standard two-sample power formula
  for a continuous endpoint, and
- the **FDA safety floor** from the 2025 draft guidance *"Obesity and
  Overweight: Developing Drugs and Biological Products for Weight
  Reduction"* ([Federal Register](https://www.federalregister.gov/documents/2025/01/08/2025-00237/obesity-and-overweight-developing-drugs-and-biological-products-for-weight-reduction-draft-guidance),
  summarized by [Medpace](https://www.medpace.com/blog/new-fda-guidance-developing-drugs-and-biological-products-for-weight-reduction/)):
  &ge;3,000 subjects exposed to the investigational drug and &ge;1,500 to
  placebo, each for &ge;1 year at the maintenance dose.

Running `scenario_table()` across a realistic range of assumed effect sizes
shows the safety floor binding in every case -- which is exactly why real
trials in this class (STEP 1: n=1,961; SURMOUNT-1: n=2,539) are sized well
above what the primary-endpoint comparison alone would require. That is the
project's one concrete, checkable claim about "how trial design decisions get
made" in this therapeutic area.

## Part B -- where does a candidate rank?

`R/nma_helpers.R` implements a fixed-effect, contrast-based network
meta-analysis (Lu & Ades graph-theoretical formulation; White 2011) from
first principles, connecting four published trials through a shared Placebo
arm and one direct head-to-head comparison:

| Trial | Comparison | Result at ~68-72 weeks | Source |
|---|---|---|---|
| STEP 1 (2021, NEJM) | Semaglutide 2.4mg vs Placebo | -14.9% vs -2.4% | [NEJM](https://www.nejm.org/doi/full/10.1056/NEJMoa2032183) |
| STEP 8 (2022, JAMA) | Semaglutide 2.4mg vs Liraglutide 3.0mg vs Placebo | -15.8% / -6.4% / -1.9% | [JAMA](https://jamanetwork.com/journals/jama/fullarticle/2787907) |
| sURMOUNT-1 (2022, NEJM) | Tirzepatide 5/10/15mg vs Placebo | -15.0% / -19.5% / -20.9% vs -3.1% | [NEJM](https://www.nejm.org/doi/full/10.1056/NEJMoa2206038) |
| SURMOUNT-5 (2025, NEJM) | Tirzepatide (MTD) vs Semaglutide 2.4mg | -20.2% vs -13.7% | [NEJM](https://www.nejm.org/doi/10.1056/NEJMoa2410819) |

Because SURMOUNT-5 provides a *direct* tirzepatide-vs-semaglutide comparison
that can be checked against the *indirect* route through Placebo, this small
network includes a genuine (if weak, with only one loop) consistency check --
the same node-splitting logic described in the project design document, just
at demo scale.

**Read `analysis/report.Rmd`'s "Limitations" section before quoting any
number from this repo** -- per-arm standard deviations are not all publicly
reported and are approximated at 10 percentage points throughout (justified
in the report); this is a fixed-effect model where the design document
specifies Bayesian random-effects; and the four trials were chosen for
network connectivity, not from a systematic search.

## Why a from-scratch NMA implementation instead of `netmeta`

`netmeta` and `gemtc` are CRAN-only and could not be installed in the
environment this repository was built in (no CRAN mirror was reachable, only
Ubuntu's `r-cran-*` apt packages). `R/nma_helpers.R` reproduces the
fixed-effect special case of the same underlying method using only base R +
MASS, so the whole repository runs with `apt install r-cran-{shiny,ggplot2,
rmarkdown,dt,metafor,dplyr,tidyr,knitr,mass}` and nothing else. If you have
full CRAN access, swap in `netmeta::netmeta()` -- see the commented block at
the end of `analysis/02_nma_analysis.R`.

## License

MIT -- see `LICENSE`. Trial data are means/estimates transcribed from public
sources (cited above and in `data/glp1_trials_armlevel.csv`); this repository
claims no rights over the underlying clinical trial results.

## Disclaimer

This is a portfolio / methodology-demonstration project, not a submission-
grade evidence package. It illustrates the statistical logic described in the
accompanying project design document using public data and simplifying
assumptions; it is not affiliated with, and does not represent the views of,
any of the companies or trials referenced above.
