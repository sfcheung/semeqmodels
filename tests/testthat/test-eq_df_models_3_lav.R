skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: 3 latent factors", {

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

path_all <- function(
  object
) {
  # For testing
  # Only useful in this test
  a <- names(object)
  for (j in seq_along(object)) {
    cat(a[j], ":\n")
    pt <- object[[j]]
    i1 <- pt$lhs %in% c("fx", "fm", "fy")
    i2 <- pt$rhs %in% c("fx", "fm", "fy")
    i3 <- pt$lhs != pt$rhs
    i <- i1 & i2 & i3
    print(pt[i, c("lhs", "op", "rhs", "start", "est", "free")])
    flush.console()
  }
}

path_all_list <- function(
  object
) {
  # For testing
  for (i in seq_along(object)) {
    cat("i: ", i, "\n")
    path_all(object[[i]])
  }
}

# Set seed for reproducible results
set.seed(1)
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

chk_expected <- get_digest_partables(
    pt_list_3_lav
  )

chk_out <- get_digest_partables(
    out1
  )

expect_setequal(
    chk_out,
    chk_expected
  )

skip_if(is_testing(),
        message = "Long test: Test in an interactive session"
)

# The following is done in an interactive session

out_p <- eq_df_models(
  sem_out = fit,
  parallel = TRUE,
  progress = !is_testing()
)

out_p1 <- eq_models(
          out_p,
          original_model = fit,
          parallel = FALSE,
          progress = !is_testing()
        )
out_p1

chk_out_p1 <- get_digest_partables(
    out_p1
  )

expect_setequal(
    chk_out_p1,
    chk_expected
  )

})
