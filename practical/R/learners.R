# Correctly specified GLMs for the two simulations, written as SuperLearner
# learners so they can be compared to (and included among) other learners.
# Each fits glm(Y ~ ., ...) after transforming the covariates.

make_glm_learner <- function(name, transform_x) {
  learner <- function(Y, X, newX, family, obsWeights, ...) {
    fit <- glm(
      Y ~ .,
      data = transform_x(X),
      family = family,
      weights = obsWeights
    )
    pred <- predict(fit, newdata = transform_x(newX), type = "response")
    list(pred = pred, fit = structure(list(object = fit), class = name))
  }
  # predict() method, needed by packages (e.g., lmtp) that re-use the fits
  registerS3method("predict", name, function(object, newdata, ...) {
    predict(object$object, newdata = transform_x(newdata), type = "response")
  })
  learner
}

# Part 1 (synthetic CpG): adds bmi_z^2
SL.glm_correct <- make_glm_learner("SL.glm_correct", function(x) {
  transform(x, bmi_z2 = bmi_z^2)
})

# Part 2 (vaccine trial): risk depends on titer only up to log10 titer 1.2
SL.glm_threshold <- make_glm_learner("SL.glm_threshold", function(x) {
  transform(x, S = pmin(S, 1.2))
})

# ridge regression (SuperLearner's SL.glmnet defaults to the lasso)
SL.ridge <- function(...) SuperLearner::SL.glmnet(..., alpha = 0)
