#' @title Summary of Parameter Estimates Across Models
#'
#' @description
#' Summarize parameter estimates across
#' a set of equivalent models, returning
#' the requested aggregate statistics
#' for each parameter.
#'
#' @details
#' The input is usually the result of
#' [eq_models()], but any `partables`
#' object containing fitted models can
#' be used. Estimates are grouped by the
#' parameter label and its `lhs`, `op`,
#' and `rhs` values, then summarized
#' across models. Parameters without an
#' estimate in a model are omitted from
#' that model's aggregates.
#'
#' The function summarizes
#' fully standardized (`std.all`)
#' estimates. For standardized output,
#' variances (`~~` parameters with the
#' same variable on both sides) are
#' represented as R-squares (`op =
#' "r2"`), calculated as one minus the
#' standardized error variance. Set
#' `standardized = FALSE` to summarize
#' unstandardized estimates instead.
#'
#' If no model is marked as the original
#' model, the first model in `object` is
#' used to establish the common
#' parameter ordering.
#'
#' @param object A `partables` object,
#' typically the output of
#' [eq_models()].
#'
#' @param level A confidence level
#' passed to the functions that
#' extract parameter estimates from
#' each fitted model. Confidence
#' intervals are not included in the
#' summary, so this argument does not
#' affect the returned aggregate
#' estimates for now. It may be used
#' in the future.
#'
#' @param standardized Logical; if
#' `TRUE` (the default), summarize fully
#' standardized (`std.all`) estimates;
#' if `FALSE`, summarize unstandardized
#' estimates. Standardized error
#' variances are reported as R-squares.
#'
#' @param trim_par_label Logical; if
#' `TRUE` (the default), remove the
#' trailing `.1.1` from `par_label` when
#' all labels have that suffix (the
#' single-block, single-group case). Set
#' to `FALSE` to retain the block and
#' group indices.
#'
#' @param col Character vector selecting
#' which aggregate columns to return.
#' Choose from `"mean"`, `"min"`,
#' `"max"`, and `"n"`; the default
#' returns all four. At least one value
#' is required. The identifier columns
#' are always returned.
#'
#' @return
#' A `lavaan.data.frame` (also a data
#' frame) with parameter identifiers and
#' the requested aggregate columns:
#'
#' - `par_label`: A label based on the
#'   two variables, block, and group,
#'   independent of the operator. For
#'   example, `x ~ y`, `y ~ x`, and `x
#'   ~~ y` share the same label. The
#'   block and group suffix is omitted
#'   by default when all parameters are
#'   from block 1 and group 1.
#'
#' - `lhs`, `op`, `rhs`: The left-hand
#'   side, operator, and right-hand side
#'   of the parameter, as in `lavaan`
#'   model syntax. If `op` is `"r2"`,
#'   `lhs` identifies the variable whose
#'   R-square is reported and `rhs` is
#'   empty.
#'
#' - `mean`, `min`, `max`: If requested,
#'   the arithmetic mean, minimum, and
#'   maximum of the available estimates
#'   for that parameter across models.
#'
#' - `n`: If requested, the number of
#'   non-missing estimates included in
#'   the aggregates. It can be smaller
#'   than the number of models when a
#'   parameter is absent or has no
#'   estimate in some models.
#'
#' @seealso [eq_models()] for
#' the function to generate the models.
#'
#' @examples
#'
#' library(lavaan)
#'
#' # For illustration, only a few models are generated below,
#' # using drop_k() and add_k manually.
#' # These two functions are usually not used directly.
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
#' # All equivalent
#' partables1 <- combine_partables(fit1_1_more_1_less)
#'
#' eq_out_1 <- eq_models(
#'           partables1,
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#'
#' est_summary(eq_out_1)
#'
#' # Select statistics and use unstandardized estimates
#' est_summary(
#'   eq_out_1,
#'   standardized = FALSE,
#'   col = c("mean", "n")
#' )
#'
#' # The usual way to use eq_models:
#' # 'parallel' should be set to TRUE or omitted
#' # eq_out_all <- eq_models(
#' #           original_model = fit1
#' #         )
#' # eq_out_all
#'
#' @export
est_summary <- function(
  object,
  level = .95,
  standardized = TRUE,
  trim_par_label = TRUE,
  col = c("mean", "min", "max", "n")
) {
  # TODO:
  # - Support SE and related statistics.
  #   Require modeblbpp 0.4.0.1 or above
  if (inherits(object, "partables")) {
    object <- merge_all_est(
      object,
      level = level
    )
  } else {
    stop("object is not of a supported class.")
  }
  col <- match.arg(col, several.ok = TRUE)
  if (length(col) < 1L) {
    stop("col must have at least one value")
  }
  obj <- object
  if (standardized) {
    # Replace ustd by std
    tmp <- colnames(obj)
    tmp2 <- grepl("\\.std$", tmp)
    tmp3 <- gsub(".std", "", tmp[tmp2])
    obj <- obj[, !(tmp %in% tmp3), drop = FALSE]
    tmp <- colnames(obj)
    tmp3 <- gsub("\\.std$", "", tmp)
    colnames(obj) <- tmp3
    # If standardized, all variances are error variances
    # Convert them to R-squares
    i <- (obj$lhs_original == obj$rhs_original) &
         (obj$op_original == "~~")
    if (any(i)) {
      obj$op_original[i] <- "r2"
      obj$rhs_original[i] <- ""
      obj$est[i] <- 1 - obj$est[i]
    }
  }
  obj$lhs_label <- obj$lhs
  obj$op_label <- obj$op
  obj$rhs_label <- obj$rhs
  obj$lhs <- obj$lhs_original
  obj$op <- obj$op_original
  obj$rhs <- obj$rhs_original
  # Do not consider fixed variance
  i1 <- is.na(obj$z)
  i2 <- obj$lhs == obj$rhs
  i3 <- obj$op == "~~"
  obj$est[i1 & i2 & i3] <- NA

  # Output column
  # - For est:
  #   - mean
  #   - min
  #   - max
  #   - # models
  if ("mean" %in% col) {
    x_mean <- stats::aggregate(
            est ~ par_label + lhs + op + rhs,
            FUN = mean,
            data = obj,
            na.rm = TRUE
          )
    x_mean$mean <- x_mean$est
    x_mean$est <- NULL
  } else {
    x_mean <- NULL
  }
  if ("min" %in% col) {
    x_min <- stats::aggregate(
            est ~ par_label + lhs + op + rhs,
            FUN = min,
            data = obj,
            na.rm = TRUE
          )
    x_min$min <- x_min$est
    x_min$est <- NULL
  } else {
    x_min <- NULL
  }
  if ("max" %in% col) {
    x_max <- stats::aggregate(
            est ~ par_label + lhs + op + rhs,
            FUN = max,
            data = obj,
            na.rm = TRUE
          )
    x_max$max <- x_max$est
    x_max$est <- NULL
  } else {
    x_max <- NULL
  }
  if ("n" %in% col) {
    x_n <- stats::aggregate(
            est ~ par_label + lhs + op + rhs,
            FUN = length,
            data = obj
          )
    x_n$n <- x_n$est
    x_n$est <- NULL
  } else {
    x_n <- NULL
  }
  out0 <- Reduce(
    function(x, y) {
      if (is.null(x) || is.null(y)) {
        return(x %||% y)
      }
      merge(x, y,
            all = TRUE)
    },
    list(
      x_mean,
      x_min,
      x_max,
      x_n
    )
  )
  if (trim_par_label) {
    if (all(grepl("\\.1\\.1$", out0$par_label))) {
      out0$par_label <- gsub(
        "\\.1\\.1$",
        "",
        out0$par_label
      )
    }
  }
  # Order
  # - lhs-rhs
  # - =~
  # - ~1
  # - r2
  out0$order0 <- 1
  out0$order0[out0$op == "=~"] <- 2
  out0$order0[out0$op == "~1"] <- 3
  out0$order0[out0$op == "r2"] <- 4
  out0 <- sort_by(
    out0,
    ~ list(order0, par_label, op)
  )
  out0$order0 <- NULL
  row.names(out0) <- NULL
  attr(out0, "eq_models_attributes") <- attr(object, "eq_models_attributes")
  attr(out0, "number_of_models") <- length(unique(object$model))
  class(out0) <- c("est_summary", "lavaan.data.frame", class(out0))
  out0
}

#' @noRd
# Output:
# - Combine all parameter estimates into
#   one data frame.
merge_all_est <- function(
  object,
  level = .95,
  ...
) {
  est_list <- lapply(
    object,
    \(x, level) {
      est_full(
        attr(x, "fit"),
        level = level
      )
    },
    level = level
  )
  object1 <- common_order(est_list)
  i_original <- which_original_model(object)
  has_original <- !is.na(unname(i_original))
  if (!has_original) {
    # Let the first model be the original
    i_original <- 1
  }
  model_original <- object1[[i_original]]
  original_order <- order(model_original$id)
  # Common order
  object1 <- lapply(
    object1,
    \(x) {
      x[original_order, ]
    }
  )
  out0 <- do.call(
    rbind,
    object1
  )
  tmp <- class(out0)
  class(out0) <- tmp[!(tmp %in% "lavaan.parameterEstimates")]
  row.names(out0) <- NULL
  tmp <- setdiff(
    names(attributes(object)),
    c("names", "class",
      "pts_same_to_more_history",
      "pts_more_to_same_history",
      "pts_more_df_all",
      "pts_excluded",
      "args")
  )
  if (length(tmp) > 0L) {
    tmp_attr <- lapply(
      tmp,
      \(x) attr(object, x)
    )
    names(tmp_attr) <- tmp
    attr(out0, "eq_models_attributes") <- tmp_attr
  }
  out0
}

#' @noRd
# Output:
# - Parameter estimates table with as much info as possible
est_full <- function(
  fit,
  level = .95
) {
  pt <- lavaan::parameterTable(fit)
  # TODO:
  # - Check whether block/group is in est and std
  # - Support R-square in the future
  # - Support defined parameters in the future
  est <- lavaan::parameterEstimates(
    fit,
    zstat = TRUE,
    pvalue = TRUE,
    ci = TRUE,
    standardized = FALSE,
    level = level,
    rsquare = FALSE,
    remove_def = TRUE,
    remove_step1 = FALSE,
    remove_aux = FALSE,
    add_attributes = TRUE,
    output = "data.frame",
    header = TRUE
  )
  std <- lavaan::standardizedSolution(
    fit,
    type = "std_all",
    level = level,
    remove_aux = FALSE,
    remove_def = TRUE
  )
  tmp <- colnames(std)
  tmp1 <- c("lhs", "op", "rhs", "est.std", "block", "group")
  i <- !(tmp %in% tmp1)
  tmp[i] <- paste0(tmp[i], ".std")
  colnames(std) <- tmp
  # Set fixed variance to NA
  exo <- unique(unlist(lavaan::lavNames(
    est,
    c("ov_x", "lv_x", "ov_orphan")
  )))
  if (length(exo) > 0L) {
    i <- (std$lhs == std$rhs) &
        (std$op == "~~") &
        (std$lhs %in% exo)
    std$est.std[i] <- NA
  }
  out0 <- pt
  out0$est <- NULL
  out0$se <- NULL
  max_id <- max(pt$id)
  rsq_id <- seq_len(sum(est$op == "r2")) + max_id
  est$rsq_id <- NA_integer_
  est$rsq_id[est$op == "r2"] <- rsq_id
  out0 <- merge(
    out0,
    est,
    all = TRUE
  )
  out0 <- merge(
    out0,
    std,
    all = TRUE
  )
  out0$id[out0$op == "r2"] <- out0$rsq_id[out0$op == "r2"]
  out0$rsq_id <- NULL
  out0 <- sort_by(
    out0,
    ~ list(id)
  )
  out0$rhs[out0$op == "r2"] <- ""
  tmp <- setdiff(
    names(attributes(est)),
    c("names", "row.names")
  )
  for (i in tmp) {
    attr(out0, i) <- attr(est, i)
  }
  out0
}

#' @noRd
# Output:
# - All parameter tables have
#   - The same rows
#   - The same columns
#   - Sample order in lhs-rhs for `~~`
common_order <- function(
  pt_list,
  add_pt_name = TRUE
) {
  sort_by <- c("lhs", "op", "rhs", "block", "group")
  lorbg <- lapply(
    pt_list,
    \(x) {
      x$lhs_original <- x$lhs
      x$op_original <- x$op
      x$rhs_original <- x$rhs
      x$op <- "~~"
      x <- sort_cov_pairs(x)
      out <- sort_partable(
        x,
        sort_by
      )
      # par_label: A unique label
      #   for two terms in a group/block,
      #   ignoring the relation.
      out$par_label <- paste0(
        out$lhs,
        ".",
        out$rhs,
        ".",
        out$bloc,
        ".",
        out$group
      )
      out
    }
  )
  label_common <- lapply(
    lorbg,
    \(x) x$par_label
  )
  label_common <- unname(unique(unlist(label_common)))
  lorbg0 <- lapply(
    lorbg,
    \(x) {
      i <- which(colnames(x) %in% c("lhs", "rhs", "block", "group", "par_label"))
      x[, -i] <- NA
      x
    }
  )
  lorbg_common <- Reduce(
    function(x, y) {
      merge(x, y,
            all = TRUE)
    },
    lorbg0
  )
  lorbg1 <- lapply(
    lorbg,
    \(x) {
      par_no <- setdiff(
        label_common, x$par_label
      )
      if (length(par_no) == 0L) {
        return(x)
      }
      n_i <- length(par_no)
      i <- lorbg_common$par_label %in% par_no
      tmp <- lorbg_common[i, , drop = FALSE]
      x <- rbind(x, tmp)
      x[sort(x$par_label), , drop = FALSE]
    }
  )
  if (add_pt_name) {
    pt_names <- names(pt_list)
    for (i in seq_along(lorbg1)) {
      lorbg1[[i]]$model <- pt_names[i]
    }
  }
  lorbg1
}
