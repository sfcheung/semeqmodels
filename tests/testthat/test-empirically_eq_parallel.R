skip("Parallel processing: Test in an interactive session")
# A long test

library(testthat)
suppressMessages(library(lavaan))

test_that("Empirically equivalent: Parallel Analysis", {

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
fit <- sem(
  model = mod1,
  data = data_test_3_factor_3_item
)

pt <- parameterTable(fit)

eq_out_1 <- eq_models(
          original_model = fit,
          parallel = TRUE,
          progress = TRUE
        )

# Only original_model: A parameter table

eq_out_2 <- eq_models(
          original_model = pt,
          parallel = TRUE,
          progress = TRUE
        )

# Only original_model: Model syntax

eq_out_3 <- eq_models(
          original_model = mod1,
          parallel = TRUE,
          progress = TRUE
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
