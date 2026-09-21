# =============================================================================
# nma_helpers.R
#
# A small, dependency-light implementation of contrast-based (frequentist,
# common-effect) network meta-analysis, built with base R + MASS, following
# the graph-theoretical / multivariate-regression formulation described in
# Lu & Ades (2004) and White (2011, "Multivariate random-effects
# meta-regression").
#
# WHY A CUSTOM IMPLEMENTATION: the project design document (Part B) specifies
# a Bayesian hierarchical random-effects NMA fitted with dedicated software
# (netmeta / gemtc / WinBUGS-style MCMC). Those packages are CRAN-only and
# were not installable in this environment's offline build (no CRAN mirror
# reachable). The functions below reproduce the *fixed-effect* special case
# of the same methodology from first principles using arm-level trial data,
# so the repository is fully reproducible without any restricted network
# access. If netmeta is available in your own R installation, swap it in --
# see the commented block at the bottom of analysis/02_nma_analysis.R.
#
# METHOD
#   For every trial, one arm is designated the study's own reference arm
#   (is_study_baseline == TRUE in the data). Every other arm in that trial
#   contributes one contrast (its mean minus the reference arm's mean).
#   Contrasts from a multi-arm trial share the same reference arm and are
#   therefore correlated (they share the reference arm's sampling error);
#   the covariance is accounted for explicitly (White 2011).
#   A single treatment is chosen as the *network* reference (Placebo here).
#   Each contrast is expressed as (d_comparator - d_baseline) where d_k is
#   the treatment effect of treatment k versus the network reference
#   (d_reference := 0 by definition). Stacking all contrasts gives a linear
#   model y = X %*% d + e, Var(e) = V (block-diagonal across trials), solved
#   by generalized least squares: d_hat = (X'V^-1X)^-1 X'V^-1 y.
# =============================================================================

suppressPackageStartupMessages({
  library(MASS)   # mvrnorm(), ginv()
})

#' Read the curated arm-level trial dataset
read_armdata <- function(path = "data/glp1_trials_armlevel.csv") {
  d <- read.csv(path, stringsAsFactors = FALSE)
  d$treat_label <- ifelse(d$treatment == "Placebo", "Placebo",
                           paste0(d$treatment, " ", d$dose))
  d
}

#' Build the stacked contrast vector, its covariance matrix, and the network
#' design matrix from arm-level data.
#'
#' @param armdata Data frame as returned by read_armdata().
#' @param reference Treatment label to use as the network's reference
#'   (must exist as a study-level baseline in at least one trial).
build_network <- function(armdata, reference = "Placebo") {
  studies <- unique(armdata$study)
  treatments <- sort(unique(armdata$treat_label))
  non_ref_treatments <- setdiff(treatments, reference)

  y_list <- list()
  V_blocks <- list()
  X_rows <- list()
  row_labels <- character(0)

  for (s in studies) {
    sub <- armdata[armdata$study == s, ]
    base_row <- sub[sub$is_study_baseline, ]
    comp_rows <- sub[!sub$is_study_baseline, ]
    if (nrow(base_row) != 1) stop("Study ", s, " must have exactly one baseline arm")
    if (nrow(comp_rows) == 0) next

    k <- nrow(comp_rows)
    te <- comp_rows$weight_pct_change_mean - base_row$weight_pct_change_mean
    var_base <- base_row$sd_assumed^2 / base_row$n
    var_comp <- comp_rows$sd_assumed^2 / comp_rows$n
    Vs <- matrix(var_base, nrow = k, ncol = k)  # shared covariance = var of baseline arm
    diag(Vs) <- var_comp + var_base

    Xs <- matrix(0, nrow = k, ncol = length(non_ref_treatments),
                 dimnames = list(NULL, non_ref_treatments))
    for (i in seq_len(k)) {
      comp_lab <- comp_rows$treat_label[i]
      base_lab <- base_row$treat_label
      if (comp_lab %in% non_ref_treatments) Xs[i, comp_lab] <- Xs[i, comp_lab] + 1
      if (base_lab %in% non_ref_treatments) Xs[i, base_lab] <- Xs[i, base_lab] - 1
    }

    y_list[[s]] <- te
    V_blocks[[s]] <- Vs
    X_rows[[s]] <- Xs
    row_labels <- c(row_labels,
                     paste0(s, ": ", comp_rows$treat_label, " vs ", base_row$treat_label))
  }

  y <- unlist(y_list)
  X <- do.call(rbind, X_rows)
  V <- as.matrix(Matrix::bdiag(lapply(V_blocks, as.matrix)))
  if (!is.matrix(V)) V <- matrix(unlist(V_blocks), nrow = length(y))  # fallback, shouldn't trigger
  rownames(X) <- row_labels
  names(y) <- row_labels

  list(y = y, X = X, V = V, treatments = treatments,
       non_ref_treatments = non_ref_treatments, reference = reference,
       row_labels = row_labels)
}

#' Fit the network via generalized least squares
#'
#' @param net Output of build_network().
#' @return A list with the estimated treatment effects (vs reference),
#'   their variance-covariance matrix, and fit diagnostics (Q statistic).
fit_nma <- function(net) {
  y <- net$y; X <- net$X; V <- net$V
  Vinv <- MASS::ginv(V)
  XtVinvX <- t(X) %*% Vinv %*% X
  XtVinvX_inv <- MASS::ginv(XtVinvX)
  d_hat <- as.vector(XtVinvX_inv %*% t(X) %*% Vinv %*% y)
  names(d_hat) <- colnames(X)
  vcov_d <- XtVinvX_inv
  dimnames(vcov_d) <- list(colnames(X), colnames(X))

  fitted <- as.vector(X %*% d_hat)
  resid <- y - fitted
  Q <- as.numeric(t(resid) %*% Vinv %*% resid)
  df <- length(y) - ncol(X)

  # Full vector/matrix including the reference treatment (effect 0, no variance)
  all_treat <- c(net$reference, net$non_ref_treatments)
  d_full <- c(0, d_hat); names(d_full) <- all_treat
  vcov_full <- matrix(0, length(all_treat), length(all_treat), dimnames = list(all_treat, all_treat))
  vcov_full[net$non_ref_treatments, net$non_ref_treatments] <- vcov_d

  list(d = d_full, vcov = vcov_full, Q = Q, df = df,
       Q_pvalue = if (df > 0) 1 - pchisq(Q, df) else NA_real_,
       reference = net$reference)
}

#' Forest-plot-ready data frame: each treatment's effect vs the reference
#' (negative = more weight loss than reference; reference row has d=0).
forest_data <- function(fit) {
  se <- sqrt(diag(fit$vcov))
  data.frame(
    treatment = names(fit$d),
    estimate = as.numeric(fit$d),
    se = se,
    lower = as.numeric(fit$d) - 1.96 * se,
    upper = as.numeric(fit$d) + 1.96 * se,
    row.names = NULL
  )
}

#' Full league table of pairwise differences between every pair of treatments
#' (row - column), with the reference included.
league_table <- function(fit) {
  trt <- names(fit$d)
  k <- length(trt)
  out <- matrix(NA_character_, k, k, dimnames = list(trt, trt))
  for (i in seq_len(k)) for (j in seq_len(k)) {
    if (i == j) { out[i, j] <- "--"; next }
    diff <- fit$d[i] - fit$d[j]
    var_diff <- fit$vcov[i, i] + fit$vcov[j, j] - 2 * fit$vcov[i, j]
    se <- sqrt(max(var_diff, 0))
    out[i, j] <- sprintf("%.1f (%.1f, %.1f)", diff, diff - 1.96 * se, diff + 1.96 * se)
  }
  out
}

#' SUCRA (Surface Under the Cumulative Ranking curve) via Monte Carlo
#' simulation from the multivariate normal implied by the GLS fit.
#'
#' @param fit Output of fit_nma().
#' @param nsim Number of simulation draws (default 100,000).
#' @param smaller_is_better If TRUE (default), a more negative effect
#'   (= more weight loss, given the sign convention used here) ranks better.
#' @return A data.frame of treatments ordered by SUCRA (descending = best).
sucra <- function(fit, nsim = 100000, smaller_is_better = TRUE, seed = 20260921) {
  set.seed(seed)
  trt <- names(fit$d)
  k <- length(trt)
  # Regularize a (near-)singular vcov (the reference row/col is exactly 0)
  V <- fit$vcov
  diag(V) <- diag(V) + 1e-8
  draws <- MASS::mvrnorm(nsim, mu = fit$d, Sigma = V)
  ranks <- t(apply(draws, 1, function(r) rank(if (smaller_is_better) r else -r, ties.method = "average")))
  colnames(ranks) <- trt

  rank_prob <- sapply(seq_len(k), function(r) colMeans(ranks == r))
  rank_prob <- t(rank_prob)  # rows = rank 1..k, cols = treatments
  cum_prob <- apply(rank_prob, 2, cumsum)
  sucra_val <- colSums(cum_prob[-k, , drop = FALSE]) / (k - 1)

  best_rank_prob <- rank_prob[1, ]
  data.frame(
    treatment = trt,
    sucra = as.numeric(sucra_val),
    p_best = as.numeric(best_rank_prob),
    mean_rank = as.numeric(colSums(sweep(rank_prob, 1, seq_len(k), `*`))),
    row.names = NULL
  )[order(-as.numeric(sucra_val)), ]
}
