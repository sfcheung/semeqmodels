#' @title Helpers to Compare Parameter Tables
#'
#' @description Helper functions that
#' compute and use hash digests for
#' parameter tables to facilitate
#' comparisons.
#'
#' @details
#' The function [digest_ptable()] uses
#' [digest::digest()] to compute a
#' hash value for a parameter, after
#' sorting some essential columns
#' (see the `cols` argument)
#' If two `lavaan` parameter tables
#' are identical on the values for these
#' columns, they should have the same
#' hash value will be considered as
#' identical.
#'
#' Note that there may be cases in which
#' two models cannot be correctly
#' identified using this approach.
#' Nevertheless, they should be sufficient
#' for typical models used in this package.
#'
#' @return
#' The function [digest_ptable()] returns
#' a character string, the output of
#' [digest::digest()].
#'
#' @param ptable A `lavaan` parameter
#' table. If it is a `lavaan` output,
#' the parameter table will be retrieved
#' by [lavaan::parameterTable()].
#'
#' @param cols The columns to be used
#' to compute the hash value. Note that
#' `start` and `ustart` will be rounded
#' based on `digits`, `free` will be
#' converted to 0s and 1s (any values
#' greater than 0 will be converted to
#' 0), and `start` and `ustart` will
#' be set to `NA` for free parameters.
#'
#' @param digits The number of digits
#' when rounding `ustart` and `start`
#' by [round()].
#'
#' @param sort_rows Whether the
#' parameter tables will be sorted
#' by `cols` before computing the
#' hash value.
#'
#' @param sort_by The columns used when
#' sorting the rows, if `sort_rows` is
#' `TRUE`.
#'
#' @param ... For [digest_ptable()],
#' these are optional arguments to be
#' passed to [digest::digest()]. For
#' [add_digest()] and [get_digest()],
#' these are arguments to be passed to
#' [digest_ptable()].
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
#'           data = data_test_3_factor_3_item,
#'           do.fit = FALSE
#'         )
#'
#' mod2 <-
#' "
#' fy =~ y1 + y2 + y3
#' fx =~ x1 + x2 + x3
#' fm =~ m1 + m2 + m3
#' fy ~ fm + fx
#' fm ~ fx
#' "
#' fit2 <- sem(
#'           model = mod2,
#'           data = data_test_3_factor_3_item,
#'           do.fit = FALSE
#'         )
#'
#' pt1 <- parameterTable(fit1)
#' pt2 <- parameterTable(fit2)
#'
#' pt1
#' pt2
#'
#' digest_ptable(pt1)
#' digest_ptable(pt2)
#'
#' @export
digest_ptable <- function(
  ptable,
  cols = c("lhs", "op", "rhs", "block", "group", "free", "ustart", "start"),
  digits = 6,
  sort_rows = TRUE,
  sort_by = c("lhs", "op", "rhs", "block", "group"),
  ...
) {

  # Compute a value using a hash function.
  # For comparing tables

  # TODO:
  # - Handle labels and constraint

  if (inherits(ptable, "lavaan")) {
    ptable <- lavaan::parameterTable(ptable)
  }

  if (sort_rows) {
    ptable <- sort_ptable(
              ptable = ptable,
              cols = sort_by
            )
  }

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

#' @details
#' The function [add_digest()] computes
#' the hash value of a parameter table
#' and add it to the attribute `"digest"`
#' of the table,
#'
#' @return
#' The function [add_digest()] returns
#' the parameter table, with the
#' hash value stored in the attribute
#' `"digest"`.
#'
#' @rdname digest_ptable
#' @export
add_digest <- function(
  ptable,
  ...
) {

  # Add a digest to a parameter table
  # Return the parameter table with
  # the value added as the attribute "digest"

  # out0 <- do.call(
  #           sort_ptable,
  #           c(list(ptable = ptable),
  #             args_sort_ptable)
  #         )
  # out1 <- do.call(
  #           digest_ptable,
  #           c(list(ptable = out0),
  #             args_digest_ptable)
  #         )
  out1 <- digest_ptable(
            ptable = ptable,
            ...
          )
  attr(ptable, "digest") <- out1
  ptable
}

#' @details
#' The function [get_digest()] retrieves
#' the stored hash value from a
#' parameter table, if available. If
#' not available, it will call [digest_ptable()]
#' to compute the hash value.
#'
#' @return
#' The function [get_digest()] returns
#' the hash value of a parameter table.
#'
#' @rdname digest_ptable
#' @export
get_digest <- function(
  ptable,
  ...
) {

  # Retrieve the digest value, if available.
  # If not available, compute it.

  out <- attr(ptable, "digest")
  if (is.null(out)) {
    out <- digest_ptable(
              ptable = ptable,
              ...
            )
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
