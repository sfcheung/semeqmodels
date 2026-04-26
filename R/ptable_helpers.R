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
#' to one single `partables` object.
#'
#' @return
#' The function [combine_ptables()]
#' returns a list of the class `partables`.
#'
#' @param object_list A list of objects
#' of the class
#' `partables`.
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
  out0 <- unlist(
    object_list,
    recursive = FALSE
  )
  if (drop_duplicated) {
    out0_digest <- lapply(
      out0,
      add_digest
    )
    i <- sapply(
            out0_digest,
            get_digest
          )
    out0 <- out0[!duplicated(i)]
  }
  tmp <- class(out0)
  tmp <- tmp[tmp != "partables"]
  tmp <- c("partables", tmp)
  class(out0) <- tmp
  out0
}


#' @noRd
sort_ptable <- function(
  ptable,
  cols = c("lhs", "op", "rhs", "block", "group", "free", "ustart")
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
