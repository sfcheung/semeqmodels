library(testthat)
suppressMessages(library(lavaan))

test_that("Empirically equivalent", {

# ==== Models ====

# Model 1

mod1 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
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

# Model 2

mod2 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3 + m3
fm ~ fx
fy ~ fm
"
fit2 <- do.call(
          sem,
          list(
            model = mod2,
            data = data_test_3_factor_3_item
        ))
fit2_1_more <- drop_k(fit2)

fit2_1_more_1_less <- lapply(
  fit2_1_more,
  add_k
)

# Model 3

mod3 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm
"
fit3 <- do.call(
          sem,
          list(
            model = mod3,
            data = data_test_3_factor_3_item
        ))
fit3_1_more <- drop_k(fit3)

fit3_1_more_1_less <- lapply(
  fit3_1_more,
  add_k
)

# ==== Parameter Tables ====

# All equivalent
partables1 <- combine_partables(fit1_1_more_1_less)

# Some not equivalent
partables12 <- combine_partables(c(fit1_1_more_1_less,
                               fit2_1_more_1_less))

# All equivalent
partables3 <- combine_partables(fit3_1_more_1_less)

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

fits12 <- lapply(
  partables12,
  \(x) lavaan::update(fit1,
                      model = x)
)

df12 <- sapply(
        fits12,
        \(x) fitMeasures(x, "df")
      )
df12

chisq12 <- sapply(
        fits12,
        \(x) fitMeasures(x, "chisq")
      )
chisq12

fits3 <- lapply(
  partables3,
  \(x) lavaan::update(fit3,
                      model = x)
)

df3 <- sapply(
        fits3,
        \(x) fitMeasures(x, "df")
      )
df3

chisq3 <- sapply(
        fits3,
        \(x) fitMeasures(x, "chisq")
      )
chisq3

# ==== Inputs: list of partables, lavaan ====

eq_out_1 <- eq_models(
          partables1,
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing()
        )

eq_out_2 <- eq_models(
          partables12,
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_setequal(
  names(eq_out_1),
  names(eq_out_2)
)

expect_setequal(
  unname(get_digest_partables(eq_out_1)),
  unname(get_digest_partables(eq_out_2))
)

eq_out_3 <- eq_models(
          partables3,
          original_model = fit3,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_true(length(eq_out_3) == 1)

# ==== Inputs: list of partables, no lavaan ====

eq_out_1b <- eq_models(
          partables1,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_setequal(names(eq_out_1),
                names(eq_out_1b))

eq_out_3b <- eq_models(
          partables3,
          parallel = FALSE,
          progress = !is_testing()
        )
expect_setequal(names(eq_out_3),
                names(eq_out_3b))

# ==== Inputs: list of partables, partable ====

eq_out_1c <- eq_models(
          partables1,
          original_model = parameterTable(fit1),
          parallel = FALSE,
          progress = !is_testing()
        )

expect_setequal(names(eq_out_1),
                names(eq_out_1c))

eq_out_3c <- eq_models(
          partables3,
          original_model = parameterTable(fit3),
          parallel = FALSE,
          progress = !is_testing()
        )
expect_setequal(names(eq_out_3),
                names(eq_out_3c))

# ==== With fit ====

# All equivalent
partables1_with_fit <- combine_partables(fit1_1_more_1_less_with_fit)

expect_false(eq_same_data(partables1_with_fit))
expect_true(eq_same_data(fit1_1_more_1_less_with_fit[[1]]))
expect_true(eq_same_data(fit1_1_more_1_less_with_fit[[2]]))

eq_out_1_fit <- eq_models(
          partables1_with_fit,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_true(eq_same_data(eq_out_1_fit))

eq_out_1_fit2 <- eq_models(
          partables1_with_fit,
          original_model = fit1,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_true(eq_same_data(eq_out_1_fit2))

expect_false(identical(
              lavInspect(eq_fits(eq_out_1_fit)[[1]], "sampstat"),
              lavInspect(eq_fits(eq_out_1_fit2)[[1]], "sampstat")
            ))

expect_true(identical(
              lavInspect(eq_fits(eq_out_1_fit2)[[1]], "sampstat"),
              lavInspect(fit1, "sampstat")
            ))


})
