library(testthat)
suppressMessages(library(lavaan))

test_that("Combine models", {

# Make results with dummy data reproducible
set.seed(4321)

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

fit_1_more2 <- drop_k(pt)

fit_1_more_1_less <- lapply(
  fit_1_more2,
  add_k
)

out0 <- combine_partables(fit_1_more_1_less)

tmp <- sapply(
        out0,
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
