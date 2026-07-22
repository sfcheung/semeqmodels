library(testthat)
suppressMessages(library(lavaan))

test_that("Empirically equivalent: Other fit measures", {

# ==== Models ====

# Model 1

mod1 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm
"
fit1 <- do.call(
          sem,
          list(
            model = mod1,
            data = data_test_3_factor_3_item
          )
        )

fit1_1_more <- drop_k(fit1)

fit1_1_more_1_less <- lapply(
  fit1_1_more,
  add_k
)

fit1_1_more_1_less_with_fit <- lapply(
  fit1_1_more,
  add_k,
  fit_models = TRUE,
  parallel = FALSE,
  progress = !is_testing()
)

# ==== Parameter Tables ====

partables1 <- combine_partables(fit1_1_more_1_less)

# ==== Fits ====

fits1 <- lapply(
  partables1,
  \(x) lavaan::update(fit1,
                      model = x)
)

df1 <- sapply(
        fits1,
        \(x) fitMeasures(x, "df")
      )
df1

chisq1 <- sapply(
        fits1,
        \(x) fitMeasures(x, "chisq")
      )
chisq1

cfi1 <- sapply(
        fits1,
        \(x) fitMeasures(x, "cfi")
      )
cfi1

chisq0 <- fitMeasures(fit1, "chisq")
cfi0 <- fitMeasures(fit1, "cfi")

# ==== Inputs: list of partables, lavaan ====

eq_out_1 <- is_eq(
          partables1,
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing()
        )

chisq_tol <- unname(eval(formals(is_eq)$tolerance)["chisq"])
expect_equal(
  eq_out_1,
  abs(chisq1 - chisq0) <= chisq_tol,
  ignore_attr = TRUE
)

eq_out_1 <- is_eq(
          partables1,
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing(),
          tolerance = c(cfi = .01)
        )

tol <- .01
expect_equal(
  eq_out_1,
  abs(cfi1 - cfi0) <= tol,
  ignore_attr = TRUE
)

eq_out_1 <- is_eq(
          partables1,
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing(),
          tolerance = c(cfi = .01, chisq = 2)
        )

i1 <- abs(cfi1 - cfi0) <= .01
i2 <- abs(chisq1 - chisq0) <= 2
i <- i1 & i2
expect_equal(
  eq_out_1,
  i,
  ignore_attr = TRUE
)

})
