skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("gen_eq_df_models: 3 latent factors", {

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

out <- gen_eq_df_models(
  sem_out = fit,
  parallel = FALSE
)
out

out1 <- empirical_eq(
          out,
          original_model = fit,
          parallel = FALSE,
          progress = !is_testing()
        )
out1

expect_identical(names(out),
                 names(out1))

})
