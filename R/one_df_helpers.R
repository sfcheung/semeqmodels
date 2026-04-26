#' @noRd
remove_dropped <- function(
  ptable
) {

  # Remove parameter(s) fixed to zero when
  # generated from the original model

  ids <- attr(ptable, "ids_dropped")
  if (length(ids) > 0) {
    ptable <- ptable[-ids, ]
  }
  ptable
}

#' @noRd
remove_fixed_zero <- function(
  ptable,
  op = c("~~", "~")
) {

  # Remove parameter(s) fixed to zero

  i_free <- ptable$free == 0
  i_zero <- ptable$start == 0
  i_op <- ptable$op %in% op
  i <- i_free & i_zero & i_op
  out <- ptable
  out[!i, ]
}

#' @noRd
fix_object <- function(
  object
) {
  if (inherits(object, "lavaan")) {
    fit <- object
    ptable <- lavaan::parameterTable(fit)
  } else {
    # Assume the object is a parameter table
    ptable <- object
    dat <- dummy_data(ptable)
    # TODO:
    # - Accept other options to sem()
    fit <- lavaan::sem(
              model = ptable,
              data = dat,
              test = "standard",
              se = "none"
            )
  }
  list(ptable = ptable,
       fit = fit)
}

#' @noRd
dummy_data <- function(
  ptable,
  n = NULL,
  n_min = 200
) {

  # TODO:
  # - Need to random set free paths to
  #   no zero in the population.

  fit0 <- lavaan::sem(
            model = ptable,
            do.fit = FALSE
          )
  ovnames <- lavaan::lavNames(
          fit0,
          "ov"
        )
  p <- length(ovnames)
  if (is.null(n)) {
    n <- min(p * 20, n_min)
  }
  out <- suppressWarnings(
            lavaan::simulateData(
              model = ptable,
              sample.nobs = n
            )
          )
  out
}
