skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: 3 observed variables: keep_cov", {

mod <-
"
fy ~ fm + fx
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3obvs,
            fixed.x = FALSE
        ))
pt <- parameterTable(fit)

# Change argument parallel = FALSE
out <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing(),
  keep_covs = "no"
)

out2 <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing(),
  keep_covs = "all_covs"
)

out3 <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing(),
  keep_covs = "all_x_covs"
)

expect_true(
  setequal_eq_partables(have_pars(out2, "fm ~~ fx"), out2)
)
expect_true(
  setequal_eq_partables(have_pars(out, "fm ~~ fx"), out2)
)
expect_true(
  setequal_eq_partables(have_pars(out3, "fm ~~ fx"), out3)
)

})


test_that("eq_df_models: 3 observed variables: keep_x_cov", {

mod <-
"
fm ~ fx
fy ~ fx
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3obvs,
            fixed.x = FALSE
        ))
pt <- parameterTable(fit)

# Change argument parallel = FALSE
out <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing(),
  keep_covs = "no"
)

out2 <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing(),
  keep_covs = "all_covs"
)

out3 <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing(),
  keep_covs = "all_x_covs"
)

expect_true(
  setequal_eq_partables(have_pars(out2, "fm ~~ fy"), out2)
)
expect_true(
  setequal_eq_partables(have_pars(out, "fm ~~ fy"), out2)
)
expect_true(
  setequal_eq_partables(out3, out)
)

})
