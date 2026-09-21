# =============================================================================
# 01_sample_size_scenarios.R
#
# Reproduces the sample-size exhibit for a Phase 3 confirmatory obesity trial:
# compares an efficacy-driven power calculation against the FDA's 2025 draft
# guidance safety-database floor, across a range of plausible effect sizes.
#
# Run from the repository root:  Rscript analysis/01_sample_size_scenarios.R
# =============================================================================

here <- function(...) file.path(getwd(), ...)
source(here("R", "sample_size.R"))

cat("== Scenario grid: assumed placebo-adjusted weight-loss difference (pp) ==\n\n")
tab <- scenario_table(deltas = c(3, 5, 8, 10, 12, 15, 18),
                       sd = 10, power = 0.90, alpha = 0.05, ratio = 2, dropout = 0.20)
print(tab, row.names = FALSE)

cat("\n== Interpretation ==\n")
cat(sprintf(paste0(
  "For every assumed effect size tested (delta = 3 to 18 percentage points, SD = 10),\n",
  "the efficacy-driven per-arm N is smaller than the FDA's exposure floor\n",
  "(>=3000 active / >=1500 control for >=1 year). The binding constraint on final\n",
  "sample size in this drug class is therefore almost always the SAFETY database\n",
  "requirement, not the primary-endpoint power calculation -- consistent with the\n",
  "observed sizes of real Phase 3 obesity trials (STEP 1: n=1961; SURMOUNT-1: n=2539),\n",
  "which are set well above what the weight-loss comparison alone would require.\n"
)))

if (interactive() || identical(Sys.getenv("SAVE_OUTPUTS"), "1")) {
  dir.create(here("analysis", "output"), showWarnings = FALSE, recursive = TRUE)
  write.csv(tab, here("analysis", "output", "sample_size_scenarios.csv"), row.names = FALSE)
}
