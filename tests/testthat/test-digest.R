library(testthat)
suppressMessages(library(lavaan))

test_that("digest", {

mod1 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit1 <- sem(
          model = mod1,
          data = data_test_3_factor_3_item
        )
pt1 <- parameterTable(fit1)

mod2 <-
"
fm =~ m1 + m2 + m3
fx =~ x1 + x2 + x3
fy =~ y1 + y2 + y3
fy ~ fm + fx
fm ~ fx
"
fit2 <- sem(
          model = mod2,
          data = data_test_3_factor_3_item
        )
pt2 <- parameterTable(fit2)

expect_false(identical(pt1, pt2))

pt1a <- sort_partable(pt1)
pt2a <- sort_partable(pt2)

cols0 <- c("lhs", "op", "rhs", "block", "group", "ustart")
expect_equal(pt1a[, cols0],
             pt2a[, cols0],
             ignore_attr = TRUE)

pt1a_digest <- digest_partable(pt1a)
pt2a_digest <- digest_partable(pt2a)

pt1b <- add_digest(pt1)
pt2b <- add_digest(pt2)

expect_false(identical(pt1b, pt2b))
expect_identical(attr(pt1b, "digest"),
                 attr(pt2b, "digest"))

expect_identical(attr(pt1b, "digest"),
                 get_digest(pt1b))

expect_identical(attr(pt1b, "digest"),
                 get_digest(pt1))

})
