#' @title Plot Functions for a List of Parameter Tables
#'
#' @description Various plot functions
#' for the output of [eq_models()] and
#' similar functions.
#'
#' @details
#' The functions provide different ways
#' to visualize the models. Basic knowledge
#' of [semPlot::semPaths()] from the
#' package `semPlot` is required.
#'
#' @seealso See [eq_models()] on the
#' type of output supported.
#'
#' @examples
#' library(lavaan)
#'
#' # Model 1
#'
#' mod1 <-
#' "
#' fx =~ x1 + x2 + x3
#' fm =~ m1 + m2 + m3
#' fy =~ y1 + y2 + y3
#' fm ~ fx
#' fy ~ fm + fx
#' "
#' fit1 <- sem(
#'           model = mod1,
#'           data = data_test_3_factor_3_item
#'         )
#'
#' eq_out_1 <- eq_models(
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#' # Add examples for plots
#'
#' @name plot_partables
NULL


#' @return
#' The function [partables_plots()] returns
#' a list of `qgraph` objects generated
#' from [semPlot::semPaths()].
#'
#' @param partables It should be a list of
#' parameter tables, such as the output
#' of [eq_models()] or [eq_df_models()].
#'
#' @param original_model The model to
#' which models in `partables` will be
#' compared to. If `NULL`, then the
#' plots will be generated without checking
#' for differences between a model and
#' `original_model`.
#'
#' @param ... Optional arguments to be
#' passed to [semPlot::semPaths()]. They
#' will be applied to all plots.
#'
#' @param par_diff_settings A named list of
#' settings to configure the change of
#' a parameter from `original_model`
#' to a model in `partables`. For now,
#' two settings are supported: `color`
#' for the color and `width` for the
#' width of an edge (arrow).
#'
#' @param fix_pars_fixed_zero If `TRUE`,
#' parameters fixed to zero will be
#' modified based on `par_fixed_zero_settings`.
#'
#' @param par_fixed_zero_settings A named
#' settings to configure edges (arrows)
#' fixed to zero. For now,
#' two settings are supported: `color`
#' for the color and `width` for the
#' width of an edge (arrow). Setting the
#' width to zer0, the default, effectively
#' hide an arrow.
#'
#' @param auto_node_color If `TRUE`,
#' and the number of nodes is less 12 or
#' less, they will be automatically
#' set to different colors. Ignored if
#' `color` of nodes is in `...`.
#'
#' @rdname plot_partables
#' @export
partables_plots <- function(
  partables,
  ...,
  original_model = NULL,
  auto_node_color = TRUE,
  par_diff_settings = list(
              color = "blue",
              width = 2
            ),
  fix_pars_fixed_zero = TRUE,
  par_fixed_zero_settings = list(
              color = "white",
              width = 0
            )
) {
  if (!is_partables(partables)) {
    stop("partables is not of a supported type.")
  }

  if (!is.null(original_model)) {
    if (!is_partable(original_model)) {
      if (!inherits(original_model, "lavaan")) {
        stop("original_model is not of a supported type.")
      }
      original_model <- lavaan::parameterTable(original_model)
    }

    # ==== Generate Model Differences ====

    f0 <- function(
      pt_i,
      original_model
    ) {
      pt_diff_i <- model_diff(
        original_model,
        pt_i
      )
      diff_i <- pt_diff_i$pt_i
      if (any(diff_i$free > 0)) {
        new_par <- lavaan::lav_partable_labels(diff_i)
      } else {
        new_par <- NULL
      }
      new_par
    }
    pt_pars_diff <- lapply(
      partables,
      FUN = f0,
      original_model = original_model
    )
  } else {
    pt_pars_diff <- vector("list", length(partables))
  }

  # ==== Generate the Plots ====

  out <- mapply(
    FUN = partables_plots_internal,
    pt = partables,
    pars_diff = pt_pars_diff,
    MoreArgs = c(
      list(...),
      list(
        auto_node_color = auto_node_color,
        fix_pars_fixed_zero = fix_pars_fixed_zero,
        par_fixed_zero_settings = par_fixed_zero_settings
      )
    ),
    SIMPLIFY = FALSE,
    USE.NAMES = TRUE
  )
  class(out) <- c("partables_plots", class(out))
  out
}

#' @rdname plot_partables
#' @export
plot.partables_plots <- function(
  x,
  ...,
  title = c("digest", "name", "none"),
  ncol = 1,
  nrow = 1
) {
  title <- match.arg(title)
  parold <- par(mfrow = c(nrow, ncol), no.readonly = TRUE)
  for (i in seq_along(x)) {
    xx <- x[[i]]
    xx_name <- names(x)[i]
    plot(xx,
         ...)
    xx_digest <- attr(xx, "digest")
    tmp <- switch(
      title,
      digest = xx_digest,
      name = xx_name,
      none = NULL
    )
    if (!is.null(tmp)) {
      title(main = tmp)
    }
  }
  par(parold)
}

#' @noRd
partables_plots_internal <- function(
  pt,
  ...,
  fix_cov = FALSE,
  cov_settings = list(
              color = "red"
            ),
  auto_node_color = TRUE,
  pars_diff = NULL,
  par_diff_settings = list(
              color = "blue",
              width = 2
            ),
  fix_pars_fixed_zero = TRUE,
  par_fixed_zero_settings = list(
              color = "white",
              width = 0
            )
) {
  # Internal function (for now)
  # Generate the plot for a model

  pt$lavlabel <- lavaan::lav_partable_labels(pt)

  ddd <- list(...)
  # Can be overriden
  semPaths_default <- list(
    residuals = FALSE
  )
  ddd1 <- utils::modifyList(
    semPaths_default,
    ddd
  )
  # Cannot be overriden
  ddd1 <- utils::modifyList(
    ddd1,
    list(
      object = pt,
      DoNotPlot = TRUE
    )
  )

  p_fit <- do.call(
    semPlot::semPaths,
    ddd1
  )

  if (is.null(ddd$color) &&
      auto_node_color) {

    # ==== Set the colors for nodes ====

    k_nodes <- length(p_fit$graphAttributes$Nodes$color)
    node_names <- p_fit$graphAttributes$Nodes$names

    if (k_nodes <= 12) {
      # TODO:
      # - Try paletteer_d("ggsci::default_ucscgb")
      color_nodes <- RColorBrewer::brewer.pal(k_nodes, "Set3")
      # Ensure the assignment of colors are the same
      # across models.
      names(color_nodes) <- sort(node_names)
      color_nodes <- color_nodes[node_names]
      ddd1 <- utils::modifyList(
        ddd1,
        list(color = color_nodes)
      )
      p_fit <- do.call(
        semPlot::semPaths,
        ddd1
      )
    }
  }

  if (fix_cov) {

    # ==== Covariance edges ====

    p_fit_vars <- names(p_fit$graphAttributes$Nodes$labels)
    i <- (pt$lhs %in% p_fit_vars) &
         (pt$op == "~~") &
         (pt$lhs != pt$rhs)
    if (any(i) && fix_cov) {
      covs <- pt$lavlabel[i]
      cov_colors <- rep(cov_settings$color, length(covs))
      names(cov_colors) <- covs
      p_fit <- semptools::set_edge_color(
                  p_fit,
                  color_list = cov_colors
                )
    }
  }

  if (fix_pars_fixed_zero) {

    # ==== Paths fixed to zero ====

    i_fixed_zero <- (pt$free == 0) &
                    (pt$op %in% c("~", "~~", "=~")) &
                    (pt$start == 0)
    if (any(i_fixed_zero)) {
      pars_fixed_zero <- pt$lavlabel[i_fixed_zero]
      tmp1 <- par_fixed_zero_settings$color
      tmp2 <- par_fixed_zero_settings$width
      for (xx in pars_fixed_zero) {
        names(tmp1) <- xx
        names(tmp2) <- xx
        p_fit <- tryCatch(
            semptools::set_edge_color(
              p_fit,
              color_list = tmp1
            ),
            error = function(e) p_fit
          )
        p_fit <- tryCatch(
            semptools::set_edge_attribute(
              p_fit,
              values = tmp2,
              attribute_name = "width"
            ),
            error = function(e) p_fit
          )
      }
    }

  }

  # ==== Parameter Differences ====

  if (!is.null(pars_diff)) {
    tmp1 <- par_diff_settings$color
    tmp2 <- par_diff_settings$width
    for (xx in pars_diff) {
      names(tmp1) <- xx
      names(tmp2) <- xx
      p_fit <- tryCatch(
        semptools::set_edge_attribute(
          p_fit,
          values = tmp1,
          attribute_name = "color"
        ),
        error = function(e) p_fit)
      p_fit <- tryCatch(
        semptools::set_edge_attribute(
          p_fit,
          values = tmp2,
          attribute_name = "width"
        ),
        error = function(e) p_fit)
    }
  }

  # ==== Additional Info ====

  attr(p_fit, "digest") <- get_digest(pt)
  attr(p_fit, "gen_models_name") <- attr(pt, "gen_models_name")

  p_fit
}
