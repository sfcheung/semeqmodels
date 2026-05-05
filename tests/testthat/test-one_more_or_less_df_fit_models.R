skip("WIP")

library(testthat)
suppressMessages(library(lavaan))

test_that("+/- df: fit_models", {

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
expect_s4_class(attr(fit_1_more1_with_fit[[1]], "fit"),
                "lavaan")
expect_equal(
  lavInspect(eq_fits(fit_1_more1_with_fit)[[1]], "sampstat")$cov,
  lavInspect(fit, "sampstat")$cov
)

# ==== Test: add_k ====

fit_1_less_with_fit <- add_k(
                fit_1_more1_with_fit[[1]],
                sem_out = fit,
                add_name = TRUE,
                fit_models = TRUE,
                parallel = FALSE
              )
expect_s4_class(attr(fit_1_less_with_fit[[1]], "fit"),
                "lavaan")
expect_equal(
  lavInspect(eq_fits(fit_1_less_with_fit)[[1]], "sampstat")$cov,
  lavInspect(fit, "sampstat")$cov
)

# ==== Test: drop_k: Using a parameter table ====

fit_1_more1_from_less1_with_fit <- drop_k(
              fit_1_less_with_fit[[1]],
              sem_out = fit,
              fit_models = TRUE,
              parallel = FALSE)
expect_s4_class(attr(fit_1_more1_from_less1_with_fit[[1]], "fit"),
                "lavaan")
expect_equal(
  lavInspect(eq_fits(fit_1_more1_from_less1_with_fit)[[1]], "sampstat")$cov,
  lavInspect(fit, "sampstat")$cov
)

})
