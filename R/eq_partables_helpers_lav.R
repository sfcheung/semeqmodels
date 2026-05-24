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
#' to be called. For the subsetting and
#' assignment methods, they are arguments
#' to be passed to those methods.
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
#' The function [eq_df()] is a wrapper
#' that call [eq_fitMeasures()] with
#' `fit.measures` set to `"df"`. It
#' always return a numeric vector.
#'
#' @rdname eq_partables_helpers
#' @export
eq_df <- function(
  object
) {
  out0 <- eq_fitMeasures(
    object = object,
    fit.measures = "df",
    output_format = "list"
  )
  out1 <- sapply(
            out0,
            unname,
            simplify = FALSE,
            USE.NAMES = TRUE
          )
  out <- unlist(out1)
  out
}

#' @details
#' The function [eq_chisq()] is a wrapper
#' that call [eq_fitMeasures()] with
#' `fit.measures` set to `"chisq"`. It
#' always return a numeric vector.
#'
#' @rdname eq_partables_helpers
#' @export
eq_chisq <- function(
  object
) {
  out0 <- eq_fitMeasures(
    object = object,
    fit.measures = "chisq",
    output_format = "list"
  )
  # TODO:
  # - Default to `"chisq.robust"` if available.
  out1 <- sapply(
            out0,
            unname,
            simplify = FALSE,
            USE.NAMES = TRUE
          )
  out <- unlist(out1)
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

#' @details
#'
#' The class `eq_partables` has
#' `[`, `[<-`, and `[[<-` methods for extracting
#' and changing elements.
#'
#' @param x The `eq_partables` object to be used in
#' subsetting or assignment.
#'
#' @return
#' The `[`, `[<-`, and `[[<-` methods return
#' an `eq_partables` object.
#'
#' @param x A 'eq_partables'-class object.
#' @param i A numeric vector of model position(s),
#'          a character vector of model name(s),
#'          or a logical vector of model(s) to be selected.
#'
#' @rdname eq_partables_helpers
#' @export
`[.eq_partables` <- function(
  x,
  i
) {
  # This method just ensures that
  # the output is also an eq_partables
  # object.
  out <- NextMethod("[")

  # Keep the attributes
  for (xx in setdiff(names(attributes(x)), c("names", "class"))) {
    attr(out, xx) <- attr(x, xx)
  }

  class(out) <- class(x)
  out
}

#' @details
#' Though available, it is not advised
#' to assign models to an `eq_partables`
#' object because there is no guarantee
#' that the names still reflect how the
#' models are created.
#'
#' @param value The value(s) to be
#' assigned to the `eq_partables` object.
#'
#' @rdname eq_partables_helpers
#' @export
`[<-.eq_partables` <- function(
  x,
  i,
  value
) {
  # This method just ensures that
  # the output is also an eq_partables
  # object.
  out <- NextMethod("[<-")
  # No need for the naming. This behavior
  # is not unique for eq_parables.
  # warning("It is not advised to assign models to an eq_partables object.")

  # Keep the attributes
  for (xx in setdiff(names(attributes(x)), c("names", "class"))) {
    attr(out, xx) <- attr(x, xx)
  }

  class(out) <- class(x)
  out
}

#' @rdname eq_partables_helpers
#' @export
`[[<-.eq_partables` <- function(
  # This method just ensures that
  # the output is also an eq_partables
  # object.
  x,
  i,
  value
) {
  out <- NextMethod("[[<-")
  # No need for the naming. This behavior
  # is not unique for eq_parables.
  # warning("It is not advised to assign models to an eq_partables object.")

  # Keep the attributes
  for (xx in setdiff(names(attributes(x)), c("names", "class"))) {
    attr(out, xx) <- attr(x, xx)
  }

  class(out) <- class(x)
  out
}

#' @noRd
eq_same_data <- function(object) {
  fits <- eq_fits(object)
  chk <- sapply(
        fits,
        inherits,
        what = "lavaan"
      )
  if (!all(chk)) {
    stop("Not all the stored fits are lavaan objects")
  }
  dats <- sapply(
    fits,
    lavaan::lavInspect,
    "sampstats",
    simplify = FALSE
  )
  dats_e <- names(dats[[1]])
  for (xx in dats_e) {
    chk_1 <- dats[[1]][[xx]]
    dim <- dim(chk_1)
    if (is.null(dim)) {
      vnames <- names(chk_1)
    } else {
      vnames <- colnames(chk_1)
    }
    for (i in seq_along(dats)) {
      dats_i <- dats[[i]][[xx]]
      if (is.null(dim)) {
        dats_i <- dats_i[vnames]
      } else {
        dats_i <- dats_i[vnames, vnames]
      }
      chk_i <- isTRUE(all.equal(
                chk_1,
                dats_i,
                check.class = FALSE,
                check.attributes = FALSE
              ))
      if (!chk_i) {
        return(FALSE)
      }
    }
  }
  return(TRUE)
}