# Simulated vaccine efficacy trial with a case-cohort (two-phase) design.
#
# Complete data X = (L, A, S, Y); observed data O = (L, A, R, RS, Y):
# L = (age, high_risk, sex): baseline covariates
# A: randomized vaccine (1) vs placebo (0)
# S: log10 neutralizing antibody titer; observed only if R = 1
# Y: infection by end of follow-up
# R: inclusion in the phase-two (case-cohort) sample, with known probability
#    pi_R = P(R = 1 | Y, L)
#
# The vaccine acts on Y only through S, and the risk of infection falls with S
# until a threshold (log10 titer = 1.2) and is flat above it.

risk_y <- function(s, age, high_risk) {
  plogis(-2.3 + 0.9 * high_risk + 0.3 * age - 2.2 * pmin(s, 1.2))
}

mean_s <- function(age, high_risk) 1.4 - 0.25 * age - 0.2 * high_risk

sim_vaccine_trial <- function(n = 10000, seed = 34812) {
  set.seed(seed)
  age <- round(rnorm(n), 2)                 # standardized age
  high_risk <- rbinom(n, 1, 0.35)
  sex <- rbinom(n, 1, 0.5)
  A <- rbinom(n, 1, 0.5)
  # placebo recipients have titers at the assay floor (0 on the log10 scale)
  S <- ifelse(A == 1, rnorm(n, mean_s(age, high_risk), 0.5), 0)
  Y <- rbinom(n, 1, risk_y(S, age, high_risk))

  # phase two: all cases, plus a subcohort of non-cases sampled by risk stratum
  pi_R <- ifelse(Y == 1, 1, ifelse(high_risk == 1, 0.25, 0.15))
  R <- rbinom(n, 1, pi_R)
  S[R == 0] <- NA

  data.frame(age, high_risk, sex, A, R, pi_R, S, Y)
}

# True counterfactual risk under the shift S + delta among vaccinees, and the
# true stochastic-interventional vaccine efficacy SVE(delta)
true_sve <- function(delta, n_mc = 2e6, seed = 1) {
  set.seed(seed)
  age <- rnorm(n_mc)
  high_risk <- rbinom(n_mc, 1, 0.35)
  s <- rnorm(n_mc, mean_s(age, high_risk), 0.5)
  risk_placebo <- mean(risk_y(0, age, high_risk))
  theta <- sapply(delta, function(d) mean(risk_y(s + d, age, high_risk)))
  data.frame(delta = delta, theta = theta, sve = 1 - theta / risk_placebo)
}
