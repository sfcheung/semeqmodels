library(testthat)
suppressMessages(library(lavaan))
suppressMessages(library(semptools))

test_that("plot models", {

names(pt_list_3_obv) <- paste0("Model ", seq_along(pt_list_3_obv))

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

p1 <- partables_plots(
  pt1,
  layout = layout_i
)

p2 <- partables_plots(
  pt1,
  layout = layout_i,
  original_model = pt1[[1]]
)

p3 <- partables_plots(
  pt1,
  layout = layout_i,
  original_model = fit1
)

skip("Test in an interactive session.")

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = 1
)

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = 1,
  original_model_mode = "include"
)

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = 1,
  original_model_mode = "include",
  title_mode = "name"
)

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = 1,
  original_model_mode = "side_by_side",
  title_mode = "name"
)

plot(
  p3
)

plot(
  p3,
  scale_plots = "always",
  scale = 4
)

plot(
  p3,
  ncol = 3,
  title_adj = .5
)
plot(
  p3,
  nrow = 3
)
plot(
  p3,
  nrow = 3,
  title_mode = "none"
)
plot(
  p3,
  nrow = 3,
  title_mode = "name"
)
plot(
  p3,
  ncol = 3,
  title_mode = "name",
  title_adj = .5
)
plot(
  p3,
  ncol = 2,
  nrow = 2,
  title_mode = "name"
)
plot(
  p3,
  ncol = 3,
  nrow = 3,
  scale = 4,
  title_mode = "name"
)
plot(
  p3,
  ncol = 3,
  nrow = 3,
  scale = 3,
  title_mode = "name"
)
plot(
  p3,
  ncol = 3,
  nrow = 3,
  scale = 3,
  title_mode = "name",
  title_args = list(line = 2)
)



})
