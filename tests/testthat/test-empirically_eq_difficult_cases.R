skip_on_cran()
# A long test

library(testthat)
suppressMessages(library(lavaan))

test_that("Empirically equivalent: Multiple passes", {

# ==== Models ====

# Model 1

mod1 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit1 <- do.call(
          sem,
          list(
            model = mod1,
            data = data_test_3_factor_3_item[1:80, ]
          )
        )
pt1 <- parameterTable(fit1)

# Only original_model: A lavaan object

set.seed(1)
eq_out_1 <- eq_models(
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing(),
          passes = 2
        )
set.seed(3)
eq_out_1b <- eq_models(
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing(),
          passes = 4
        )
expect_setequal(
  names(eq_out_1),
  names(eq_out_1b)
)

})
