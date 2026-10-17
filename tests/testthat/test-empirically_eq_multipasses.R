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
            data = data_test_3_factor_3_item
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

# Only original_model: A parameter table

set.seed(11)
eq_out_2 <- eq_models(
          original_model = pt1,
          parallel = FALSE,
          progress = !is_testing(),
          passes = 2
        )
set.seed(12)
eq_out_2b <- eq_models(
          original_model = pt1,
          parallel = FALSE,
          progress = !is_testing(),
          passes = 4
        )
expect_setequal(
  names(eq_out_2),
  names(eq_out_2b)
)

# Only original_model: Model syntax

# Need this seed for consistent dummy data
set.seed(2345)
eq_out_3 <- eq_models(
          original_model = mod1,
          parallel = FALSE,
          progress = !is_testing(),
          passes = 2
        )
eq_out_3b <- eq_models(
          original_model = mod1,
          parallel = FALSE,
          progress = !is_testing(),
          passes = 3
        )
expect_setequal(
  names(eq_out_3),
  names(eq_out_3b)
)

expect_setequal(
  names(eq_out_1),
  names(eq_out_2)
)
expect_setequal(
  names(eq_out_1),
  names(eq_out_3)
)

})
