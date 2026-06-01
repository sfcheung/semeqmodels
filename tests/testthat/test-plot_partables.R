library(testthat)
suppressMessages(library(lavaan))
suppressMessages(library(semptools))

test_that("plot models", {

pt_list_3_obv

pt1 <- pt_list_3_obv[1:3]

fit1 <- sem(
  pt1[[1]],
  data = data_test_3obvs,
  fixed.x = FALSE
)

layout_i <- layout_matrix(
  fx = c(2, 1),
  fm = c(1, 2),
  fy = c(2, 3)
)

p1 <- gen_plots(
  pt1,
  layout = layout_i
)

p2 <- gen_plots(
  pt1,
  layout = layout_i,
  original_model = pt1[[1]]
)

p3 <- gen_plots(
  pt1,
  layout = layout_i,
  original_model = fit1
)


})
