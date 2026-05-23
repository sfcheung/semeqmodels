library(testthat)
suppressMessages(library(lavaan))

test_that("eq_partables: set functions", {

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

fit_1_more1 <- drop_k(fit,
              fit_models = FALSE,
              parallel = FALSE)

fit_1_more_1_less <- lapply(
  fit_1_more1,
  add_k,
  fit_models = TRUE,
  parallel = FALSE
)

pt0 <- combine_partables(fit_1_more_1_less)

pt1 <- pt0[1:3]
pt2 <- pt0[2:4]

expect_true(setequal_eq_partables(
              union_eq_partables(pt1, pt2),
              pt0))

expect_true(setequal_eq_partables(
              intersect_eq_partables(pt1, pt2),
              pt0[2:3]))

expect_true(is_element_eq_partables(
              pt0[[3]],
              pt1))

expect_false(is_element_eq_partables(
              pt0[[4]],
              pt1))

expect_equal(match_eq_partables(pt1, pt2),
             c(NA, 1, 2))

expect_equal(pt1 %pt_in% pt2,
             c(FALSE, TRUE, TRUE))

expect_equal(pt1 %pt_notin% pt2,
             !c(FALSE, TRUE, TRUE))

# setdiff

pt1 <- pt0[1:2]
pt2 <- pt0[1:3]

expect_length(setdiff_eq_partables(pt1, pt2), 0)
expect_length(setdiff_eq_partables(pt2, pt1), 1)

})
