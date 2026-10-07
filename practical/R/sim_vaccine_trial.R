# Simulated vaccine efficacy trial with a case-cohort (two-phase) design.
#
# Complete data X = (L, A, S, Y); observed data O = (L, A, RS, Y, R), with
# structural equations
#   age ~ Uniform{18, ..., 75},  high_risk ~ Bernoulli(0.35),
#   sex ~ Bernoulli(0.5)                                  (L, baseline)
#   A ~ Bernoulli(0.5)                                    (randomized vaccine)
#   S = A * {1.4 - 0.02 (age - 45) - 0.2 high_risk + U_S},  U_S ~ N(0, 0.5^2)
#   Y ~ Bernoulli(expit{-2.3 + 0.025 (age - 45) + 0.9 high_risk
#                        - 2.2 min(S, 1.2)})
#   R ~ Bernoulli(g_R(Y, L)),  g_R = 1 if Y = 1, else 0.25 (high risk) or 0.15
# S is the log10 neutralizing antibody titer (0, the assay floor, in the
# placebo arm), observed only if R = 1. The vaccine acts on Y only through S,
# and the risk of infection falls with S until a threshold (log10 titer = 1.2)
# and is flat above it. sex affects nothing.

risk_y <- function(s, age, high_risk) {
  plogis(-2.3 + 0.025 * (age - 45) + 0.9 * high_risk - 2.2 * pmin(s, 1.2))
}

mean_s <- function(age, high_risk) 1.4 - 0.02 * (age - 45) - 0.2 * high_risk

sim_vaccine_trial <- function(n = 10000, seed = 34812) {
  set.seed(seed)
  age <- sample(18:75, n, replace = TRUE)
  high_risk <- rbinom(n, 1, 0.35)
  sex <- rbinom(n, 1, 0.5)
  A <- rbinom(n, 1, 0.5)
  S <- A * (mean_s(age, high_risk) + rnorm(n, sd = 0.5))
  Y <- rbinom(n, 1, risk_y(S, age, high_risk))

  # phase two: all cases, plus a subcohort of non-cases sampled by risk stratum
  g_R <- ifelse(Y == 1, 1, ifelse(high_risk == 1, 0.25, 0.15))
  R <- rbinom(n, 1, g_R)
  S[R == 0] <- NA

  data.frame(age, high_risk, sex, A, S, Y, R, g_R)
}

# True counterfactual risk psi under the shift S + delta among vaccinees, and
# the true stochastic-interventional vaccine efficacy SVE_delta
true_sve <- function(delta, n_mc = 2e6, seed = 1) {
  set.seed(seed)
  age <- sample(18:75, n_mc, replace = TRUE)
  high_risk <- rbinom(n_mc, 1, 0.35)
  s <- mean_s(age, high_risk) + rnorm(n_mc, sd = 0.5)
  risk_placebo <- mean(risk_y(0, age, high_risk))
  psi <- sapply(delta, function(d) mean(risk_y(s + d, age, high_risk)))
  data.frame(delta = delta, psi = psi, sve = 1 - psi / risk_placebo)
}
