skip("Long test: Test in an interactive session")
skip_on_cran()

# This test is a long one.
# Should be conducted locally.

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: 4 latent factors", {

mod <-
"
fx =~ x1 + x2 + x3
fm1 =~ m1 + m2 + m3
fm2 =~ m4 + m5 + m6
fy =~ y1 + y2 + y3
fm1 ~ fx
fm2 ~ fx
fy ~ fm1 + fm2 + fx
fm1 ~~ fm2
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_4_factor_3_item
        ))
pt <- parameterTable(fit)

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

expect_identical(names(out),
                 names(out1))
# saveRDS(out1, "C:/temp/to_check_4_lav.RDS")

# TO PROCESS

length(pt_list_4_lav)
length(out1)

chk_expected <- get_digest_partables(
    pt_list_4_lav
  )

chk_out <- get_digest_partables(
    out1
  )

# The final set may be more inclusive.
# Therefore, it is sufficient to test that
# all known models are in the results.
expect_true(all(chk_expected %in% chk_out))

})
