library(testthat)
suppressMessages(library(lavaan))
suppressMessages(library(semptools))

test_that("plot models: Pipe operator", {

pdf(NULL)

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

layout_j <- layout_matrix(
  fx = c(1, 1),
  fm = c(2, 2),
  fy = c(1, 3)
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

p1b <- partables_plots(
  p1,
  sizeMan = 20,
  partables = pt_list_3_obv[4:6],
  par_diff_settings = list(
              color = "red",
              width = 4
            )
)

p1c <- partables_plots(
  p1,
  sizeMan = 20,
  original_model = pt_list_3_obv[[2]],
  partables = pt_list_3_obv[4:6],
  par_diff_settings = list(
              color = "red",
              width = 4
            ),
  exclude_original_model = FALSE
)


p2b <- partables_plots(
  p2,
  original_model = pt1[[2]],
  sizeMan = 20,
  par_diff_settings = list(
              color = "green",
              width = 4
            )
)

p3b <- partables_plots(
  p3,
  layout = layout_j,
  original_model = pt1[[2]]
)

dev.off()

p1_1 <- p1 %p>% set_node_attribute(c(fm = "red", fx = "blue"), attribute_name = "color")

expect_in(
  c("red", "blue"),
  p1_1[[1]]$graphAttributes$Nodes$color
)

# plot(p1_1, ncol = 3)

p2_1 <- p2 %p>% set_node_attribute(c(fx = "cyan", fm = "green"), attribute_name = "color")

expect_in(
  c("green", "cyan"),
  p2_1[[2]]$graphAttributes$Nodes$color
)

expect_in(
  c("green", "cyan"),
  attr(p2_1, "original_model")[[1]]$graphAttributes$Nodes$color
)

p2_2 <- p2 %p>%
  set_node_attribute(c(fm = "green"), attribute_name = "color") %p>%
  set_node_attribute(c(fx = "cyan"), attribute_name = "color")

expect_in(
  c("green", "cyan"),
  p2_2[[2]]$graphAttributes$Nodes$color
)

expect_in(
  c("green", "cyan"),
  attr(p2_2, "original_model")[[1]]$graphAttributes$Nodes$color
)

# plot(p2_1, ncol = 3)

})
