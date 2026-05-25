library(testthat)
suppressMessages(library(lavaan))

test_that("Check for x-y ecov: 4-var models", {

mod1 <-
"
m1 ~ x1
m2 ~ x1
y1 ~ m1 + m2 + x1
m1 ~~ m2
"
fit1 <- sem(
          model = mod1,
          data = data_test_3_factor_3_item,
          fixed.x = FALSE
        )
pt1 <- parameterTable(fit1)

out1 <- has_x_y_ecov2(pt1)

out1b <- has_x_y_ecov(pt1)

# If has_no_x_y_ecov, we need both checks to say no
expect_true(isFALSE(out1) && isFALSE(out1b))

})
