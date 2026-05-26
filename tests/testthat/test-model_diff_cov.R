library(testthat)
suppressMessages(library(lavaan))

test_that("model differences: Treat cov correctly", {

mod1 <-
"
y ~ m + x
"

mod2 <-
"
y ~ x + m
"

pt1 <- sem(mod1, do.fit = FALSE)
pt2 <- sem(mod2, do.fit = FALSE)

out <- model_diff(pt1, pt2)

expect_equal(nrow(out[[1]]), 0)
expect_equal(nrow(out[[2]]), 0)

})
