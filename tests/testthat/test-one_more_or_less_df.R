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

# ==== Test: drop_k ====

fit_1_more1 <- drop_k(fit)

fit_1_more2 <- drop_k(pt)

expect_setequal(names(fit_1_more1),
                names(fit_1_more2))

# ==== Test: add_k ====

fit_1_less <- add_k(
                fit_1_more1[[1]],
                add_name = TRUE
              )

fit_1_more_1_less <- lapply(
  fit_1_more1,
  add_k
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
