skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("nonconvergence", {

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + y2 + m3
fy =~ y1 + m2 + y3
fx ~ fm
fy ~ fx
"
dat <- data_test_4_factor_3_item[1:150, ]
fit <- sem(
  model = mod,
  dat = dat
)
fit_eq <- eq_models(
  original_model = fit,
  parallel = FALSE,
  progress = !is_testing()
)
expect_true(
  length(attr(fit_eq, "has_error")) > 0
)
})
