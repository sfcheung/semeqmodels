library(testthat)
suppressMessages(library(lavaan))

test_that("eq_partables: rename", {

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

# ==== Test: drop_k ====

fit_1_more1 <- drop_k(fit,
              fit_models = FALSE,
              parallel = FALSE)

fit_1_more_1_less <- lapply(
  fit_1_more1,
  add_k,
  fit_models = TRUE,
  parallel = FALSE
)

fit_1_more_1_less <- combine_partables(fit_1_more_1_less)

# Tests

out <- rename_to_digest(
  fit_1_more_1_less
)

chk <- get_digest_partables(fit_1_more_1_less)

expect_equal(
  names(out),
  chk,
  ignore_attr = TRUE
)

chk <- sapply(out, attr, which = "gen_models_name")

expect_equal(
  names(fit_1_more_1_less),
  chk,
  ignore_attr = TRUE
)


})
