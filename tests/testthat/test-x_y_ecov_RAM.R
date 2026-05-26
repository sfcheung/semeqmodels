library(testthat)
suppressMessages(library(lavaan))

test_that("Check for x-y ecov: RAM", {

mod1 <-
"
y1 ~ x1
x1 ~~ m1
y1 ~~ m1
"
fit1 <- sem(
          model = mod1,
          data = data_test_3_factor_3_item,
          fixed.x = FALSE,
          representation = "RAM"
        )
pt1 <- parameterTable(fit1)

mod2 <-
"
y1 ~ x1
x1 ~~ 0*m1
y1 ~~ m1
"
fit2 <- sem(
          model = mod2,
          data = data_test_3_factor_3_item,
          fixed.x = FALSE,
          representation = "RAM"
        )
pt2 <- parameterTable(fit2)

mod3 <-
"
y1 ~ x1
y2 ~ x2
"
fit3 <- sem(
          model = mod3,
          data = data_test_3_factor_3_item,
          fixed.x = FALSE,
          representation = "RAM"
        )
pt3 <- parameterTable(fit3)

mod4 <-
"
y1 ~ x1
y2 ~~ x2
x1 ~~ x2
y1 ~~ y2
"
fit4 <- sem(
          model = mod4,
          data = data_test_3_factor_3_item,
          fixed.x = FALSE,
          representation = "RAM"
        )
pt4 <- parameterTable(fit4)


out1 <- has_x_y_ecov2(fit1)
out2 <- has_x_y_ecov2(fit2)
out3 <- has_x_y_ecov2(fit3)
out4 <- has_x_y_ecov2(fit4)

out1b <- has_x_y_ecov(pt1)
out2b <- has_x_y_ecov(pt2)
out3b <- has_x_y_ecov(pt3)
out4b <- has_x_y_ecov(pt4)

# If has_x_y_ecov, we just need either check to detect them
expect_true(out1 || out1b)
expect_true(out4 || out4b)
# If has_no_x_y_ecov, we need both checks to say no
expect_true(isFALSE(out2) && isFALSE(out2b))
expect_true(isFALSE(out3) && isFALSE(out3b))

})
