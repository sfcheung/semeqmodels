#' @title Parameter Table Helpers
#'
#' @description Helper functions to
#' manipulate parameter tables.
#'
#' @name partable_helpers
NULL

#' @details
#' The function [combine_partables()]
#' combine a list of `partables` objects
#' or `eq_partables` objects
#' to one single object of the same type.
#'
#' @return
#' The function [combine_partables()]
#' always returns an object of the class
#' `eq_partables`.
#'
#' @param object_list A list of objects
#' of the class
#' `partables` or `eq_partables`.
#'
#' @param drop_duplicated Logical. Whether
#' duplicated models will be removed.
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
#' partables1 <- combine_partables(fit1_1_more_1_less)
#' partables1
#'
#' @rdname partable_helpers
#' @export
combine_partables <- function(
  object_list,
  drop_duplicated = TRUE
) {
  # TODO:
  # - Update it to work with other type
  #   of list of parameter tables.
  # Combine a list of partables objects
  # out0 <- unlist(
  #   object_list,
  #   recursive = FALSE
  # )
  out0 <- do.call(
      to_eq_partables_list,
      object_list
    )
  if (drop_duplicated) {
    # out0_digest <- lapply(
    #   out0,
    #   add_digest
    # )
    # i <- sapply(
    #         out0_digest,
    #         get_digest
    #       )
    # out0 <- out0[!duplicated(i)]
    out0 <- unique(out0)
  }
  tmp <- class(out0)
  tmp <- tmp[!(tmp %in% c("eq_partables", "partables"))]
  tmp <- c("eq_partables", "partables", tmp)
  class(out0) <- tmp
  out0
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
#' make them more readable.`
#'
#' @return
#' The `print`-method of `eq_partables`
#' return `x` invisibly. It is called
#' for its side-effet.
#'
#' @rdname partable_helpers
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
#' object combine `eq_partables` elements
#' to one single `eq_partables` elements.
#'
#' @return
#' The `c`-method of `eq_partables`
#' returns a list of the class
#' `eq_partables`.
#'
#' @param ... For the `c`-method of
#' `eq_partables`
#' object, these are `eq_partables`
#' objects to be combined. For the
#' `print`-method of `eq_partables`
#' objects, these arguments are not
#' used. For [eq_partables()], it
#' should be `lavaan` outputs or
#' `lavaan` parameter tables.
#'
#' @rdname partable_helpers
#' @export
c.eq_partables <- function(
  ...,
  drop_duplicated = TRUE
) {
  out0 <- to_eq_partables_list(...)
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
#' @rdname partable_helpers
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
#' @rdname partable_helpers
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


#' @noRd
to_eq_partables_list <- function(
  ...
) {
  # Input
  # - A list of eq_partables or partables,
  #   may be a list of lists.
  # Output
  # - Ensure that the output is of the class `eq_partables`
  out0 <- list(...)
  out1 <- unlist_eq_partables(out0)
  tmp <- class(out1)
  tmp <- tmp[!(tmp %in% c("eq_partables", "partables"))]
  class(out1) <- c("eq_partables", "partables", class(out1))
  out1
}

#' @noRd
unlist_eq_partables <- function(x) {
  # Input
  # - A list, which may have lists of lists.
  # Output
  # - A list of parameter tables
  out <- list()
  for (i in seq_along(x)) {
    if ((inherits(x[[i]], "eq_partables")) ||
        (inherits(x[[i]], "partables"))) {
      out <- append(
                out,
                unlist(x[i], recursive = FALSE)
              )
    } else if (is.list(x[[i]])) {
      out <- do.call(
                append,
                list(x = out,
                     values = unlist_eq_partables(x[[i]])),
              )
    }
  }
  out
}

#' @param y An `eq_partables` object.
#'
#' @details
#' The function [setdiff_eq_partables()]
#' removes from `x` models that are
#' also in `y`.
#'
#' @return
#' The function [setdiff_eq_partables()]
#' returns a list of parameter tables,
#' of the same class of `x`, with models
#' present in `y` removed.
#'
#' @rdname partable_helpers
#' @export
setdiff_eq_partables <- function(
  x,
  y
) {
  x_digest <- sapply(
    x,
    get_digest
  )
  y_digest <- sapply(
    y,
    get_digest
  )
  i <- !(x_digest %in% y_digest)
  if (any(i)) {
    out <- x[i]
  } else {
    out <- list()
  }
  class(out) <- class(x)
  out
}

#' @details
#' The function [union_eq_partables()]
#' combines the models in `x` and `y`,
#' with duplicated models removed.
#'
#' @return
#' The function [union_eq_partables()]
#' returns a list of parameter tables,
#' of the class `eq_partables`.
#'
#' @rdname partable_helpers
#' @export
union_eq_partables <- function(
  x,
  y
) {
  # TODO:
  # - Need to add some sanity checks.
  # - Add some tests.
  out0 <- c(x, y)
  class(out0) <- c("eq_partables", "partables", "list")
  out0 <- unique(out0)
  out0
}

#' @details
#' The function [intersect_eq_partables()]
#' find the models common in `x` and `y`.
#'
#' @return
#' The function [intersect_eq_partables()]
#' returns a list of parameter tables,
#' of the class `eq_partables`, common
#' in both `x` and `y`.
#'
#' @rdname partable_helpers
#' @export
intersect_eq_partables <- function(
  x,
  y
) {
  # TODO:
  # - Need to add some sanity checks.
  # - Add some tests.
  x_digest <- get_digest_partables(x)
  y_digest <- get_digest_partables(y)
  digest0 <- intersect(x_digest, y_digest)
  if (length(digest0) > 0) {
    out0 <- union_eq_partables(x, y)
    tmp <- get_digest_partables(out0) %in%
           digest0
    out0 <- out0[tmp]
  } else {
    out0 <- list()
  }
  class(out0) <- c("eq_partables", "partables", "list")
  out0
}


#' @details
#' The function [setequal_eq_partables()]
#' check whether `x` and `y` has the
#' same set of models. Orders are ignored.
#'
#' @return
#' The function [setequal_eq_partables()]
#' returns `TRUE` or `FALSE`, based on
#' the results of [get_digest_partables()]
#' applied to `x` and `y`.
#'
#' @rdname partable_helpers
#' @export
setequal_eq_partables <- function(
  x,
  y
) {
  # TODO:
  # - Need to add some sanity checks.
  # - Add some tests.
  x_digest <- get_digest_partables(x)
  y_digest <- get_digest_partables(y)
  setequal(x_digest, y_digest)
}


#' @details
#' The function [is_element_eq_partables()]
#' checks whether `el` is one of the
#' models in `set`.
#'
#' @return
#' The function [is_element_eq_partables()]
#' returns `TRUE` or `FALSE`, based on
#' the results of [is.element()] applied
#' to the hash values from [get_digest()]
#' and [get_digest_partables()].
#'
#' @param el A parameter table.
#'
#' @param set A list of parameter tables.
#'
#' @rdname partable_helpers
#' @export
is_element_eq_partables <- function(
  el,
  set
) {
  # TODO:
  # - Need to add some sanity checks.
  # - Add some tests.
  if (!is_partable(el)) {
    stop("'el' does not appear to be a parameter table.")
  }
  set_digest <- get_digest_partables(set)
  el_digest <- get_digest(el)
  is.element(el_digest, set_digest)
}

#' @details
#' The function [match_eq_partables()]
#' is similar to [match()], but check
#' matches based on the results of
#' [get_digest()] applied to the
#' parameter tables.
#'
#' @return
#' The function [match_eq_partables()]
#' returns the results of [match()] applied
#' to the hash values generated by
#' [get_digest()].
#'
#' @param table A list of parameter tables.
#'
#' @param nomatch The same argument from
#' [match()].
#'
#' @rdname partable_helpers
#' @export
match_eq_partables <- function(
  x,
  table,
  nomatch = NA_integer_
) {
  # TODO:
  # - Need to add some sanity checks.
  # - Add some tests.
  table_digest <- get_digest_partables(table)
  x_digest <- get_digest_partables(x)
  match(x = x_digest,
        table = table_digest,
        nomatch = nomatch)
}

#' @details
#' `%pt_in%` is similar to `%in%`,
#' but works on parameter tables using
#' [match_eq_partables()].
#'
#' @return
#' `%pt_in%` returns a logical vector,
#' the output of `%in%` applied to
#' the has values of `x` and `table.`
#'
#' @rdname partable_helpers
#' @export
`%pt_in%` <- function(
  x,
  table
) {
  match_eq_partables(
    x,
    table,
    nomatch = 0L) > 0L
}

#' @details
#' `%pt_notin%` is similar to `%notin%`,
#' but works on parameter tables using
#' [match_eq_partables()].
#'
#' @return
#' `%pt_notin%` returns a logical vector,
#' the output of `%notin%` applied to
#' the has values of `x` and `table.`
#'
#' @rdname partable_helpers
#' @export
`%pt_notin%` <- function(
  x,
  table
) {
  match_eq_partables(
    x,
    table,
    nomatch = 0L) == 0L
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
#' created from the one or more
#' `lavaan` outputs or `lavaan`
#' parameter tables.
#'
#' @rdname partable_helpers
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
#' @rdname partable_helpers
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
#' The function [is_partable()] check
#' whether an object is probably a
#' parameter table. It checks whether
#' (a) the object is a `data.frame`-like
#' object (by [is.data.frame()]) and (b)
#' the columns in `colchk` exist. If
#' both conditions are met, then the
#' object is considered a parameter
#' table.
#'
#' @param object The object to be
#' checked whether it is a parameter
#' table.
#'
#' @param colchk The columns to be
#' checked.
#'
#' @return
#' The function [is_partable()] return
#' either `TRUE` or `FALSE`. It is
#' `TRUE` is the two conditions mentioned
#' in Details are met.
#'
#' @rdname partable_helpers
#' @export
is_partable <- function(
  object,
  colchk = c("id", "lhs", "op", "rhs")
) {
  # Check if a data frame is "likely" a
  # lavaan parameter table
  # Use only column names
  # Not a 100% correct check but good enough
  if (!is.data.frame(object)) {
    return(FALSE)
  }
  col0 <- colnames(object)
  if (all(colchk %in% col0)) {
    return(TRUE)
  }
  return(FALSE)
}

#' @details
#' The function [is_partables()] check
#' whether a list is likely a list of parameter
#' tables. It simply call [is_partable()]
#' on all the elements.
#'
#' @return
#' The function [is_partables()] return
#' either `TRUE` or `FALSE`. It is
#' `TRUE` only if [is_partable()] returns
#' `TRUE` for all its elements.
#'
#' @rdname partable_helpers
#' @export
is_partables <- function(
  object,
  colchk = c("id", "lhs", "op", "rhs")
) {
  if (!is.list(object)) {
    return(FALSE)
  }
  chk <- sapply(
    object,
    is_partable,
    colchk = colchk
  )
  all(chk)
}