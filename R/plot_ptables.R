#' @title Plot Functions for a List of Models
#'
#' @description Various plot functions
#' for the output of [eq_models()],
#' [eq_df_models()], and
#' similar functions.
#'
#' @details
#' The functions provide different ways
#' to visualize the models. Basic knowledge
#' of [semPlot::semPaths()] from the
#' package `semPlot` is required to
#' customize the plots.
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
#' fit1_1_more <- drop_k(fit1)
#' fit1_1_more_1_less <- lapply(
#'   fit1_1_more,
#'   add_k
#' )
#'
#' partables1 <- combine_partables(fit1_1_more_1_less)
#' eq_out_1 <- eq_models(
#'           partables1,
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#'
#' eq_out_1 <- eq_models(
#'           partables1,
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#'
#' layout_i <- matrix(c(  NA, "fm",  NA,
#'                      "fx",   NA, "fy"),
#'                    ncol = 3,
#'                    nrow = 2,
#'                    byrow = TRUE)
#' layout_i
#' p <- partables_plots(
#'   eq_out_1,
#'   original_model = fit1,
#'   layout = layout_i,
#'   label.cex = 1.5,
#'   sizeLat = 15,
#'   edge.width = 5,
#'   asize = 5,
#'   structural = TRUE,
#'   par_diff_settings = list(
#'             color = "blue",
#'             width = 10
#'           )
#' )
#' plot(p)
#'
#'
#' @name plot_partables
NULL


#' @return
#' The function [partables_plots()] returns
#' a list of `qgraph` objects generated
#' from [semPlot::semPaths()], of the
#' class `partables_plots`.
#'
#' @param object If it is a list of models
#' (parameter tables), such as the output
#' of [eq_models()], it will be used
#' as the value for `partables`. If
#' it is a `partables_plots` object
#' (i.e., an output of [partables_plots()],
#' then it will be updated with any new
#' values for other arguments.
#'
#' @param partables It should be a list of
#' models in the form of parameter tables,
#' such as the output
#' of [eq_models()] or [eq_df_models()].
#'
#' @param original_model The model to
#' which models in `partables` will be
#' compared to. If `NULL`, then the
#' plots will be generated without checking
#' for differences between a model and
#' `original_model`. Model comparison is
#' conducted by [model_diff()].
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
#' width of an edge (arrow/path).
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
#' width of an edge (arrow/path). Setting the
#' width to zero, the default, effectively
#' hiding an arrow/path.
#'
#' @param exclude_original_model If `TRUE`
#' and `original_model` is set, the output
#' will not include the plot of the original
#' model, though this plot will be stored
#' in the attribute `"original_model"`,
#' as a one-element list.
#'
#' @param auto_node_color If `TRUE`,
#' and the number of nodes is less 12 or
#' less, they will be automatically
#' set to different colors. Ignored if
#' `color` of nodes is in `...`.
#'
#' @param curve_cov If `TRUE`, lines
#' denoting covariances will be automatically
#' curve. Implemented by calling
#' [auto_curve_covariance()].
#'
#' @param curve_cov_settings A named list
#' of arguments to be passed to
#' [auto_curve_covariance()]. Used only
#' if `curve_cov` is `TRUE`.
#'
#' @rdname plot_partables
#' @export
partables_plots <- function(
  object,
  ...,
  partables = NULL,
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
            ),
  exclude_original_model = FALSE,
  curve_cov = TRUE,
  curve_cov_settings = list(base_curve = 1.5)
) {

  is_update <- FALSE

  if (inherits(object, "partables_plots")) {

    # ==== Update a previous output ====

    is_update <- TRUE
    args_names <- names(formals())

    # Retrieve stored argument values

    args0 <- attr(object, "args")
    call_new <- as.list(match.call())[-1]
    # object is just a placeholder,
    # it can be previous output or
    # a partables for a new set of plots
    call_new$object <- NULL
    ddd_old <- args0[!(names(args0) %in% args_names)]
    eee_old <- args0[names(args0) %in% args_names]

    # Get the new values and evaluate them
    # TODO:
    # - How to handle arguments not named?
    ddd_new <- call_new[!(names(call_new) %in% args_names)]
    eee_new <- call_new[names(call_new) %in% args_names]
    ddd_new <- lapply(ddd_new, eval, envir = parent.frame())
    eee_new <- lapply(eee_new, eval, envir = parent.frame())

    ddd <- utils::modifyList(
      ddd_old,
      ddd_new,
      keep.null = TRUE
    )
    eee <- utils::modifyList(
      eee_old,
      eee_new,
      keep.null = TRUE
    )

    # modifyList does not handle an argument of list as desired
    eee$partables <- eee_new$partables %||% eee_old$partables
    eee$original_model <- eee_new$original_model

    # Set the argument values
    # TODO:
    # - Is there a better way to do this?
    partables <- eee$partables
    original_model <- eee$original_model
    auto_node_color <- eee$auto_node_color
    par_diff_settings <- eee$par_diff_settings
    fix_pars_fixed_zero <- eee$fix_pars_fixed_zero
    par_fixed_zero_settings <- eee$par_fixed_zero_settings
    exclude_original_model <- eee$exclude_original_model
    # eee is not needed after this line

  } else if (is_partables(object)) {

    # ==== A new set of plots ====

    partables <- object
    object <- NULL
    ddd <- list(...)

  }

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
      ddd,
      list(
        auto_node_color = auto_node_color,
        fix_pars_fixed_zero = fix_pars_fixed_zero,
        par_fixed_zero_settings = par_fixed_zero_settings,
        par_diff_settings = par_diff_settings,
        curve_cov = curve_cov,
        curve_cov_settings = curve_cov_settings
      )
    ),
    SIMPLIFY = FALSE,
    USE.NAMES = TRUE
  )

  out_org <- NULL

  if (exclude_original_model &&
      !is.null(original_model)) {

    # ==== Exclude the original model from the output? ====

    tmp <- partables %pt_in% as_eq_partables(original_model)
    if (any(tmp)) {
      out_org <- out[tmp]
      out <- out[!tmp]
      # attr(out, "original_model") <- out_org
    }
  }

  if (!is.null(original_model)) {

    # ==== Store the plot of the original model ====

    if (is.null(out_org)) {
      out_org <- do.call(
        partables_plots_internal,
        c(list(
            pt = original_model,
            auto_node_color = auto_node_color,
            fix_pars_fixed_zero = fix_pars_fixed_zero,
            par_fixed_zero_settings = par_fixed_zero_settings,
            par_diff_settings = par_diff_settings,
            curve_cov = curve_cov,
            curve_cov_settings = curve_cov_settings
          ),
          ddd)
      )
    }
    attr(out, "original_model") <- list(original_model = out_org)

  }

  # ==== Store Args ====

  if (is_update) {

    # ==== Store the updated argument values ====

    args <- c(ddd, eee)
    attr(out, "args") <- args

  } else {

    # ==== A new call ====

    call_new <- as.list(match.call())
    call_new[[1]] <- NULL
    # object is just a placeholder
    call_new$object <- NULL
    call_new <- lapply(
      call_new,
      eval,
      envir = parent.frame()
    )

    # Update the default values
    call0 <- formals()
    # object is just a placeholder
    call0$object <- NULL
    call0$... <- NULL
    call0 <- utils::modifyList(
      call0,
      call_new,
      keep.null = TRUE
    )
    # This is necessary because modifyList does not
    # handle argument values of names list as desired
    call0$partables <- partables
    call0$original_model <- original_model
    attr(out, "args") <- call0

  }

  # ==== Set class ====

  class(out) <- c("partables_plots", class(out))
  out

}

#' @return
#' The `plot` method of the output
#' of [partables_plots()] returns `x`
#' invisibly. Called for its side effect.
#'
#' @param x The output of [partables_plots()],
#' a `partables_plots` object.
#'
#' @param ... For [plot.partables_plots()],
#' these are optional arguments to be
#' passed to [semPlot::semPaths()].
#' For [print.partables_plots()], they
#' are not used.
#'
#' @param title_mode What will be used
#' as the title. If `"digest"`, then
#' the digest value of a model, generated
#' by [digest_partable()], will be
#' used as its title. If `"name"`, then
#' its name in `x` will be used, which may
#' also be the digest value. If
#' `"none"`, then no title will be drawn
#' with the plot.
#'
#' @param title_adj Adjust the position
#' of the title. Increase this value
#' if the plot is too close to the title,
#' and decrease this value if the space
#' between the plot and its title is
#' too large.
#'
#' @param title_args A named list of
#' arguments to be passed to [title()]
#' when printing the title.
#'
#' @param ncol,nrow The number of columns
#' and rows when drawing the models. Used
#' by `mfrow` in [par()].
#'
#' @param scale_plots How the models will
#' be scaled. If `"auto"`, then the models
#' will be scaled based on `ncol` and `nrow`,
#' using `scale` as a reference. If
#' `"always"`, then `scale` will always
#' be used to scale the models, even if
#' they are drawn one by one.
#'
#' @param scale How the model will
#' be furthered scaled when drawn. If this
#' value is greater than one, then
#' elements in `elements_to_scale` will
#' be increased by this ratio. If this
#' value is less than one, then elements
#' in `elements_to_scale` will be decreased
#' by this ratio.
#'
#' @param elements_to_scale Elements
#' in the `qgraph` object that will be
#' scaled based on the values of
#' `scale_plots` and `scale`.
#'
#' @param original_model_mode How original
#' model, if present will be handled when
#' drawing the models. If `"exclude"`,
#' then the original model will not be
#' drawn. If `"include"`, the original
#' model will be drawn as the first model,
#' along with other models. If `"side_by_side"`,
#' then the number of columns is always two
#' and the number of rows is always one.
#' In each plot, the original model will
#' be drawn on the left and the other
#' model will be drawn on the right.
#'
#' @rdname plot_partables
#' @export
plot.partables_plots <- function(
  x,
  ...,
  title_mode = c("digest", "name", "none"),
  title_adj = 1.4,
  title_args = list(),
  ncol = 1,
  nrow = 1,
  scale_plots = c("auto", "always"),
  scale = NULL,
  elements_to_scale = c(
    "Nodes:width",
    "Nodes:height",
    "Edges:width",
    "Edges:asize"
  ),
  original_model_mode = c("include", "exclude", "side_by_side")
) {
  original_model_mode <- match.arg(original_model_mode)
  scale_plots <- match.arg(scale_plots)
  title_mode <- match.arg(title_mode)

  x_org <- x

  if (original_model_mode == "side_by_side") {
    nrow <- 1
    ncol <- 2
  }
  parold <- par(mfrow = c(nrow, ncol), no.readonly = TRUE)

  original_model_list <- attr(x, "original_model")
  has_original_model <- !is.null(original_model_list)

  original_title_suffix <- "(Original)"
  if (has_original_model) {
    original_digest <- get_digest(original_model_list[[1]])
  } else {
    original_digest <- ""
  }

  if (has_original_model) {

    x_digest <- sapply(x, \(x) attr(x, "digest"))

    if (original_model_mode == "exclude") {

      # ==== Exclude the original model, if present ====

      x <- x[!(x_digest %in% original_digest)]

    }
    if (original_model_mode == "include") {

      # ==== Include the original model ====

      # x may not have the original model
      # Always insert or move the original model as the first plot
      x <- x[!(x_digest %in% original_digest)]
      x <- c(original_model_list,
            x)

    }
    if (original_model_mode == "side_by_side") {

      # ==== Side-By-Side ====

      # Insert or move the original model as the first plot
      x <- x[!(x_digest %in% original_digest)]
      x <- c(original_model_list,
            x)

      k0 <- seq_along(x)
      k1 <- sapply(
              k0[-1],
              \(x) c(1, x)
            )
      x <- x[k1]

    }
  }

  # ==== auto_scale ====

  if (scale_plots == "auto") {
    if (((ncol != 1) || (nrow != 1))) {
      scale_i <- scale %||% c(x = ncol / 2, y = nrow / 2)
      if (length(scale_i) == 1) {
        scale_i <- c(x = scale_i, y = scale_i)
      }
    } else {
      scale_i <- c(x = 1, y = 1)
    }
  }
  if (scale_plots == "always") {
    scale_i <- scale %||% c(x = 1, y = 1)
    if (length(scale_i) == 1) {
      scale_i <- c(x = scale_i, y = scale_i)
    }
  }
  if (any(scale_i != 1)) {
    x <- lapply(
      x,
      FUN = scale_plot,
      scale_x = scale_i["x"],
      scale_y = scale_i["y"],
      elements = elements_to_scale
    )
  }

  # ==== Plot the model ====

  for (i in seq_along(x)) {
    xx <- x[[i]]
    xx_name <- names(x)[i]
    if (title_mode != "none") {
      xx$plotOptions$mar[3] <- xx$plotOptions$mar[3] * title_adj
    }
    plot(xx,
         ...)
    xx_digest <- attr(xx, "digest")
    tmp <- switch(
      title_mode,
      digest = xx_digest,
      name = xx_name,
      none = NULL
    )

    if (xx_digest == original_digest) {
      tmp <- paste(tmp, original_title_suffix)
    }

    if (!is.null(tmp)) {
      do.call(
        match.fun("title"),
        c(list(main = tmp),
          title_args)
      )
    }
  }
  par(parold)
  invisible(x)
}

#' @return
#' The `print` method of the output
#' of [partables_plots()] returns `x`
#' invisibly. Called for its side effect.
#'
#' @rdname plot_partables
#' @export
print.partables_plots <- function(
  x,
  ...
) {
  x1 <- x
  class_old <- class(x)
  i <- which(class_old == "partables_plots")
  if (length(i) > 0)
  class(x1) <- class_old[-seq(1, i)]
  k <- length(x1)
  x_names <- names(x1)
  cat("The plot(s) of", k, "model(s):\n")
  if (!is.null(x_names)) {
    print(x_names)
  } else {
    x_names <- sapply(x, \(x) attr(x, "digest"))
    print(unname(x_names))
  }
  invisible(x)
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
            ),
  curve_cov = TRUE,
  curve_cov_settings = list(base_curve = 1.5)
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

  if (curve_cov) {

    # ==== Curve covariance edges ====

    auto_curve_covariance_args <-
      utils::modifyList(
        curve_cov_settings,
        list(qgraph_obj = p_fit)
      )
    p_fit <- do.call(
        auto_curve_covariance,
        auto_curve_covariance_args
      )
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
  attr(p_fit, "partable") <- pt

  p_fit
}

#' @noRd
scale_plot <- function(
  object,
  scale_x = 1,
  scale_y = 1,
  elements = c(
#    "Nodes:label.cex",
    "Nodes:width",
    "Nodes:height",
#    "Edges:label.cex",
    "Edges:width",
    "Edges:asize"
  )
) {
  out <- object
  for (xx in elements) {
    xx1 <- strsplit(xx, ":")[[1]]
    scale1 <- switch(
      xx1[2],
      width = max(scale_x, scale_y),
      height = max(scale_y, scale_x),
#      label.cex = min(scale_x, scale_y),
      max(scale_x, scale_y)
    )
    out$graphAttributes[[xx1[1]]][[xx1[2]]] <-
      out$graphAttributes[[xx1[1]]][[xx1[2]]] * scale1
  }
  out
}

#' @return
#' The `%p>%` operator returns a
#' `partables_plots` object, processed
#' by the right-hand side function.
#'
#' @param lhs A `partables_plots` object.
#'
#' @param rhs A function call to be applied
#' to all stored plots. Each plot will
#' be inserted as the first argument.
#'
#' @rdname plot_partables
#' @export
`%p>%` <- function(
  lhs,
  rhs
) {

  # A pipe operator to process all stored plots

  rhs_call <- as.list(substitute(rhs))
  fct <- eval(rhs_call[[1]])
  out <- lapply(
    lhs,
    \(x) {do.call(
      fct,
      c(list(x),
        rhs_call[-1])
    )}
  )

  # ==== Has an original model? ====

  original_model <- attr(lhs, "original_model")
  has_original_model <- !is.null(original_model)
  if (has_original_model) {
    out0 <-
        do.call(
          fct,
          c(list(original_model[[1]]),
            rhs_call[-1])
      )
    original_model_modified <- original_model
    original_model_modified[[1]] <- out0
  }

  # ==== Finalize the output ====

  out <- overwrite_attributes(
          out,
          lhs
        )
  if (has_original_model) {
    attr(out, "original_model") <- original_model_modified
  }
  out
}