skip("WIP")

skip_on_cran()

skip_if_not_installed("semPlot")
skip_if_not_installed("semptools")

library(testthat)
suppressMessages(library(lavaan))

test_that("eq_df_models: Plot history", {


plot_model <- function(
  pt,
  ...,
  fix_cov = FALSE,
  cov_color = "red",
  new_par = NULL,
  new_par_color = "black",
  new_par_width = 2
) {
  p_fit <- semPlot::semPaths(
    pt,
    ...,
    residuals = FALSE,
    structural = TRUE,
    DoNotPlot = TRUE
  )
  p_fit_vars <- names(p_fit$graphAttributes$Nodes$labels)
  pt$lavlabel <- lavaan::lav_partable_labels(pt)
  i <- (pt$lhs %in% p_fit_vars) &
       (pt$op == "~~") &
       (pt$lhs != pt$rhs)
  if (any(i) && fix_cov) {
    covs <- pt$lavlabel[i]
    cov_colors <- rep(cov_color, length(covs))
    names(cov_colors) <- covs
    p_fit <- semptools::set_edge_color(
                p_fit,
                color_list = cov_colors
              )
  }
  if (!is.null(new_par)) {
    tmp1 <- new_par_color
    names(tmp1) <- new_par
    tmp2 <- new_par_width
    names(tmp2) <- new_par
    p_fit <- semptools::set_edge_attribute(
      p_fit,
      values = tmp1,
      attribute_name = "color"
    )
    p_fit <- semptools::set_edge_attribute(
      p_fit,
      values = tmp2,
      attribute_name = "width"
    )
  }
  p_fit
}


gen_plots_a_to_b_i <- function(
  object_a_to_b_i,
  i = 1,
  ...
) {
  x <- object_a_to_b_i[[i]]
  if (isTRUE(is.na(x))) {
    # No b-models
    has_b_models <- FALSE
  } else {
    has_b_models <- TRUE
  }
  p_a <- x$from_model
  plot_from <- plot_model(
    pt = remove_fixed_zero(p_a),
    ...
  )
  if (!has_b_models) {
    out <- list(
            plot_from = plot_from,
            plot_to = list()
          )
    return(out)
  }
  p_b <- x$to_model
  f <- function(
    p_b_i
  ) {
    p_b_i_diff <- model_diff(
      p_a,
      p_b_i
    )
    diff_i <- p_b_i_diff$p_b_i
    if (diff_i$free > 0) {
      new_par <- lavaan::lav_partable_labels(diff_i)
      new_par_color <- "blue"
      new_par_width <- 5
    } else {
      new_par <- NULL
      new_par_color <- "white"
      new_par_width <- 0
    }
    tmp <- plot_model(
      pt = remove_fixed_zero(p_b_i),
      ...,
      new_par = new_par,
      new_par_color = new_par_color,
      new_par_width = new_par_width
    )
  }
  plot_to <- sapply(
    p_b,
    FUN = f,
    simplify = FALSE,
    USE.NAMES = TRUE
  )
  list(plot_from = plot_from,
       plot_to = plot_to)
}

plot_a_to_b_i <- function(
  p
) {
  # TODO:
  # - Check for zero plot_to
  k_from <- 1
  k_to <- length(p$plot_to)
  parold <- par(mfrow = c(k_to, 2), no.readonly = TRUE)
  for (i in seq_len(k_to)) {
    plot(p$plot_from)
    segments(1.25, 0, 1.5, 0, col = "red")
    plot(p$plot_to[[i]])
    arrows(-1.5, 0, -1.25, 0, col = "red")
  }
  par(parold)
}

library(semPlot)
library(semptools)

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

p_pt <- plot_model(pt)

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
tmp2 <- inspect_search(out, "more_to_same", iteration = 1)

layout_i <- layout_matrix(
  fx = c(2, 1),
  fm = c(1, 2),
  fy = c(2, 3)
)

p1 <- gen_plots_a_to_b_i(tmp1, layout = layout_i, asize = 20)
p2 <- gen_plots_a_to_b_i(tmp2, layout = layout_i, asize = 20)

# plot_a_to_b_i(p1)
# plot_a_to_b_i(p2)

})
