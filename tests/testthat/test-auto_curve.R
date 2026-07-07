skip("WIP")

library(testthat)
suppressMessages(library(lavaan))
suppressMessages(library(semptools))

test_that("auto_curve_covariance: 3obv", {

pdf(NULL)

names(pt_list_3_obv) <- paste0("Model ", seq_along(pt_list_3_obv))

pt1 <- pt_list_3_obv[c(1:2, 7, 13)]

layout_i <- layout_matrix(
  fx = c(2, 1),
  fm = c(1, 2),
  fy = c(2, 3)
)

p1 <- partables_plots(
  pt1,
  layout = layout_i
)

plot(
  p1,
  ncol = 2,
  nrow = 2
)

dev.off()

# SF: Add some tests below

expect_length(bidirectional_edges(p1[[1]]), 3)
expect_length(bidirectional_edges(p1[[2]]), 1)
expect_length(bidirectional_edges(p1[[3]]), 1)
expect_length(bidirectional_edges(p1[[4]]), 0)

pdf(NULL)

pt1_a <- set_curve(
  p1[[1]],
  auto_curve_covariance_i(bidirectional_edges(p1[[1]])[[1]], p1[[1]])
)
if (!is_testing()) plot(pt1_a)
expect_equal(
  pt1_a$graphAttributes$Edge$curve[c(1, 4)],
  c(1, 1)
)
pt1_a <- set_curve(
  p1[[1]],
  auto_curve_covariance_i(bidirectional_edges(p1[[1]])[[2]], p1[[1]])
)
if (!is_testing()) plot(pt1_a)
expect_equal(
  pt1_a$graphAttributes$Edge$curve[c(3, 6)],
  c(-1, -1)
)
pt1_a <- set_curve(
  p1[[1]],
  auto_curve_covariance_i(bidirectional_edges(p1[[1]])[[3]], p1[[1]])
)
if (!is_testing()) plot(pt1_a)
expect_equal(
  pt1_a$graphAttributes$Edge$curve[c(2, 5)],
  c(1, 1)
)

dev.off()


})

test_that("auto_curve_covariance: 4var", {

pdf(NULL)

names(pt_list_4_lav) <- paste0("Model ", seq_along(pt_list_4_lav))

pt1 <- pt_list_4_lav[c(1, 11, 51, 75)]

layout_i <- layout_matrix(
  fx = c(2, 1),
  fm1 = c(1, 2),
  fm2 = c(3, 2),
  fy = c(2, 3)
)

p1 <- partables_plots(
  pt1,
  structural = TRUE,
  layout = layout_i
)

plot(
  p1,
  ncol = 2,
  nrow = 2
)

dev.off()

# SF: Add some tests below

expect_length(bidirectional_edges(p1[[1]]), 6)
expect_length(bidirectional_edges(p1[[2]]), 2)
expect_length(bidirectional_edges(p1[[3]]), 1)
expect_length(bidirectional_edges(p1[[4]]), 0)

pdf(NULL)

pt1_a <- set_curve(
  p1[[1]],
  auto_curve_covariance_i(bidirectional_edges(p1[[1]])[[1]], p1[[1]])
)
if (!is_testing()) plot(pt1_a)
expect_equal(
  pt1_a$graphAttributes$Edge$curve[c(1, 7)],
  c(1, 1)
)
pt1_a <- set_curve(
  p1[[1]],
  auto_curve_covariance_i(bidirectional_edges(p1[[1]])[[2]], p1[[1]])
)
if (!is_testing()) plot(pt1_a)
expect_equal(
  pt1_a$graphAttributes$Edge$curve[c(4, 10)],
  c(-1, -1)
)
pt1_a <- set_curve(
  p1[[1]],
  auto_curve_covariance_i(bidirectional_edges(p1[[1]])[[3]], p1[[1]])
)
if (!is_testing()) plot(pt1_a)
expect_equal(
  pt1_a$graphAttributes$Edge$curve[c(6, 12)],
  c(1, 1)
)
pt1_a <- set_curve(
  p1[[1]],
  auto_curve_covariance_i(bidirectional_edges(p1[[1]])[[4]], p1[[1]])
)
if (!is_testing()) plot(pt1_a)
expect_equal(
  pt1_a$graphAttributes$Edge$curve[c(5, 11)],
  c(1, 1)
)

dev.off()

})
