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
#' The `print`-method of `eq_partables`
#' object handles a zero-length list.
#' If not of zero-length, the `print`-method
#' for `partables` will be used.
#'
#' @return
#' The `print`-method of `eq_partables`
#' return `x` invisibly. It is called
#' for its side-effet.
#'
#' @rdname ptable_helpers
#' @export
print.eq_partables <- function(
  x,
  ...
) {
  if (length(x) == 0) {
    cat("The number of models is zero.\n")
  } else {
    NextMethod()
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
#' used.
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

#' @noRd
remove_x_y_ecov <- function(
  object,
  progress = FALSE
) {

  # Remove models with x_y_ecov

  chk <- sapply(
            object,
            has_x_y_ecov
          )
  if (any(chk)) {
    if (progress) {
      tmp <- sprintf(
        "Removed %d model(s) with x-error covariances.",
        round(sum(chk))
      )
      cat(tmp)
    }
    tmp <- class(object)
    object <- object[!chk]
    class(object) <- tmp
  }
  object
}

