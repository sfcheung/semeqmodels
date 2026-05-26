skip("Long test: Test in an interactive session")
skip_on_cran()

# This test is a long one.
# Should be conducted locally.

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: 4 observed variables", {

mod <-
"
fm1 ~ fx
fm2 ~ fx
fy ~ fm1 + fm2 + fx
fm1 ~~ fm2
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_4obvs,
            fixed.x = FALSE
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
          progress = is_testing()
        )
out1

expect_identical(names(out),
                 names(out1))


length(pt_list_4_obv)
length(out1)

chk_expected <- get_digest_partables(
    pt_list_4_obv
  )

chk_out <- get_digest_partables(
    out1
  )

# The final set may be more inclusive.
# Therefore, it is sufficient to test that
# all known models are in the results.
expect_true(all(chk_expected %in% chk_out))

})
