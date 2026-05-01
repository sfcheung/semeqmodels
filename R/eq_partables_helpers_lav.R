#' @title Helpers for 'eq_partables' Object
#'
#' @description Helpers to extract information
#' from the elements of an
#' `eq_partables`` object.
#'
#' @name eq_partables_helpers
NULL

#' @details
#' The function [eq_lavInspect()]
#' call [lavaan::lavInspect()] on the
#' elements of an `eq_partables` object.
#'
#' @return
#' The function [eq_lavInspect()]
#' returns the output of
#' [lavaan::lavInspect()]. Whether it
#' is a vector, list, or other type of
#' objects depends on the argument
#' `simplify`, used by [sapply()].
#'
#' @param object An `eq_partables` object.
#'
#' @param ... Optional arguments to be
#' passed to the `lavaan` functions
#' to be called.
#'
#' @param simplify To be passed to
#' [sapply()]. Note that the default is
#' `FALSE`, different from [sapply()].
#'
#' @examples
#'
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
#' # Model 3
#'
#' mod3 <-
#' "
#' fx =~ x1 + x2 + x3
#' fm =~ m1 + m2 + m3
#' fy =~ y1 + y2 + y3
#' fm ~ fx
#' fy ~ fm
#' "
#' fit3 <- sem(
#'           model = mod3,
#'           data = data_test_3_factor_3_item
#'         )
#' fit3_1_more <- drop_k(fit3, fit_models = TRUE)
#' fit3_1_more_1_less <- lapply(
#'   fit3_1_more,
#'   add_k,
#'   fit_models = TRUE
#' )
#'
#' @rdname eq_partables_helpers
#' @export
eq_lavInspect <- function(
  object,
  ...,
  simplify = FALSE
) {
  if (length(object) == 0) {
    return(NULL)
  }
  fits <- eq_fits(
    object
  )
  f <- function(
    object,
    ...
  ) {
    if (is.null(object)) {
      out <- NULL
    } else {
      out <- do.call(
        lavaan::lavInspect,
        c(list(object),
          list(...))
      )
    }
    out
  }
  out <- sapply(
    fits,
    f,
    ...,
    simplify = simplify
  )
  out
}

#' @details
#' The function [eq_fitMeasures()]
#' call [lavaan::fitMeasures()] on the
#' elements of an `eq_partables` object.
#'
#' @param output_format The format of
#' the output of [eq_fitMeasures()].
#' If `output_format` is `"data.frame`, then
#' the output will be a data frame with
#' the number of columns equal to the
#' number of models, and rows equal to
#' the number of values returned by
#' [lavaan::fitMeasures()].
#' If `output_format` is `"list"`, then
#' the output will be a list of numeric
#' vectors.
#'
#' @return
#' The function [eq_fitMeasures()]
#' returns the output of
#' [lavaan::fitMeasures()]. The format
#' is determined by `output_format`.
#'
#' @rdname eq_partables_helpers
#' @export
eq_fitMeasures <- function(
  object,
  ...,
  output_format = c("data.frame", "list")
) {
  output_format <- match.arg(output_format)
  if (length(object) == 0) {
    return(NULL)
  }
  fits <- eq_fits(
    object
  )
  f <- function(
    object,
    ...
  ) {
    if (is.null(object)) {
      out <- NULL
    } else {
      out <- do.call(
        lavaan::fitMeasures,
        c(list(object),
          list(...))
      )
    }
    out
  }
  out <- sapply(
    fits,
    f,
    ...,
    simplify = FALSE
  )

  # ==== Handle models without lavaan output ====

  out_NULL <- sapply(
                out,
                is.null
              )
  if (all(out_NULL)) {
    return(NULL)
  } else if (any(out_NULL)) {
    out_len <- sapply(
      out,
      length
    )
    out_len <- max(out_len)
    out_names <- names(out[!out_NULL][[1]])
    tmp <- rep_len(NA_real_, out_len)
    names(tmp) <- out_names
    out[out_NULL] <- tmp
  }

  if (output_format == "data.frame") {
    out <- data.frame(
      out,
      check.names = FALSE
    )
  }

  out
}

#' @details
#' The function [eq_fits()] extracts
#' the `lavaan` outputs stored for each
#' model, if present.
#'
#' @return
#' The function [eq_fits()] returns a
#' list of `lavaan` outputs for the
#' models in `object`. If absent for
#' a model, the value returned is `NULL`.
#'
#' @rdname eq_partables_helpers
#' @export
eq_fits <- function(object) {
  if (length(object) == 0) {
    return(NULL)
  }
  out <- lapply(
    object,
    attr,
    which = "fit"
  )
  out
}