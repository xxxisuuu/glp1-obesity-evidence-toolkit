# =============================================================================
# sample_size.R
#
# Sample size / power calculations for a Phase 3 confirmatory obesity trial,
# following the two-track logic described in the project design document:
#
#   1. EFFICACY-DRIVEN N   -- the classic two-sample continuous-outcome formula
#                             applied to the primary endpoint (% body weight
#                             change from baseline at week 68/72).
#   2. SAFETY-DRIVEN N     -- the FDA's 2025 draft guidance on obesity drug
#                             development requires >=3000 subjects exposed to
#                             the investigational drug and >=1500 to placebo
#                             for >=1 year at the maintenance dose, regardless
#                             of what the efficacy comparison alone would need.
#
# In this drug class the observed effect sizes are large relative to the
# within-arm variability (see data/glp1_trials_armlevel.csv), so in practice
# (1) is almost always small compared to (2). The final planned N is the
# larger of the two -- this file makes that comparison explicit and
# reproducible rather than asserting a number.
# =============================================================================

#' Per-arm sample size for a two-sample comparison of a continuous endpoint
#'
#' Uses the standard normal-approximation formula for two independent means
#' with unequal allocation ratio k = n_active / n_control (Chow, Shao & Wang,
#' "Sample Size Calculations in Clinical Research", eq. for two-sample t-test
#' with allocation ratio).
#'
#' @param delta   Assumed true group difference in % body weight change
#'                (active vs control), a positive number (percentage points).
#' @param sd      Assumed common standard deviation of the endpoint (percentage
#'                points). Defaults to 10, consistent with the SD implied by
#'                back-calculating STEP 1's reported 95% CI (see analysis/02).
#' @param power   Target power (default 0.90).
#' @param alpha   Two-sided type-I error (default 0.05).
#' @param ratio   Allocation ratio k = n_active / n_control (default 2, i.e. 2:1).
#' @return A list with per-arm completer sample sizes (control, active, total).
n_efficacy <- function(delta, sd = 10, power = 0.90, alpha = 0.05, ratio = 2) {
  stopifnot(delta > 0, sd > 0, power > 0 && power < 1, alpha > 0 && alpha < 1, ratio > 0)
  z_alpha <- qnorm(1 - alpha / 2)
  z_beta  <- qnorm(power)
  n_control <- (1 + 1 / ratio) * sd^2 * (z_alpha + z_beta)^2 / delta^2
  n_control <- ceiling(n_control)
  n_active  <- ceiling(ratio * n_control)
  list(
    n_control_completers = n_control,
    n_active_completers  = n_active,
    n_total_completers   = n_control + n_active,
    assumptions = list(delta = delta, sd = sd, power = power, alpha = alpha, ratio = ratio)
  )
}

#' Inflate completer sample sizes for expected dropout
#'
#' @param n_completers Number of completers required in an arm.
#' @param dropout Expected proportion of randomized subjects who do not
#'                complete the trial (default 0.20, per a 68-72 week
#'                long-duration obesity trial).
n_with_dropout <- function(n_completers, dropout = 0.20) {
  stopifnot(dropout >= 0 && dropout < 1)
  ceiling(n_completers / (1 - dropout))
}

#' Safety-database floor per the FDA 2025 draft obesity guidance
#'
#' "Obesity and Overweight: Developing Drugs and Biological Products for
#' Weight Reduction" (Draft Guidance, Jan 2025) recommends >=3000 subjects
#' exposed to the investigational product and >=1500 to placebo, each for
#' >=1 year at the maintenance dose.
#' Source: https://www.federalregister.gov/documents/2025/01/08/2025-00237/
#'
#' @param ratio Allocation ratio k = n_active / n_control, used only to check
#'              internal consistency with the requested minimums; the floor
#'              values themselves are fixed by the guidance.
n_safety_floor <- function(ratio = 2, min_active = 3000, min_control = 1500) {
  list(
    n_control_floor = min_control,
    n_active_floor  = min_active,
    n_total_floor   = min_control + min_active,
    implied_ratio   = min_active / min_control
  )
}

#' Combine efficacy-driven and safety-driven requirements into a final plan
#'
#' Returns, for the control and active arms separately, the maximum of the
#' dropout-inflated efficacy requirement and the safety-database floor --
#' i.e. the actual number a sponsor should plan to randomize.
#'
#' @inheritParams n_efficacy
#' @param dropout Expected dropout proportion, passed to n_with_dropout().
#' @param min_active,min_control FDA safety floor for the active/control arms.
plan_sample_size <- function(delta, sd = 10, power = 0.90, alpha = 0.05,
                              ratio = 2, dropout = 0.20,
                              min_active = 3000, min_control = 1500) {
  eff   <- n_efficacy(delta, sd, power, alpha, ratio)
  eff_c <- n_with_dropout(eff$n_control_completers, dropout)
  eff_a <- n_with_dropout(eff$n_active_completers, dropout)
  safety <- n_safety_floor(ratio, min_active, min_control)

  final_control <- max(eff_c, safety$n_control_floor)
  final_active  <- max(eff_a, safety$n_active_floor)

  binding <- if (final_control == safety$n_control_floor && final_active == safety$n_active_floor &&
                 (safety$n_control_floor > eff_c || safety$n_active_floor > eff_a)) {
    "safety (FDA exposure floor)"
  } else {
    "efficacy (power calculation)"
  }

  data.frame(
    delta = delta, sd = sd, power = power, alpha = alpha, ratio = ratio, dropout = dropout,
    efficacy_driven_control = eff_c, efficacy_driven_active = eff_a,
    safety_floor_control = safety$n_control_floor, safety_floor_active = safety$n_active_floor,
    final_control = final_control, final_active = final_active,
    final_total = final_control + final_active,
    binding_constraint = binding
  )
}

#' Build a scenario table across a grid of assumed effect sizes
#'
#' This is the core exhibit for the "market positioning determines trial
#' design" narrative: for a drug class where competitors already report
#' 15-20+ percentage-point placebo-adjusted effects, ask what assumed delta
#' would make the *efficacy* comparison itself the binding constraint -- and
#' show that, over a realistic range, it essentially never is.
#'
#' @param deltas Numeric vector of assumed group differences to scan.
#' @param ... Passed to plan_sample_size().
scenario_table <- function(deltas = c(3, 5, 8, 10, 12, 15), ...) {
  do.call(rbind, lapply(deltas, plan_sample_size, ...))
}
