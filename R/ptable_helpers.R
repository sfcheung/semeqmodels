#' @title Parameter Table Helpers
#'
#' @description Helper functions to
#' manipulate parameter tables. They are
#' exported for advanced users.
#'
#' @name partable_helpers
NULL

#' @details
#'
#' The function [combine_partables()]
#' combine a list of `partables` objects
#' or `eq_partables` objects
#' to one single object of the same type.
#'
#' @return
#' The function [combine_partables()]
#' always returns an object of the class
#' `eq_partables`, which is a subclass
#' of `partables`.
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
  tmp <- add_digest_partables(tmp)
  tmp <- tmp[!(tmp %in% c("eq_partables", "partables"))]
  tmp <- c("eq_partables", "partables", tmp)
  class(out0) <- tmp
  out0
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

#' @param x,y List of parameter tables,
#' such as `eq_partables` objects.
#'
#' @details
#' The function [setdiff_eq_partables()]
#' (and [setdiff_partables()])
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
#' @rdname partable_helpers
#' @export
setdiff_partables <- setdiff_eq_partables

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
  if (!is_partables(x) ||
      !is_partables(y)) {
    stop("Both x and y must be list of parameter tables")
  }
  if (!inherits(x, "eq_partables")) {
    x <- do.call(
              eq_partables,
              x
            )
  }
  if (!inherits(y, "eq_partables")) {
    y <- do.call(
              eq_partables,
              y
            )
  }
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
  if (!is_partables(x) ||
      !is_partables(y)) {
    stop("Both x and y must be list of parameter tables")
  }
  if (!inherits(x, "eq_partables")) {
    x <- do.call(
              eq_partables,
              x
            )
  }
  if (!inherits(y, "eq_partables")) {
    y <- do.call(
              eq_partables,
              y
            )
  }
  out0 <- c(x, y)
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
#' (and [setequal_partables()])
#' checks whether `x` and `y` has the
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
  if (!is_partables(x) ||
      !is_partables(y)) {
    stop("Both x and y must be lists of parameter tables")
  }
  x_digest <- get_digest_partables(x)
  y_digest <- get_digest_partables(y)
  setequal(x_digest, y_digest)
}
#' @rdname partable_helpers
#' @export
setequal_partables <- setequal_eq_partables

#' @details
#' The function [is_element_eq_partables()]
#' checks whether `el` is one of the
#' models in `set`.
#'
#' @return
#' The function [is_element_eq_partables()]
#' (and [is_element_partables()])
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
#' @rdname partable_helpers
#' @export
is_element_partables <- is_element_eq_partables

#' @details
#' The function [match_eq_partables()]
#' (and [match_partables()])
#' is similar to [match()], but check
#' matches based on the results of
#' [get_digest()] applied to the
#' parameter tables.
#'
#' @return
#' The function [match_eq_partables()]
#' (and [match_partables()])
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
#' @rdname partable_helpers
#' @export
match_partables <- match_eq_partables

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
#' The function [is_partable()] returns
#' either `TRUE` or `FALSE`. It is
#' `TRUE` if the two conditions mentioned
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
#' The function [is_partables()] checks
#' whether a list is likely a list of parameter
#' tables. It simply calls [is_partable()]
#' on all the elements.
#'
#' @return
#' The function [is_partables()] returns
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