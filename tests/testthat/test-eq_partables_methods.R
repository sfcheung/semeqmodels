library(testthat)
suppressMessages(library(lavaan))

test_that("eq_partables methods", {

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- sem(
          model = mod,
          data = data_test_3_factor_3_item
        )
pt <- parameterTable(fit)

# ==== Test: drop_k ====

fit_1_more1_with_fit <- drop_k(fit,
              fit_models = TRUE,
              parallel = FALSE)
fit_1_more1 <- drop_k(fit,
              fit_models = FALSE,
              parallel = FALSE)

fit_1_more_1_less_with_fit <- lapply(
  fit_1_more1_with_fit,
  add_k,
  fit_models = TRUE,
  parallel = FALSE
)

a1 <- fit_1_more_1_less_with_fit[[1]]
a2 <- fit_1_more_1_less_with_fit[[2]]
a3 <- fit_1_more_1_less_with_fit[[3]]

out <- eq_lavInspect(a1, "npar")
expect_all_equal(unlist(out),
                 21)

out <- eq_lavInspect(fit_1_more1, "npar")
expect_all_true(sapply(out, is.null))

})
