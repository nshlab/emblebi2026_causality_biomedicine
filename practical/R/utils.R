# Helper functions for Part 1 (after medoutcon's R/utils.R).

# Bound estimated propensity scores away from 0 and 1. Scores near 0 or 1 make
# the inverse weights 1 / g_n(L) explode; truncating trades a little bias for
# much less variance. The bounds are a tuning choice (0.01 is ltmle's default).
bound_propensity <- function(vals, bounds = c(0.01, 0.99)) {
  stopifnot(all(vals >= 0 & vals <= 1))
  pmin(pmax(vals, bounds[1]), bounds[2])
}

# Keep predicted (scaled) outcomes strictly inside (0, 1), so that their
# logits, used by the TMLE fluctuation, are finite.
bound_precision <- function(vals, bounds = c(0.001, 0.999)) {
  pmin(pmax(vals, bounds[1]), bounds[2])
}

# Scale values to the unit interval, and back, given the original range.
scale_to_unit <- function(vals, range_orig = range(vals)) {
  (vals - range_orig[1]) / diff(range_orig)
}
scale_from_unit <- function(vals_scaled, range_orig) {
  vals_scaled * diff(range_orig) + range_orig[1]
}

# Estimate the propensity score g_0(L) = P(A = 1 | L) with a Super Learner
# (a library with a single learner, e.g., "SL.glm", is just that learner).
estimate_g <- function(a, l, g_lib) {
  g_fit <- SuperLearner::SuperLearner(
    Y = a,
    X = l,
    family = binomial(),
    SL.library = g_lib,
    cvControl = list(V = 5)
  )
  bound_propensity(g_fit$SL.predict[, 1])
}

# Estimate the outcome regression Q_0(A, L) = E[Y | A, L], and predict it at
# the observed A, at A = 1, and at A = 0.
estimate_Q <- function(y, a, l, q_lib) {
  X <- data.frame(A = a, l)
  q_fit <- SuperLearner::SuperLearner(
    Y = y,
    X = X,
    newX = rbind(X, transform(X, A = 1), transform(X, A = 0)),
    SL.library = q_lib,
    cvControl = list(V = 5)
  )
  q_n <- matrix(q_fit$SL.predict, ncol = 3)
  list(QA = q_n[, 1], Q1 = q_n[, 2], Q0 = q_n[, 3], coef = q_fit$coef)
}

# TMLE of the ATE for a continuous outcome y, given propensity score estimates
# g_n. The same steps as Exercise 1.2, wrapped in a function.
tmle_ate <- function(y, a, l, g_n, q_lib) {
  # 1. scale the outcome to [0, 1], so a logistic fluctuation respects its range
  y_range <- range(y)
  y_s <- scale_to_unit(y, y_range)

  # 2. initial estimate of the outcome regression, on the unit scale
  Q <- lapply(
    estimate_Q(y_s, a, l, q_lib)[c("QA", "Q1", "Q0")],
    bound_precision
  )

  # 3. clever covariate, at the observed A and at A = 1, A = 0
  H_A <- a / g_n - (1 - a) / (1 - g_n)
  H_1 <- 1 / g_n
  H_0 <- -1 / (1 - g_n)

  # 4. fluctuate: logistic regression of y_s on H_A, offset by the initial fit
  eps <- coef(glm(
    y_s ~ -1 + H_A + offset(qlogis(Q$QA)),
    family = quasibinomial()
  ))

  # 5. update the outcome regression, then plug it in
  QA_star <- plogis(qlogis(Q$QA) + eps * H_A)
  Q1_star <- plogis(qlogis(Q$Q1) + eps * H_1)
  Q0_star <- plogis(qlogis(Q$Q0) + eps * H_0)
  psi_s <- mean(Q1_star - Q0_star)

  # 6. the EIF at the targeted fit, back on the original scale
  eif <- diff(y_range) * (H_A * (y_s - QA_star) + Q1_star - Q0_star - psi_s)
  c(
    psi = diff(y_range) * psi_s,
    se = sd(eif) / sqrt(length(y)),
    mean_eif = mean(eif)
  )
}
