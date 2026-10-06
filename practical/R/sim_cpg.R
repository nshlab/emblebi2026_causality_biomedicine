# A synthetic CpG site with a known average treatment effect (ATE = -1).
#
# O = (L, A, Y) with L = (age, sex). Smoking A depends on age through age^2,
# and so does methylation Y: a main-terms GLM in (A, age, sex) omits this
# confounding and is misspecified; a GLM that adds age^2 is correctly
# specified (see learners.R).

true_ate_cpg <- -1

sim_cpg <- function(n = 2000, seed = 1) {
  set.seed(seed)
  age <- rnorm(n)                    # standardized age
  sex <- rbinom(n, 1, 0.5)
  A <- rbinom(n, 1, plogis(-1 + 0.7 * age^2 + 0.4 * sex))
  Y <- 0.5 + true_ate_cpg * A + 0.3 * age + 0.8 * age^2 + 0.2 * sex +
    rnorm(n, sd = 0.5)
  data.frame(age, sex, A, Y)
}
