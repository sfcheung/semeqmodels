#' @title Parameter Table Helpers
#'
#' @description Helper functions to
#' manipulate parameter tables.
#'
#' @name ptable_helpers
NULL

#' @details
#' The function [combine_ptables()]
#' combine a list of `partables` objects
#' or `eq_partables` objects
#' to one single object of the same type.
#'
#' @return
#' The function [combine_ptables()]
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
#' ptables1 <- combine_ptables(fit1_1_more_1_less)
#' ptables1
#'
#' @rdname ptable_helpers
#' @export
combine_ptables <- function(
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
#' objects to be combined.
#'
#' @rdname ptable_helpers
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
#' @rdname ptable_helpers
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
#' @rdname ptable_helpers
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
  out0 <- list(...)
  out1 <- unlist_eq_partables(out0)
  tmp <- class(out1)
  tmp <- tmp[!(tmp %in% c("eq_partables", "partables"))]
  class(out1) <- c("eq_partables", "partables", class(out1))
  out1
}

#' @noRd
unlist_eq_partables <- function(x) {
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

#' @noRd
sort_ptable <- function(
  ptable,
  cols = c("lhs", "op", "rhs", "block", "group")
) {
  # Sort a parameter table
  # For comparing different tables

  # TODO:
  # - Handle labels and constraint
  # Sort rows in a parameter table.
  i <- do.call(
            order,
            ptable[, cols]
          )
  out0 <- ptable[i, ]
  out0
}

#' @noRd
digest_ptable <- function(
  ptable,
  cols = c("lhs", "op", "rhs", "block", "group", "free", "ustart", "start"),
  digits = 6,
  ...
) {

  # Compute a value using a hash function.
  # For comparing tables

  # TODO:
  # - Handle labels and constraint
  out0 <- ptable[, cols]
  out0 <- as.data.frame(out0)
  row.names(out0) <- NULL
  i_free <- which(out0$free > 0)
  out0$free[i_free] <- seq_along(i_free)
  out0$start <- round(out0$start, digits = digits)
  out0$ustart <- round(out0$ustart, digits = digits)
  out0$start[i_free] <- NA
  out0$ustart[i_free] <- NA
  do.call(
      digest::digest,
      list(object = out0,
          ...
      )
    )
}

#' @noRd
add_digest <- function(
  ptable,
  args_sort_ptable = list(),
  args_digest_ptable = list()
) {

  # Add a digest to a parameter table
  # Return the parameter table with
  # the value added as the attribute "digest"

  out0 <- do.call(
            sort_ptable,
            c(list(ptable = ptable),
              args_sort_ptable)
          )
  out1 <- do.call(
            digest_ptable,
            c(list(ptable = out0),
              args_digest_ptable)
          )
  attr(ptable, "digest") <- out1
  ptable
}

#' @noRd
get_digest <- function(
  ptable,
  args_sort_ptable = list(),
  args_digest_ptable = list()
) {

  # Retrieve the digest value, if available.
  # If not available, compute it.

  out <- attr(ptable, "digest")
  if (is.null(out)) {
    out0 <- do.call(
            add_digest,
            list(ptable = ptable,
                 args_sort_ptable = args_sort_ptable,
                 args_digest_ptable = args_digest_ptable)
          )
    out <- attr(out0, "digest")
  }
  out
}

#' @noRd
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
  }
  class(out) <- class(x)
  out
}