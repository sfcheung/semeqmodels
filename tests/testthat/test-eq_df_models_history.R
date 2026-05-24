skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: Helpers", {

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3_factor_3_item
        ))
pt <- parameterTable(fit)

# Set seed for reproducible results
set.seed(1)
out <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing()
)
out

# Check for error is OK. The history
# may change if the search algorithm changes.
expect_no_error(partables_a_to_b(out, "same_to_more", iteration = 1))
expect_no_error(partables_a_to_b(out, "same_to_more", iteration = 2))
expect_no_error(partables_a_to_b(out, "more_to_same", iteration = 1))
expect_no_error(partables_a_to_b(out, "same_to_more", iteration = 2))

out_pts <- inspect_search(out, "same_to_more", iteration = 2)
expect_true(is_partable(out_pts[[1]]$from_model))
expect_true(is_partables(out_pts[[1]]$to_model))
out_diff <- inspect_search(out, "more_to_same", iteration = 5, what = "model_diff")
expect_s3_class(out_diff[[1]], "model_diff_many")

})
