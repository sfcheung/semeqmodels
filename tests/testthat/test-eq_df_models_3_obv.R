skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: 3 observed variables", {

mod <-
"
fm ~ fx
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
  progress = !is_testing()
)
out

out1 <- eq_models(
          out,
          original_model = fit,
          parallel = FALSE,
          progress = !is_testing()
        )
out1

expect_identical(names(out),
                 names(out1))


length(pt_list_3_obv)
length(out1)

chk_expected <- get_digest_partables(
    pt_list_3_obv
  )

chk_out <- get_digest_partables(
    out1
  )

expect_setequal(
    chk_out,
    chk_expected
  )

})
