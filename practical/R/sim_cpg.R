# A synthetic CpG site with a known average treatment effect (ATE = -1).
#
# O = (L, A, Y) with L = (bmi_z, sex). Smoking A depends on bmi_z through bmi_z^2,
# and so does methylation Y: a main-terms GLM in (A, bmi_z, sex) omits this
# confounding and is misspecified; a GLM that adds bmi_z^2 is correctly
# specified (see learners.R).

true_ate_cpg <- -1

sim_cpg <- function(n = 2000, seed = 1) {
  set.seed(seed)
  bmi_z <- rnorm(n) # body-mass index z-score (standardized)
  sex <- rbinom(n, 1, 0.5)
  A <- rbinom(n, 1, plogis(-1 + 0.7 * bmi_z^2 + 0.4 * sex))
  Y <- 0.5 +
    true_ate_cpg * A +
    0.3 * bmi_z +
    0.8 * bmi_z^2 +
    0.2 * sex +
    rnorm(n, sd = 0.5)
  data.frame(bmi_z, sex, A, Y)
}
