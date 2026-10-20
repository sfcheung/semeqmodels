library(testthat)
suppressMessages(library(lavaan))

test_that("eq_partables test implied", {

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
          se = "none",
          parallel = FALSE,
          progress = !is_testing(),
          passes = 1
        )
set.seed(1)
eq_out_1b <- eq_models(
          original_model = fit1,
          se = "none",
          eq_mode = "implied",
          parallel = FALSE,
          progress = !is_testing(),
          passes = 2
        )
expect_setequal(
  names(eq_out_1),
  names(eq_out_1b)
)

})
