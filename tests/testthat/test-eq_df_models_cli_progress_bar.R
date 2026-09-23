library(testthat)

test_that("eq_df_models: 3 latent factors", {

skip_on_cran()

suppressMessages(library(lavaan))

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

chk_expected <- get_digest_partables(
    pt_list_3_lav
  )

chk_out <- get_digest_partables(
    out
  )

# The final set may be more inclusive.
# Therefore, it is sufficient to test that
# all known models are in the results.
expect_true(all(chk_expected %in% chk_out))

})

test_that("eq_df_models: 3 latent factors", {

skip_if_not(interactive())

suppressMessages(library(lavaan))

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
  parallel = TRUE,
  ncores = 2,
  progress = !is_testing()
)
out

chk_expected <- get_digest_partables(
    pt_list_3_lav
  )

chk_out <- get_digest_partables(
    out
  )

# The final set may be more inclusive.
# Therefore, it is sufficient to test that
# all known models are in the results.
expect_true(all(chk_expected %in% chk_out))

})
