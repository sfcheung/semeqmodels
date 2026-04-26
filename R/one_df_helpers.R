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
  n_min = 200,
  n_per_p = 20,
  max_attempts = 10,
  random_delta = c(.01, .10)
) {

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
    n <- min(p * n_per_p, n_min)
  }
  ptablei <- ptable
  k <- (ptablei$free > 0) &
       (ptablei$start < .Machine$double.eps)
  i <- max_attempts
  out <- NULL
  while ((i > 0) &&
         !is.data.frame(out)) {
    if (any(k)) {
      tmp <- stats::runif(
                sum(k),
                min = random_delta[1],
                max = random_delta[2]
              )
      tmp <- tmp * sample(c(-1, 1), sum(k), replace =  TRUE)
      ptablei[k, "start"] <- tmp
    }
    out <- tryCatch(suppressWarnings(
              lavaan::simulateData(
                model = ptablei,
                sample.nobs = n
              )
            ),
            error = function(e) e)
    i <- i - 1
  }
  if (!is.data.frame(out)) {
    stop("Failed to generate the dummy data.")
  }
  out
}
