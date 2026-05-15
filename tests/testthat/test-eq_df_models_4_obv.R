# Have bugs

skip("WIP")

# Too long to run. Wait for parallel processing in eq_df_models().

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
            data = data_test_4obvs
        ))
pt <- parameterTable(fit)

out <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = is_testing()
)
out

out1 <- eq_models(
          out,
          original_model = fit,
          parallel = FALSE,
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

expect_setequal(
    chk_out,
    chk_expected
  )

})
