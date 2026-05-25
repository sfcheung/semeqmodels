library(testthat)
suppressMessages(library(lavaan))

test_that("+/- df: fixed.x", {

mod <-
"
m1 ~ x1
y1 ~ m1 + x1
"
# Should not support fixed.x = TRUE
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3_factor_3_item,
            fixed.x = TRUE
        ))
pt <- parameterTable(fit)

# ==== Test: drop_k ====

fit_1_more1 <- drop_k(fit)

fit_1_more2 <- drop_k(pt)

expect_setequal(names(fit_1_more1),
                names(fit_1_more2))

# With fit_mondels

fit_1_more1_with_fit <- drop_k(fit,
              fit_models = TRUE,
              parallel = FALSE)
expect_s4_class(attr(fit_1_more1_with_fit[[1]], "fit"),
                "lavaan")

# ==== Test: add_k ====

# If fixed.x, then no free parameter can be added if
# `m ~ x` is removed or
# `y ~ x` is removed

# Do not test this because whether a model is returned
# depends on the search settings
# fit_1_less <- add_k(
#                 fit_1_more1[[1]],
#                 add_name = TRUE,
#                 fit_models = FALSE,
#                 parallel = FALSE
#               )
# expect_null(fit_1_less)

# fit_1_less_with_fit <- add_k(
#                 fit_1_more1[[1]],
#                 add_name = TRUE,
#                 fit_models = TRUE,
#                 parallel = FALSE
#               )
# expect_null(fit_1_less_with_fit)

fit_1_more_1_less <- lapply(
  fit_1_more1,
  add_k,
  fit_models = FALSE,
  parallel = FALSE
)

expect_null(fit_1_more_1_less$`fit_1_more_1_less`)

})
