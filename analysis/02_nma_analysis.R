# =============================================================================
# 02_nma_analysis.R
#
# Network meta-analysis of published GLP-1 / dual-agonist obesity trials:
# percent body weight change from baseline at ~68-72 weeks.
#
# Data: data/glp1_trials_armlevel.csv (arm-level means, curated from public
# trial reports; see the "source_url" column and README.md for full citations
# and the standard-deviation assumption used).
#
# Run from the repository root:  Rscript analysis/02_nma_analysis.R
# =============================================================================

here <- function(...) file.path(getwd(), ...)
source(here("R", "nma_helpers.R"))
suppressPackageStartupMessages(library(ggplot2))

armdata <- read_armdata(here("data", "glp1_trials_armlevel.csv"))
net <- build_network(armdata, reference = "Placebo")
fit <- fit_nma(net)

cat("== Network structure ==\n")
print(net$row_labels)

cat("\n== Treatment effects vs Placebo (percentage points; negative = more weight loss) ==\n")
fd <- forest_data(fit)
print(fd, row.names = FALSE, digits = 3)

cat(sprintf("\n== Global consistency check (design-by-treatment) ==\nQ = %.2f on %d df, p = %.3f (non-significant p is reassuring, not confirmatory)\n",
            fit$Q, fit$df, fit$Q_pvalue))

cat("\n== League table (row minus column, 95% CI) ==\n")
print(league_table(fit), quote = FALSE)

cat("\n== SUCRA ranking (probability-weighted rank; 1 = best) ==\n")
sc <- sucra(fit)
print(sc, row.names = FALSE, digits = 3)

# ---- Forest plot ------------------------------------------------------------
fd$treatment <- factor(fd$treatment, levels = fd$treatment[order(fd$estimate)])
p_forest <- ggplot(fd, aes(x = estimate, y = treatment)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.15) +
  geom_point(size = 2.5) +
  labs(x = "% body weight change vs Placebo (percentage points, 95% CI)",
       y = NULL,
       title = "Network meta-analysis: weight change vs Placebo at ~68-72 weeks",
       caption = "Fixed-effect GLS network model; see README.md for data sources and assumptions") +
  theme_minimal(base_size = 12)

# ---- SUCRA bar chart ---------------------------------------------------------
sc$treatment <- factor(sc$treatment, levels = sc$treatment[order(sc$sucra)])
p_sucra <- ggplot(sc, aes(x = sucra, y = treatment)) +
  geom_col(fill = "#3B6E8F") +
  scale_x_continuous(limits = c(0, 1), labels = scales::percent_format(accuracy = 1)) +
  labs(x = "SUCRA (higher = more likely to rank among the best for weight loss)",
       y = NULL,
       title = "Ranking of GLP-1 / dual-agonist therapies by SUCRA") +
  theme_minimal(base_size = 12)

if (interactive() || identical(Sys.getenv("SAVE_OUTPUTS"), "1")) {
  dir.create(here("analysis", "output"), showWarnings = FALSE, recursive = TRUE)
  ggsave(here("analysis", "output", "forest_plot.png"), p_forest, width = 7, height = 4, dpi = 150)
  ggsave(here("analysis", "output", "sucra_plot.png"), p_sucra, width = 7, height = 4, dpi = 150)
  write.csv(fd, here("analysis", "output", "nma_forest_data.csv"), row.names = FALSE)
  write.csv(sc, here("analysis", "output", "nma_sucra.csv"), row.names = FALSE)
}

# -----------------------------------------------------------------------------
# Optional: if you have full CRAN access, cross-check against netmeta::netmeta()
# -----------------------------------------------------------------------------
# if (requireNamespace("netmeta", quietly = TRUE)) {
#   library(netmeta)
#   pw <- pairwise(treat = treat_label, n = n, mean = weight_pct_change_mean,
#                   sd = sd_assumed, studlab = study, data = armdata, sm = "MD")
#   nm <- netmeta(pw, reference.group = "Placebo", common = TRUE, random = TRUE)
#   print(summary(nm))
#   netrank(nm, small.values = "good")  # note: sign convention differs, adjust
# }
