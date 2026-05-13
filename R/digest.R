#' @title Helpers to Compare Parameter Tables
#'
#' @description Helper functions that
#' compute and use hash digests for
#' parameter tables to facilitate
#' comparisons.
#'
#' @details
#' The function [digest_partable()] uses
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
#' The function [digest_partable()] returns
#' a character string, the output of
#' [digest::digest()].
#'
#' @param partable A `lavaan` parameter
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
#' @param algo The algorithm used to
#' by [digest::digest()]. Note that the
#' default value is different from that
#' of [digest::digest()]
#'
#' @param ... For [digest_partable()],
#' these are optional arguments to be
#' passed to [digest::digest()]. For
#' [add_digest()], [get_digest()],
#' [add_digest_partables()], and
#' [get_digest_partables()],
#' these are arguments to be passed to
#' [digest_partable()].
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
#' digest_partable(pt1)
#' digest_partable(pt2)
#'
#' @export
digest_partable <- function(
  partable,
  cols = getOption("semeqmodels.digest_cols", default = c("lhs", "op", "rhs", "block", "group", "free", "ustart", "start")),
  digits = getOption("semeqmodels.digest_digits", default = 6),
  sort_rows = TRUE,
  sort_by = getOption("semeqmodels.digest_sort_by", default = c("lhs", "op", "rhs", "block", "group")),
  algo = getOption("semeqmodels.algo", default = "xxhash32"),
  ...
) {

  # Compute a value using a hash function.
  # For comparing tables

  # TODO:
  # - Handle labels and constraint

  if (inherits(partable, "lavaan")) {
    partable <- lavaan::parameterTable(partable)
  }

  if (sort_rows) {
    partable <- sort_partable(
              partable = partable,
              cols = sort_by
            )
  }

  out0 <- partable[, cols]
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
          algo = algo,
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
#' @rdname digest_partable
#' @export
add_digest <- function(
  partable,
  ...
) {

  # Add a digest to a parameter table
  # Return the parameter table with
  # the value added as the attribute "digest"

  # out0 <- do.call(
  #           sort_partable,
  #           c(list(partable = partable),
  #             args_sort_partable)
  #         )
  # out1 <- do.call(
  #           digest_partable,
  #           c(list(partable = out0),
  #             args_digest_partable)
  #         )
  out1 <- digest_partable(
            partable = partable,
            ...
          )
  attr(partable, "digest") <- out1
  partable
}

#' @details
#' The function [get_digest()] retrieves
#' the stored hash value from a
#' parameter table, if available. If
#' not available, it will call [digest_partable()]
#' to compute the hash value.
#'
#' @return
#' The function [get_digest()] returns
#' the hash value of a parameter table.
#'
#' @rdname digest_partable
#' @export
get_digest <- function(
  partable,
  ...
) {

  # Retrieve the digest value, if available.
  # If not available, compute it.

  out <- attr(partable, "digest")
  if (is.null(out)) {
    out <- digest_partable(
              partable = partable,
              ...
            )
  }
  out
}

#' @details
#' The function [add_digest_partables]
#' call [add_digest()] on a list of
#' parameter tables.
#'
#' @return
#' The function [add_digest_partables]
#' returns the list of parameter tables,
#' with hash values stored.
#'
#' @param partables A list of `lavaan`
#' parameter tables.
#'
#' @rdname digest_partable
#' @export
add_digest_partables <- function(
  partables,
  ...
) {
  # TOOD:
  # - Add some sanity checks.
  out0 <- lapply(
    partables,
    add_digest,
    ...
  )
  class(out0) <- class(partables)
  out0
}


#' @details
#' The function [get_digest_partables]
#' call [get_digest()] on a list of
#' parameter tables.
#'
#' @return
#' The function [get_digest_partables]
#' returns a character vector, the
#' outputs of [get_digest()] for the
#' parameter tables.
#'
#' @rdname digest_partable
#' @export
get_digest_partables <- function(
  partables,
  ...
) {
  # TOOD:
  # - Add some sanity checks.
  out0 <- sapply(
    partables,
    get_digest,
    ...
  )
  out0
}

#' @noRd
sort_partable <- function(
  partable,
  cols = c("lhs", "op", "rhs", "block", "group")
) {
  # Sort a parameter table
  # For comparing different tables

  # TODO:
  # - Handle labels and constraint
  # Sort rows in a parameter table.
  i <- do.call(
            order,
            partable[, cols]
          )
  out0 <- partable[i, ]
  out0
}
