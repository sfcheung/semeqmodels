#' @importFrom graphics arrows
#' @importFrom graphics par
#' @importFrom graphics plot.new
#' @importFrom graphics segments
#' @importFrom graphics text
#' @importFrom graphics title

#' @noRd
partables_a_to_b <- function(
  object,
  a_to_b = c("same_to_more", "more_to_same"),
  iteration = 1
) {
  # Return a matrix of the relations
  # between models in the i-th iteration.
  # From more-df models to same-df models,
  # or from same-df models to more-df models.
  a_to_b <- match.arg(a_to_b)
  a <- switch(
        a_to_b,
        same_to_more = "same",
        more_to_same = "more"
  )
  b <- switch(
        a_to_b,
        same_to_more = "more",
        more_to_same = "same"
  )
  pts_a_to_b_history <- switch(
      a,
      same = attr(object, "pts_same_to_more_history"),
      more = attr(object, "pts_more_to_same_history")
    )
  pts_a_to_b_history_i <- pts_a_to_b_history[[iteration]]
  pts_a_i <- names(pts_a_to_b_history_i)
  pts_b_i <- unique(unname(unlist(pts_a_to_b_history_i)))
  k_a_i <- length(pts_a_i)
  k_b_i <- length(pts_b_i)
  # TODO:
  # Handle zero row/column
  out0 <- matrix(
            0,
            ncol = k_a_i,
            nrow = k_b_i
          )
  colnames(out0) <- pts_a_i
  rownames(out0) <- pts_b_i
  if (min(dim(out0)) == 0) {
    return(out0)
  }
  for (xx in pts_a_i) {
    yy <- pts_a_to_b_history_i[[xx]]
    if (length(yy) > 0) {
      out0[yy, xx] <- iteration
    }
  }
  out0
}

#' @noRd
inspect_search <- function(
  object,
  a_to_b = c("same_to_more", "more_to_same"),
  iteration = 1,
  what = c("partables", "model_diff")
) {
  # Find the changes in an iteration
  what <- match.arg(what)
  a_to_b <- match.arg(a_to_b)
  a_to_b_matrix <- partables_a_to_b(
    object = object,
    a_to_b = a_to_b,
    iteration = iteration
  )
  # TODO:
  # - Sanity check: zero row/column
  pts_same <- c(object, attr(object, "pts_excluded"))
  pts_same <- rename_to_digest(pts_same)
  pts_more <- attr(object, "pts_more_df_all")
  pts_a <- switch(
    a_to_b,
    "same_to_more" = pts_same,
    "more_to_same" = pts_more
  )
  pts_b <- switch(
    a_to_b,
    "same_to_more" = pts_more,
    "more_to_same" = pts_same
  )
  a_names <- colnames(a_to_b_matrix)
  b_names <- rownames(a_to_b_matrix)
  pts_a_i <- pts_a[a_names]
  pts_b_i <- pts_b[b_names]
  f_model_diff <- function(
    xx,
    pts_a_i,
    pts_b_i,
    a_to_b_matrix) {
    tmp <- a_to_b_matrix[, xx] > 0
    if (isFALSE(any(tmp))) {
      return(NA)
    }
    b_names_xx <- rownames(a_to_b_matrix)[tmp]
    out_i <- model_diff_many(
      target_model = pts_a_i[[xx]],
      other_models = pts_b_i[b_names_xx],
      target_model_name = xx,
      other_models_names = b_names_xx
    )
    out_i
  }
  f_partables <- function(
    xx,
    pts_a_i,
    pts_b_i,
    a_to_b_matrix) {
    out_i <- list(
      from_model = pts_a_i[[xx]]
    )
    tmp <- a_to_b_matrix[, xx] > 0
    if (isFALSE(any(tmp))) {
      out_i$to_model <- list()
    } else {
      b_names_xx <- rownames(a_to_b_matrix)[tmp]
      out_i$to_model <- pts_b_i[b_names_xx]
    }
    out_i
  }
  f <- switch(
            what,
            model_diff = f_model_diff,
            partables = f_partables
         )
  out0 <- sapply(
    a_names,
    FUN = f,
    pts_a_i = pts_a_i,
    pts_b_i = pts_b_i,
    a_to_b_matrix = a_to_b_matrix,
    simplify = FALSE,
    USE.NAMES = TRUE
  )
  out0
}

#' @noRd
inspect_search_full <- function(
  object
) {
  k_same_to_more <- length(
      attr(object, "pts_same_to_more_history")
    )
  k_more_to_same <- length(
      attr(object, "pts_more_to_same_history")
    )
  k <- max(k_same_to_more, k_more_to_same)
  out0 <- vector("list", k)
  for (i in seq_len(k)) {
    if (i <= k_same_to_more) {
      out0[[i]]$same_to_more <- inspect_search(
        object,
        "same_to_more",
        iteration = i
      )
    }
    if (i <= k_more_to_same) {
      out0[[i]]$more_to_same <- inspect_search(
        object,
        "more_to_same",
        iteration = i
      )
    }
  }
  out0
}

#' @noRd
gen_plot <- function(
  pt,
  ...,
  fix_cov = FALSE,
  cov_color = "red",
  new_par = NULL,
  new_par_color = "black",
  new_par_width = 2,
  structural = TRUE
) {
  # Internal function (for now)
  # Generate the plot for a model

  pt$lavlabel <- lavaan::lav_partable_labels(pt)

  p_fit <- semPlot::semPaths(
    pt,
    ...,
    residuals = FALSE,
    structural = structural,
    DoNotPlot = TRUE
  )

  # ==== Set the colors for nodes ====

  # TODO:
  # - Can use semptools::set_edge_color()

  k_nodes <- length(p_fit$graphAttributes$Nodes$color)
  if (k_nodes <= 12) {
    color_nodes <- RColorBrewer::brewer.pal(k_nodes, "Set3")
    p_fit <- semPlot::semPaths(
      pt,
      ...,
      color = color_nodes,
      residuals = FALSE,
      structural = structural,
      DoNotPlot = TRUE
    )
  }

  # ==== Configure covariance edges ====

  p_fit_vars <- names(p_fit$graphAttributes$Nodes$labels)
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

  # ==== Configure paths fixed to zero ====

  i_fixed_zero <- (pt$free == 0) &
                  (pt$op %in% c("~", "~~", "=~")) &
                  (pt$start == 0)
  if (any(i_fixed_zero)) {
    pars_fixed_zero <- pt$lavlabel[i_fixed_zero]
    tmp1 <- "white"
    tmp2 <- 0
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

  # ==== Configure new parameters ====

  if (!is.null(new_par)) {
    tmp1 <- new_par_color
    tmp2 <- new_par_width
    for (xx in new_par) {
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

  p_fit
}

#' @noRd
gen_plots_eq_models <- function(
  original_model,
  other_models,
  ...,
  new_par_color = "blue",
  new_par_width = 5
) {
  original_model_fixed <- fix_object(original_model)
  out0 <- list()
  out0$from_model <- original_model_fixed$partable
  out0$to_model <- other_models
  p0 <- gen_plots_a_to_b_i(
    out0,
    ...,
    new_par_color = new_par_color,
    new_par_width = new_par_width
  )
  p0
}

#' @noRd
plot_eq_models <- function(
  p
) {
  # Just an alias for now.
  # Will add more features later.
  plot_a_to_b_i(p)
}

#' @noRd
gen_plots_a_to_b_i <- function(
  x,
  ...,
  new_par_color = "blue",
  new_par_width = 5
) {
  # An internal function
  # Generate two plots for
  # one model in an iteration.
  # Should be the output of
  # inspect_search(), with output
  # format parameter tables.

  if (length(x$to_model) == 0) {
    # No b-models
    has_b_models <- FALSE
  } else {
    has_b_models <- TRUE
  }

  # ==== Generate the plot for 'from_model' ====

  p_a <- x$from_model
  plot_from <- gen_plot(
    pt = p_a,
    ...
  )
  attr(plot_from, "digest") <- get_digest(x$from_model)
  attr(plot_from, "gen_models_name") <- attr(x$from_model, "gen_models_name")

  # ==== No 'to_model' ====

  if (!has_b_models) {
    out <- list(
            plot_from = plot_from,
            plot_to = list()
          )
    return(out)
  }

  # ==== Generate the plots for 'to_model' ====

  p_b <- x$to_model
  f <- function(
    p_b_i
  ) {
    p_b_i_diff <- model_diff(
      p_a,
      p_b_i
    )
    diff_i <- p_b_i_diff$p_b_i
    if (any(diff_i$free > 0)) {
      new_par <- lavaan::lav_partable_labels(diff_i)
    } else {
      new_par <- NULL
    }
    plot_to_i <- gen_plot(
      pt = p_b_i,
      ...,
      new_par = new_par,
      new_par_color = new_par_color,
      new_par_width = new_par_width
    )
    attr(plot_to_i, "digest") <- get_digest(p_b_i)
    attr(plot_to_i, "gen_models_name") <- attr(p_b_i, "gen_models_name")
    plot_to_i
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
  k_to <- length(p$plot_to)
  if (k_to == 0) {
    has_to_models <- FALSE
    k_to <- 1
  } else {
    has_to_models <- TRUE
  }
  parold <- par(mfrow = c(1, 2), no.readonly = TRUE)
  on.exit(par(parold))
  if (!has_to_models) {
    plot(p$plot_from)
    p_digest <- attr(p$plot_from, "digest")
    if (!is.null(p_digest)) {
      title(main = p_digest)
    }
    plot.new()
    text(.5, .5, "No model")
  } else {
    for (i in seq_len(k_to)) {
      plot(p$plot_from)
      segments(1.25, 0, 1.5, 0, col = "red")
      p_digest <- attr(p$plot_from, "digest")
      if (!is.null(p_digest)) {
        title(main = p_digest)
      }
      plot(p$plot_to[[i]])
      arrows(-1.5, 0, -1.25, 0, col = "red")
      p_digest <- attr(p$plot_to[[i]], "digest")
      if (!is.null(p_digest)) {
        title(main = p_digest)
      }
    }
  }
}

#' @noRd
gen_plots_for_search <- function(
  object,
  ...
) {
  # Internal function (for now)
  # Generate the plots for the full search
  # history.
  # object should be the output of
  # inspect_search_full().
  k <- length(object)
  out <- vector("list", k)
  for (i in seq_len(k)) {
    if (length(object[[i]]$same_to_more) > 0) {
      out[[i]]$same_to_more_plots <- sapply(
        object[[i]]$same_to_more,
        gen_plots_a_to_b_i,
        ...,
        simplify = FALSE,
        USE.NAMES = TRUE
      )
    } else {
      out[[i]]$same_to_more_plots <- list()
    }
    if (length(object[[i]]$more_to_same) > 0) {
      out[[i]]$more_to_same <- sapply(
        object[[i]]$more_to_same,
        gen_plots_a_to_b_i,
        ...,
        simplify = FALSE,
        USE.NAMES = TRUE
      )
    }
  }
  out
}

#' @noRd
plot_search_history <- function(
  p_full
) {
  # Internal function (for now)
  # Plot all the plots in the outputs
  # of gen_plots_for_search()
  for (xx in p_full) {
    for (yy in xx$same_to_more) {
      plot_a_to_b_i(yy)
    }
    for (yy in xx$more_to_same) {
      plot_a_to_b_i(yy)
    }
  }
}
