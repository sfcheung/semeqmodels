#' @title Compare Two Models
#'
#' @description Helper functions to
#' compare two models (parameter tables)
#' and find the differences.
#'
#' @name model_diff
NULL

#' @details
#' The functions [model_diff()] takes
#' two parameter tables and identify
#' the differences, if any.
#'
#' The columns compared is specified
#' by the argument `cols`.
#'
#' For the `free` column, the actual values are
#' ignored. Two parameters are considered
#' identical if they are both free
#' (have non-zero values on `free`).
#'
#' For `ustart` and `start` columns,
#' the values are used only if a parameter
#' is fixed. If a parameter is free,
#' they will be recoded to `NA` when
#' being compared.
#'
#' @return
#' The function [model_diff()]
#' returns a list with two elements,
#' `model_x_only` and `model_y_only`.
#' Each element is a parameter table
#' with parameters that are present only
#' in one of the model.
#'
#' @param model_x,model_y Parameter
#' tables (from `lavaan`) to be compared.
#' They can also be `lavaan` objects,
#' the output of functions such as
#' [lavaan::sem()].
#'
#' @param cols The columns to be compared.
#' Two parameters are considered to
#' be identical if they are identical
#' on these columns (but see Details
#' on how `free`, `ustart`, and `start`
#' are compared).
#'
#' @param digits The number of decimal
#' places used to round `ustart` and
#' `start` when doing the comparison.
#'
#' @param model_x_name,model_y_name The
#' names of the models used in the output.
#' If `NULL`, the name will be generated
#' automatically.
#'
#' @examples
#'
#' library(lavaan)
#'
#'
#' mod1 <-
#' "
#' m ~ x
#' y ~ m + x
#' "
#'
#' mod2 <-
#' "
#' m ~ x
#' y ~ m
#' "
#'
#' mod3 <-
#' "
#' y ~ m + x
#' "
#'
#' pt1 <- parameterTable(sem(mod1, do.fit = FALSE))
#' pt2 <- parameterTable(sem(mod2, do.fit = FALSE))
#' pt3 <- parameterTable(sem(mod3, do.fit = FALSE))
#'
#' model_diff(pt1, pt2)
#' model_diff(pt1, pt3)
#' model_diff(pt2, pt3)
#'
#' @rdname model_diff
#' @export
model_diff <- function(
  model_x,
  model_y,
  cols = getOption("semeqmodels.digest_cols", default = c("lhs", "op", "rhs", "block", "group", "free", "ustart", "start")),
  digits = 6,
  model_x_name = NULL,
  model_y_name = NULL
) {
  if (is.null(model_x_name)) {
    model_x_name <- deparse(substitute(model_x))
  }
  if (is.null(model_y_name)) {
    model_y_name <- deparse(substitute(model_y))
  }
  if (inherits(model_x, "lavaan")) {
    model_x <- lavaan::parameterTable(model_x)
  }
  if (inherits(model_y, "lavaan")) {
    model_y <- lavaan::parameterTable(model_y)
  }
  if (!is_partable(model_x)) {
    stop("model_x does not appear to be a parameter table")
  }
  if (!is_partable(model_y)) {
    stop("model_y does not appear to be a parameter table")
  }
  x0 <- sort_cov_pairs(model_x)
  y0 <- sort_cov_pairs(model_y)
  algo <- getOption("semeqmodels.algo") %||% "xxhash32"
  x0$digest0 <- apply(
                x0,
                MARGIN = 1,
                digest::digest,
                algo = algo
              )
  y0$digest0 <- apply(
                y0,
                MARGIN = 1,
                digest::digest,
                algo = algo
              )
  x0 <- fix_pt(x0, digits = digits)
  y0 <- fix_pt(y0, digits = digits)
  xnames <- colnames(x0)
  ynames <- colnames(y0)
  x1 <- x0[, intersect(xnames, union(cols, "digest0"))]
  y1 <- y0[, intersect(ynames, union(cols, "digest0"))]
  x1d <- which(colnames(x1) == "digest0")
  y1d <- which(colnames(y1) == "digest0")
  x1$digest <- apply(
                x1[, -x1d],
                MARGIN = 1,
                digest::digest,
                algo = algo
              )
  y1$digest <- apply(
                y1[, -y1d],
                MARGIN = 1,
                digest::digest,
                algo = algo
              )
  x1_only <- setdiff(x1$digest, y1$digest)
  y1_only <- setdiff(y1$digest, x1$digest)
  x1_only_d0 <- x1[x1$digest %in% x1_only, "digest0"]
  y1_only_d0 <- y1[y1$digest %in% y1_only, "digest0"]
  x2 <- x0[x0$digest0 %in% x1_only_d0, ]
  y2 <- y0[y0$digest0 %in% y1_only_d0, ]
  x3 <- fix_pt_reverse(x2)
  y3 <- fix_pt_reverse(y2)
  attr(x3, "model_name") <- model_x_name
  attr(y3, "model_name") <- model_y_name
  out <- list(
    model_x_only = x3,
    model_y_only = y3
  )
  names(out) <- c(model_x_name, model_y_name)
  class(out) <- c("model_diff", class(out))
  out
}

#' @details
#' The function [model_diff_many()]
#' compare one model (`target_model`)
#' against other models (`other_models`)
#' using [model_diff()].
#'
#' @return
#' The function [model_diff_many()]
#' return a list of the results
#' of [model_diff()].
#'
#' @param target_model A model
#' (`lavaan` parameter table or
#' `lavaan` output) to which other
#' models will be compared.
#'
#' @param other_models A list of models
#' (`lavaan` parameter tables o
#' `lavaan` outputs) to be compared to
#' the `target_model` by [model_diff()].
#'
#' @param ... For [model_diff_many()],
#' these are arguments to be passed to
#' [model_diff()]. For the `print`-methods,
#' these arguments are ignored.
#'
#' @param target_model_name,other_models_names
#' Names of the models, to be passed to
#' [model_diff()]. If `NULL`, they will
#' be generated automatically.
#'
#' @rdname model_diff
#' @export
model_diff_many <- function(
  target_model,
  other_models,
  ...,
  target_model_name = NULL,
  other_models_names = NULL
) {
  # out0 <- lapply(
  #   other_models,
  #   model_diff,
  #   model_x = target_model,
  #   ...
  # )
  if (is.null(target_model_name)) {
    target_model_name <- deparse(substitute(target_model))
  }
  if (is.null(other_models_names)) {
    other_models_names <- names(other_models)
    if (is.null(other_models_names)) {
      other_models_names <- paste0(
        "Model_y_",
        seq_along(other_models)
      )
    }
  }
  ddd <- list(...)
  out0 <- mapply(
    model_diff,
    model_y = other_models,
    model_y_name = other_models_names,
    MoreArgs = c(
        list(model_x = target_model,
            model_x_name = target_model_name),
        ddd
      ),
    SIMPLIFY = FALSE,
    USE.NAMES = FALSE
  )
  names(out0) <- other_models_names
  class(out0) <- c("model_diff_many", class(out0))
  out0
}

#' @details
#' The `print` method of the output
#' of [model_diff()] prints the differences
#' between models in a user-friendly
#' way.
#'
#' @return
#' The `print`-method of the output
#' of [model_diff()] returns `x`
#' invisibly.
#' It is called for its side-effect.
#'
#' @param x The object to be printed.
#'
#' @param format The format of the output
#' when printing model differences.
#' Either a user-friendly summary
#' (`"summary"`) or the original parameter
#' table (`"data.frame"`).
#'
#' @rdname model_diff
#' @export
model_diff.print <- function(
  x,
  format = c("summary", "data.frame"),
  ...
) {
  format <- match.arg(format)
  # TODO:
  # - Retrieve model names
  model_names <- names(x)
  if (is.null(model_names)) {
    model_names <- paste0("[[", seq_along(model_names), "]]")
  }
  out0 <- lapply(
    x,
    partable_to_syntax
  )
  for (a in seq_along(x)) {
    cat("\nModel: ",
        model_names[a],
        "\n",
        sep = "")
    if (format == "data.frame") {
      print(x[[a]])
    }
    if (format == "summary") {
      if (length(out0[[a]]) == 0) {
        cat("No parameter only in this model.\n")
      } else {
        cat(out0[[a]],
            sep = "\n"
            )
      }
    }
  }
  invisible((x))
}


#' @details
#' The `print` method of the output
#' of [model_diff()] prints the differences
#' between models in a user-friendly
#' way.
#'
#' @return
#' The `print`-method of the output
#' of [model_diff()] returns `x`
#' invisibly.
#' It is called for its side-effect.
#'
#' @param x The object to be printed.
#'
#' @param format The format of the output
#' when printing model differences.
#' Either a user-friendly summary
#' (`"summary"`) or the original parameter
#' table (`"data.frame"`).
#'
#' @rdname model_diff
#' @export
print.model_diff <- function(
  x,
  format = c("summary", "data.frame"),
  ...
) {
  format <- match.arg(format)
  # TODO:
  # - Retrieve model names
  model_names <- names(x)
  if (is.null(model_names)) {
    model_names <- paste0("[[", seq_along(model_names), "]]")
  }
  out0 <- lapply(
    x,
    partable_to_syntax
  )
  for (a in seq_along(x)) {
    cat("\nModel: ",
        model_names[a],
        "\n",
        sep = "")
    if (format == "data.frame") {
      print(x[[a]])
    }
    if (format == "summary") {
      if (length(out0[[a]]) == 0) {
        cat("No parameter only in this model.\n")
      } else {
        cat(out0[[a]],
            sep = "\n"
            )
      }
    }
  }
  invisible((x))
}


#' @details
#' The `print` method of the output
#' of [model_diff_many()] prints the
#' list of model differences in a
#' user-friendly
#' way.
#'
#' @return
#' The `print`-method of the output
#' of [model_diff_many()] returns `x`
#' invisibly.
#' It is called for its side-effect.
#'
#' @rdname model_diff
#' @export
print.model_diff_many <- function(
  x,
  format = "summary",
  ...
) {
  target_name <- names(x[[1]])[1]
  other_names <- names(x)
  for (a in seq_along(x)) {
    cat("\n-------------\n\n")
    cat("Models: ",
        target_name,
        " vs. ",
        other_names[a],
        "\n",
        sep = "")
    print(
      x[[a]],
      format = format,
      ...
    )
  }
  invisible(x)
}

#' @noRd
fix_pt <- function(
  object,
  digits = 6
) {
  object$free_org <- object$free
  object$start_org <- object$start
  object$ustart_org <- object$ustart
  object$free <- ifelse(object$free > 0, 1, 0)
  i_free <- which(object$free > 0)
  object$start <- round(object$start, digits = digits)
  object$ustart <- round(object$ustart, digits = digits)
  object$start[i_free] <- NA_real_
  object$ustart[i_free] <- NA_real_
  object
}

#' @noRd
fix_pt_reverse <- function(
  object,
  remove = c("digest0")
) {
  object$free <- object$free_org
  object$start <- object$start_org
  object$ustart <- object$ustart_org
  object$free_org <- NULL
  object$start_org <- NULL
  object$ustart_org <- NULL
  object[, remove] <- NULL
  object
}

#' @noRd
partable_to_syntax <- function(
  partable
) {
  # Convert a partable to lhs-op-rhs syntax strings
  if (nrow(partable) == 0) {
    return(character(0))
  }
  out0 <- lavaan::lav_partable_labels(partable)
  # TODO:
  # - Handle other rows such as user-defined parameters
  #   and equality constrains
  partable$label <- ""
  fixed <- partable$free == 0
  free <- partable$free > 0
  suffix <- character(length(out0))
  if (any(fixed)) {
    suffix[fixed] <- paste0("fixed to ", partable$start[fixed])
  }
  if (any(free)) {
    suffix[free] <- paste0("free")
  }
  out1 <- paste0(out0, " (", suffix, ")")
  out1
}