# Empirical Bayes variance moderation (Smyth, 2004), as in limma::squeezeVar.
#
# s2: vector of per-biomarker variance estimates, each on `df` degrees of
#     freedom. Returns the moderated variances
#       s2_tilde = (df * s2 + d0 * s0^2) / (df + d0)
#     with the prior degrees of freedom d0 and prior variance s0^2 estimated
#     from all biomarkers by the method of moments on log(s2).
moderate <- function(s2, df) {
  z <- log(s2) - digamma(df / 2) + log(df / 2)
  z_var <- var(z) - mean(trigamma(df / 2))
  if (z_var <= 0) {
    # no evidence of extra spread: shrink fully to a common variance
    d0 <- Inf
    s0_2 <- exp(mean(z))
    s2_tilde <- rep(s0_2, length(s2))
  } else {
    d0 <- 2 * uniroot(function(x) trigamma(x) - z_var, c(1e-8, 1e8))$root
    s0_2 <- exp(mean(z) + digamma(d0 / 2) - log(d0 / 2))
    s2_tilde <- (df * s2 + d0 * s0_2) / (df + d0)
  }
  list(s2_tilde = s2_tilde, d0 = d0, s0_2 = s0_2)
}
