library(testthat)
suppressMessages(library(lavaan))
suppressMessages(library(semptools))

test_that("plot models", {

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

expect_no_error(print(p1))
expect_no_error(print(p2))
expect_no_error(print(p3))


dev.off()

# Check selection

expect_length(have_pars_all(p1, "fx ~ fm"), 1)
expect_length(have_pars_any(p1, c("fx ~ fm", "fy ~ fx")), 2)
expect_length(have_pars_none(p1, c("fm ~~ fy")), 1)
expect_length(must_not_be_y(p1, var = "fx"), 2)
expect_length(must_be_y(p1, var = "fx"), 1)
expect_length(must_not_have_paths(p1, y_on_x = "fy ~ fm"), 2)
expect_length(must_have_paths(p1, y_on_x = "fy ~ fm"), 1)


skip("Test in an interactive session.")

# No original model
plot(
  p1,
  ncol = 2,
  nrow = 2,
  title_adj = 1
)

# No original model
plot(
  p1b,
  ncol = 2,
  nrow = 2,
  title_adj = 2
)

# Original model added
plot(
  p1c,
  ncol = 2,
  nrow = 2,
  title_adj = 2
)

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = 1
)

plot(
  p2b,
  ncol = 2,
  nrow = 2,
  title_adj = 2
)

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = 1,
  original_model_mode = "exclude"
)

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = 1,
  original_model_mode = "exclude",
  title_mode = "name"
)

plot(
  p2,
  ncol = 2,
  nrow = 2,
  title_adj = .7,
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

plot(
  p3b,
  ncol = 3,
  nrow = 3,
  scale = 3,
  original_model_mode = "exclude",
  title_mode = "name",
  title_args = list(line = 2)
)

})
