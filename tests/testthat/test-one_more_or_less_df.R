library(testthat)
suppressMessages(library(lavaan))

test_that("+/- df", {

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

# ==== Test: get_drop_i ====

fit_1_more1 <- get_drop_i(fit)

fit_1_more2 <- get_drop_i(pt)

expect_setequal(names(fit_1_more1),
                names(fit_1_more2))

# ==== Test: get_add_i ====

fit_1_less <- get_add_i(
                fit_1_more1[[1]],
                add_name = TRUE
              )

fit_1_more_1_less <- lapply(
  fit_1_more1,
  get_add_i
)

fit_1_more_1_less <- unlist(
    fit_1_more_1_less,
    recursive = FALSE
  )

class(fit_1_more_1_less) <- c("partables", class(fit_1_more_1_less))

tmp <- sapply(
        fit_1_more_1_less,
        attr,
        which = "parameters_added",
        USE.NAMES = FALSE
      )

chk <- c(
  "fx~~fm",
  "fx~fm",
  "fm~~fy",
  "fm~fy"
)
expect_setequal(tmp,
                chk)

})
