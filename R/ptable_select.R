#' @title Select Parameter Tables
#'
#' @description Helper functions to
#' select parameter tables based on
#' parameters.
#'
#' @name partable_select
NULL

#' @details
#' The functions [models_have_pars_all()]
#' and [have_pars_all()] identify models
#' that have all the free parameters
#' specified in `pars`.
#'
#' @return
#' The function [models_have_pars_all()]
#' returns a list of parameter tables
#' that have all the free parameters
#' specified in `pars`.
#' The function [have_pars_all()] returns
#' a logical vector to indicate models
#' that have all the free parameters
#' specified.
#'
#' @param partables A list of parameter
#' tables, such as a
#' `partables` or `eq_partables` object.
#'
#' @param pars A character vector
#' of `lavaan` model syntax that
#' can be converted to a parameter table.
#' It can be a vector of parameters,
#' such as `c("y ~ x", "m ~~ x")`, but
#' can also be of other forms as long
#' as `lavaan::lavParseModelString()`
#' can process it. Covariances such as
#' `"m ~~ x"` and `"x ~~ m"` are treated
#' as the same and so only one of them
#' is necessary.
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
#' models_have_pars_all(partables1, c("fx ~~ fm", "fy ~ fx"))
#' have_pars_all(partables1, c("fx ~~ fm", "fy ~ fx"))
#'
#' @rdname partable_select
#' @export
models_have_pars_all <- function(
  partables,
  pars = NULL
) {
  have_pars(
    partables = partables,
    pars = pars,
    mode = "all",
    output = "partables"
  )
}

#' @details
#' The functions [models_have_pars_any()]
#' and [have_pars_any()] identify models
#' that have any of the free parameters
#' specified in `pars`.
#'
#' @return
#' The function [models_have_pars_all()]
#' returns a list of parameter tables
#' that have any the free parameters
#' specified in `pars`.
#' The function [have_pars_all()] returns
#' a logical vector to indicate models
#' that have any of the free parameters
#' specified.
#'
#' @examples
#'
#' models_have_pars_any(partables1, c("fx ~~ fm", "fm ~ fy"))
#' have_pars_any(partables1, c("fx ~~ fm", "fm ~ fx"))
#'
#' @rdname partable_select
#' @export
models_have_pars_any <- function(
  partables,
  pars = NULL
) {
  have_pars(
    partables = partables,
    pars = pars,
    mode = "any",
    output = "partables"
  )
}

#' @details
#' The functions [models_have_pars_none()]
#' and [have_pars_none()] identify models
#' that have all none of the free parameters
#' specified in `pars`.
#'
#' @return
#' The function [models_have_pars_none()]
#' returns a list of parameter tables
#' that have none of the free parameters
#' specified in `pars`.
#' The function [have_pars_none()] returns
#' a logical vector to indicate models
#' that have none of the free parameters
#' specified.
#'
#' @examples
#'
#' models_have_pars_none(partables1, c("fx ~~ fm", "fm ~ fx"))
#' have_pars_none(partables1, c("fx ~~ fm", "fm ~ fx"))
#'
#' @rdname partable_select
#' @export
models_have_pars_none <- function(
  partables,
  pars = NULL
) {
  have_pars(
    partables = partables,
    pars = pars,
    mode = "none",
    output = "partables"
  )
}

#' @rdname partable_select
#' @export
have_pars_all <- function(
  partables,
  pars = NULL
) {
  have_pars(
    partables = partables,
    pars = pars,
    mode = "all",
    output = "logical"
  )
}

#' @rdname partable_select
#' @export
have_pars_any <- function(
  partables,
  pars = NULL
) {
  have_pars(
    partables = partables,
    pars = pars,
    mode = "any",
    output = "logical"
  )
}

#' @rdname partable_select
#' @export
have_pars_none <- function(
  partables,
  pars = NULL
) {
  have_pars(
    partables = partables,
    pars = pars,
    mode = "none",
    output = "logical"
  )
}

#' @noRd
have_pars <- function(
  partables,
  pars = NULL,
  mode = c("any", "all", "none"),
  output = c("logical", "models", "partables")
) {
  # Which models in the list:
  # - has any/all/none of the parameters?
  mode <- match.arg(mode)
  mode_none <- FALSE
  if (mode == "none") {
    mode <- "any"
    mode_none <- TRUE
  }
  output <- match.arg(output)
  if (output == "models") {
    output <- "partables"
  }
  if (!is.null(pars)) {
    pars_lav_list <- parse_pars_to_list(pars)
    out <- sapply(
      partables,
      has_pars_i,
      pars_lav_list = pars_lav_list,
      mode = mode
    )
    if (mode_none) {
      out <- !out
    }
  } else {
    out <- rep(TRUE, length(partables))
    names(out) <- names(partables)
  }
  out1 <- switch(
    output,
    logical = out,
    partables = partables[out]
  )
  out1
}

#' @noRd
parse_pars_to_list <- function(
  pars
) {
  # Convert model syntax to a list of one-row parameter tables
  pars_lav <- lavaan::lavParseModelString(
    pars,
    as.data.frame. = TRUE,
    warn = FALSE
  )
  pars_lav_list <- split(
    pars_lav,
    seq_len(nrow(pars_lav))
  )
  pars_lav_list
}

#' @noRd
has_pars_i <- function(
  partable,
  pars_lav_list,
  mode = c("any", "all")
) {
  # Does a model has any/all of parameter pars?
  mode <- match.arg(mode)
  out0 <- sapply(
    pars_lav_list,
    has_par_i,
    partable = partable
  )
  if (mode == "any") {
    out1 <- any(out0)
  } else if (mode == "all") {
    out1 <- all(out0)
  }
  out1
}

#' @noRd
has_par_i <- function(
  partable,
  par
) {
  # Does a model has parameter par as a free parameter?
  # partable is a parameter table of a model
  # par must be a one-row parameter table
  op <- par$op
  if (op == "~~") {
    i1 <- (partable$op == par$op) &
          (partable$lhs == par$lhs) &
          (partable$rhs == par$rhs) &
          (partable$free > 0)
    i2 <- (partable$op == par$op) &
          (partable$lhs == par$rhs) &
          (partable$rhs == par$lhs) &
          (partable$free > 0)
    out <- any(i1 | i2)
  } else {
    i1 <- (partable$op == par$op) &
          (partable$lhs == par$lhs) &
          (partable$rhs == par$rhs) &
          (partable$free > 0 )
    out <- any(i1)
  }
  isTRUE(out)
}

#' @details
#' The function [remove_x_y_ecov()]
#' remove models from `partables` that
#' have one or more covariances between
#' an exogenous variable (observed
#' or latent) and an error term.
#'
#' @return
#' The function [remove_x_y_ecov()]
#' return a list of parameter tables,
#' of the same class as `partables`.
#'
#' @rdname partable_select
#' @export
remove_x_y_ecov <- function(
  partables
) {

  # Remove models with x_y_ecov

  chk <- sapply(
            partables,
            has_x_y_ecov
          )
  if (any(chk)) {
    tmp <- class(partables)
    partables <- partables[!chk]
    class(partables) <- tmp
  }
  partables
}


#' @details
#' The function [must_not_be_nox()]
#' keep only models with variables
#' (observed or latent) that are
#' not being affected or predicted
#' by other variables. They are
#' defined as variables not
#' in `"ov.nox"` and `"lv.nox"`
#' as returned by [lavaan::lavNames()].
#'
#' @param vars A character vector of
#' variables to be checked.
#'
#' @return
#' The function [must_not_be_nox()]
#' returns a list of parameter tables,
#' of the same class as `partables`.
#'
#' @rdname partable_select
#' @export
must_not_be_nox <- function(
  partables,
  vars = NULL
) {

  chk <- sapply(
            partables,
            vars_is_nox,
            vars = vars
          )
  chk <- !chk
  out <- partables[chk]
  class(out) <- class(partables)
  out
}

#' @noRd
vars_is_nox <- function(
  partable,
  vars = NULL
) {
  i1 <- lavaan::lavNames(
          partable,
          type = "ov.nox"
        )
  i2 <- lavaan::lavNames(
          partable,
          type = "lv.nox"
        )
  i <- union(i1, i2)
  any(vars %in% i)
}