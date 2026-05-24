skip("WIP")

skip_on_cran()

skip_if_not_installed("semPlot")
skip_if_not_installed("semptools")

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: Plot history", {

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
pt <- parameterTable(fit)

# Set seed for reproducible results
set.seed(1)
out <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = !is_testing()
)
out

out1 <- eq_models(
          out,
          original_model = fit,
          parallel = FALSE,
          progress = !is_testing()
        )
out1

# Check plots

tmp1 <- inspect_search(out, "same_to_more", iteration = 2)
tmp2 <- inspect_search(out, "more_to_same", iteration = 5)

tmp3 <- inspect_search_full(out)

layout_i <- semptools::layout_matrix(
  fx = c(2, 1),
  fm = c(1, 2),
  fy = c(2, 3)
)

p1 <- gen_plots_a_to_b_i(tmp1[[1]], layout = layout_i, asize = 10)
p2 <- gen_plots_a_to_b_i(tmp2[[3]], layout = layout_i, asize = 10)
p3 <- gen_plots_a_to_b_i(tmp2[[4]], layout = layout_i, asize = 10)

pall1 <- gen_plots_for_search(tmp3, layout = layout_i, asize = 10)

plot_a_to_b_i(p1)
plot_a_to_b_i(p2)
plot_a_to_b_i(p3)

plot_search_history(pall1)

})
