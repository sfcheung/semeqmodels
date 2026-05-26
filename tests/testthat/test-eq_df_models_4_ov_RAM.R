skip("Long test: Test in an interactive session")
skip_on_cran()

# This test is a long one.
# Should be conducted locally.

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: 4 observed factors: RAM", {

mod <-
"
m1 ~ x1
m2 ~ x1
y1 ~ m1 + m2
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3_factor_3_item,
            fixed.x = FALSE
        ))
pt <- parameterTable(fit)

expect_setequal(all_nil_parameters(pt),
                all_nil_parameters(fit))

# Set seed for reproducible results
set.seed(1)
out <- eq_df_models(
  sem_out = fit,
  parallel = TRUE,
  progress = !is_testing()
)
out

out1 <- eq_models(
          out,
          original_model = fit,
          parallel = TRUE,
          progress = !is_testing()
        )
out1

})
