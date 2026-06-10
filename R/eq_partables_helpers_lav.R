#' @title Helpers for 'eq_partables' Object
#'
#' @description Helpers to work
#' with an
#' `eq_partables` object.
#'
#' @name eq_partables_helpers
NULL

#' @details
#'
#' Although the functions are designed
#' to work with the output of [eq_models()],
#' they also work for a list of models
#' (parameter tables), except for the
#' methods specifically for an `eq_partables`
#' object.
#'
#' The function [eq_lavInspect()]
#' calls [lavaan::lavInspect()] on the
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
#' @param ... For [eq_lavInspect()] and
#' [eq_fitMeasures()], these are optional
#' arguments to be
#' passed to the `lavaan` functions
#' to be called.
#' For the
#' `print`-method of `eq_partables`
#' objects, these arguments are not
#' used.
#' For the `c`-method of
#' `eq_partables`
#' objects, these are `eq_partables`
#' objects to be combined.
#' For [eq_partables()], it
#' should be `lavaan` outputs or
#' `lavaan` parameter tables.
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
#' fm ~ fx
#' fy ~ fm
#' "
#' fit1 <- sem(
#'           model = mod1,
#'           data = data_test_3obvs,
#'           fixed.x = FALSE
#'         )
#'
#' # Remove 'parallel = FALSE' or set parallel to TRUE
#' # for faster generation.
#' out <- eq_models(
#'   original_model = fit1,
#'   parallel = FALSE
#' )
#' out
#'
#' eq_lavInspect(out, "implied")
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
#' @examples
#'
#' eq_fitMeasures(out, c("cfi", "tli"))
#'
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
#' @examples
#'
#' eq_df(out)
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
#' @examples
#'
#' eq_fits(out)
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
#' @return
#' The `[`, `[<-`, and `[[<-` methods return
#' an `eq_partables` object.
#'
#' @param x An 'eq_partables'-class object.
#' @param i A numeric vector of model position(s),
#'          a character vector of model name(s),
#'          or a logical vector of model(s) to be selected.
#'
#' @examples
#'
#' out1 <- out[2:3]
#'
#' out1
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

#' @details
#' The `print`-method of `eq_partables`
#' object handles a zero-length list.
#' If not of zero-length, the `print`-method
#' for `partables` will be used.
#'
#' @param max_models The maximum number
#' of models to print. If `NULL`, all
#' models will be printed.
#'
#' @param names_to_use If `"default"`,
#' the names in `x`, which may not be
#' descriptive, will be used. If `"long"`,
#' the names from [modelbpp::gen_models()]
#' will be used if available.
#' They can be very long,
#' but describes the changes leading to
#' a model.
#'
#' @param wrap_long_names If `TRUE`,
#' long names will be wrapped when
#' printed. Used only when `names_to_use`
#' is `"long"`.
#'
#' @param readable_long_names If `TRUE`,
#' the long names will be modified to
#' make them more readable.
#'
#' @return
#' The `print`-method of `eq_partables`
#' returns `x` invisibly. It is called
#' for its side-effect.
#'
#' @rdname eq_partables_helpers
#' @export
print.eq_partables <- function(
  x,
  max_models = NULL,
  names_to_use = c("default", "long"),
  wrap_long_names = TRUE,
  readable_long_names = TRUE,
  ...
) {
  names_to_use <- match.arg(names_to_use)
  if (length(x) == 0) {
    cat("The number of models is zero.\n")
    return(invisible(x))
  }
  x_n <- length(x)
  x_org_names <- names(x)
  x_gen_models_names <- mapply(
    function(x, y) {
      tmp <- attr(x, "gen_models_name")
      return(tmp %||% y)
    },
    x = x,
    y = x_org_names,
    SIMPLIFY = TRUE
  )
  x_gen_models_names <- unname(x_gen_models_names)
  if (readable_long_names) {
    x_gen_models_names <- gsub(
                            ".add: ",
                            ", add:",
                            x_gen_models_names,
                          fixed = TRUE)
    x_gen_models_names <- gsub(
                            ".drop: ",
                            ", drop:",
                            x_gen_models_names,
                          fixed = TRUE)
  }
  if (names_to_use == "long") {
    if (all(x_org_names != x_gen_models_names)) {
      x_names <- paste0(x_org_names,
                        " := ",
                        x_gen_models_names)
    } else {
      x_names <- x_gen_models_names
    }
  }
  if (names_to_use == "default") {
    x_names <- x_org_names
  }
  cat("\n")
  cat("Number of models: ", x_n, "\n", sep = "")
  cat("\n")
  if (isTRUE(x_n > max_models)) {
      x_tmp <- x_names[seq_len(max_models)]
      cat("The first", max_models, "model(s):\n")
    } else {
      x_tmp <- x_names
      cat("The models:\n")
    }
  # if (names_to_use == "long") {
  #   x_tmp <- strsplit(x_tmp, ".", fixed = TRUE)
  #   x_tmp <- sapply(
  #         x_tmp,
  #         \(x) paste(x, collapse = ",\n")
  #       )
  # }
  x_tmp2 <- data.frame(Model = x_tmp)
  x_tmp3 <- utils::capture.output(print(x_tmp2, right = FALSE))
  if ((names_to_use == "long") &&
      wrap_long_names) {
    x_tmp3 <- sapply(
      x_tmp3,
      strwrap,
      exdent = 4
    )
  }
  cat("\n")
  cat(paste(unlist(x_tmp3), collapse = "\n"), "\n")

  if (names_to_use == "default") {
    tmp <- strwrap(
      paste0("NOTE: 'default' names are used. ",
             "Call 'print()' and add 'names_to_use = \"long\"' ",
             "to use the long descriptive names, if available, ",
             "for the models.")
    )
    cat("\n")
    cat(tmp, sep = "\n")
  }

  invisible(x)
}


#' @details
#' The `c`-method of `eq_partables`
#' object combines `eq_partables` elements
#' to one single `eq_partables` elements.
#'
#' @return
#' The `c`-method of `eq_partables`
#' returns a list of the class
#' `eq_partables`.
#'
#' @param drop_duplicated Logical. Whether
#' duplicated models will be removed.
#'
#' @rdname eq_partables_helpers
#' @export
c.eq_partables <- function(
  ...,
  drop_duplicated = TRUE
) {
  out0 <- to_eq_partables_list(...)
  out0 <- add_digest_partables(out0)
  class0 <- class(out0)
  if (drop_duplicated) {
    i <- sapply(
            out0,
            get_digest
          )
    j <- duplicated(i)
    if (any(j)) {
      out0 <- out0[!j]
      class(out0) <- class0
    }
  }
  out0
}

#' @details
#' The function [eq_partables()]
#' creates an `eq_partables` object
#' from `lavaan` parameter tables
#' or `lavaan` outputs.
#'
#' @return
#' The function [eq_partables()]
#' returns an `eq_partables` object
#' created from one or more
#' `lavaan` outputs or `lavaan`
#' parameter tables.
#'
#' @rdname eq_partables_helpers
#' @export
eq_partables <- function(
  ...
) {
  out <- list(...)
  out_names <- as.list(substitute(list(...)))[-1]
  if (is.null(names(out))) {
    names(out) <- out_names
  }
  tmp <- sapply(names(out), nchar)
  if (any(tmp == 0L)) {
    i <- which(tmp == 0L)
    names(out)[i] <- out_names[i]
  }
  chk1 <- sapply(
            out,
            is_partable
          )
  chk2 <- sapply(
            out,
            \(x) inherits(x, "lavaan")
          )
  chk <- chk1 | chk2
  if (!all(chk)) {
    stop("Objects are not all parameter tables or lavaan outputs.")
  }
  if (any(chk2)) {
    for (x in which(chk2)) {
      x_pt <- as_eq_partables(out[[x]])
      out[[x]] <- x_pt[[1]]
    }
  }
  tmp <- class(out)
  tmp <- tmp[!(tmp %in% c("eq_partables", "partables"))]
  class(out) <- c("eq_partables", "partables", class(out))
  # TODO:
  # - Add names
  out
}

#' @details
#' The function [as_eq_partables()] is
#' not a usual `as` function. It works
#' only on a `lavaan` output or
#' `lavaan` parameter table. It converts
#' `sem_out` to a one-element
#' list of the class `eq_partables`,
#' with the parameter table as the
#' element and the `lavaan` output,
#' if `sem_out` is a `lavaan` output, in
#' the attribute `"fit"`. If `sem_out`
#' is not a `lavaan` object nor a
#' `lavaan` parameter table, a zero-length
#' `eq_partables` object will be returned.
#'
#' @param sem_out A `lavaan` object
#' or a `lavaan` parameter table.
#' Can be `NULL`.
#'
#' @param model_name The name of the
#' model in the output.
#'
#' @return
#' The function [as_eq_partables()]
#' returns a one-element
#' `eq_partables` object if `sem_out` is
#' a `lavaan` output or a `lavaan`
#' parameter table. It returns
#' a zero-length `eq_partables` object
#' otherwise.
#'
#' @rdname eq_partables_helpers
#' @export
as_eq_partables <- function(
  sem_out = NULL,
  model_name = "original"
) {
  # Convert *one* single lavaan object
  # to an eq_partables object
  # If sem_out is NULL,
  # create a zero-length eq_partables object.
  # For concatenation
  if (inherits(sem_out, "lavaan") ||
      is_partable(sem_out)) {
    if (inherits(sem_out, "lavaan")) {
      pt <- lavaan::parameterTable(sem_out)
      out <- list(pt)
      attr(out[[1]], "fit") <- sem_out
    } else {
      out <- list(sem_out)
    }
    names(out) <- model_name
  } else {
    out <- list()
  }
  class(out) <- c("eq_partables", "partables", "list")
  out
}

#' @details
#' The `duplicated`-method of `eq_partables`
#' checks whether any models are
#' identical. If yes, the duplicated
#' models, except for the first one,
#' will be denoted as duplicated.
#'
#' @return
#' The `duplicated`-method of `eq_partables`
#' returns a logical vector to indicate
#' which models, if any, are identical
#' to other models earlier in the list.
#'
#' @param x An `eq_partables` object.
#'
#' @param incomparables Not used.
#'
#' @rdname eq_partables_helpers
#' @export
duplicated.eq_partables <- function(
  x,
  incomparables = FALSE,
  ...
) {
  i <- sapply(
          x,
          get_digest
        )
  duplicated(i)
}

#' @details
#' The `unique`-method of `eq_partables`
#' returns an `eq_partables` object with
#' duplicated models, if any, removed.
#'
#' @return
#' The `unique`-method of `eq_partables`
#' returns  an `eq_partables` object.
#'
#' @rdname eq_partables_helpers
#' @export
unique.eq_partables <- function(
  x,
  incomparables = FALSE,
  ...
) {
  i <- duplicated(x)
  out <- x[!i]
  class(out) <- class(x)
  out
}

