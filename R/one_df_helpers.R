#' @noRd
remove_dropped <- function(
  partable
) {

  # Remove parameter(s) fixed to zero when
  # generated from the original model

  ids <- attr(partable, "ids_dropped")
  if (length(ids) > 0) {
    partable <- partable[-ids, ]
  }
  partable
}

#' @noRd
remove_fixed_zero <- function(
  partable,
  op = c("~~", "~")
) {

  # Remove parameter(s) fixed to zero

  i_free <- partable$free == 0
  i_zero <- partable$start == 0
  i_op <- partable$op %in% op
  i <- i_free & i_zero & i_op
  out <- partable
  out[!i, ]
}

#' @noRd
fix_object <- function(
  object
) {
  if (inherits(object, "lavaan")) {
    fit <- object
    partable <- lavaan::parameterTable(fit)
  } else {
    # Assume the object is a parameter table
    partable <- object
    dat <- dummy_data(partable)
    # TODO:
    # - Accept other options to sem()
    fit <- lavaan::sem(
              model = partable,
              data = dat,
              test = "standard",
              se = "none"
            )
  }
  list(partable = partable,
       fit = fit)
}

#' @noRd
dummy_data <- function(
  partable,
  n = NULL,
  n_min = 200,
  n_per_p = 30,
  max_attempts = 10,
  random_delta = c(-.40, .40)
) {

  fit0 <- lavaan::sem(
            model = partable,
            do.fit = FALSE
          )
  ovnames <- lavaan::lavNames(
          fit0,
          "ov"
        )
  fixed.x <- partable_fixedx(partable = partable)
  p <- length(ovnames)
  if (is.null(n)) {
    n <- min(p * n_per_p, n_min)
  }
  partablei <- partable
  k <- (partablei$free > 0) &
       (partablei$start < .Machine$double.eps)
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
      partablei[k, "start"] <- tmp
    }
    out <- tryCatch(
              lavaan::simulateData(
                model = partablei,
                sample.nobs = n
              ),
            error = function(e) e,
            warning = function(w) w)
    if (!inherits(out, "error") &&
        !inherits(out, "warning")) {
      # ==== Ensure that the model can be fitted ====
      fit_chk <- tryCatch(
                lavaan::sem(
                  model = partablei,
                  data = out,
                  fixed.x = fixed.x
                ),
                error = function(e) e,
                warning = function(w) w)
    }
    if (inherits(fit_chk, "error") ||
        inherits(fit_chk, "warning")) {
      out <- try(stop(), silent = TRUE)
    }
    i <- i - 1
  }
  if (!is.data.frame(out)) {
    stop("Failed to generate simulated data. Please use a lavaan output.")
  }
  out
}

#' @noRd
x_y_pairs <- function(
  object
) {

  # Output
  # - Always a data frame, though may have
  #   0 row.

  # # Whether a variable is in "ov.nox" depends
  # # on fixed.x. Should use eqs.x and eqs.y.
  # all_x1 <- lavaan::lavNames(
  #   object,
  #   "ov.x"
  # )
  # all_x2 <- lavaan::lavNames(
  #   object,
  #   "lv.x"
  # )
  all_x1 <- character(0)
  all_x2 <- character(0)
  all_x3 <- lavaan::lavNames(
    object,
    "eqs.x"
  )
  all_x <- unique(c(all_x1, all_x2, all_x3))
  # # Whether a variable is in "ov.nox" depends
  # # on fixed.x. Should use eqs.x and eqs.y.
  # all_y1 <- lavaan::lavNames(
  #   object,
  #   "ov.nox"
  # )
  # all_y2 <- lavaan::lavNames(
  #   object,
  #   "lv.nox"
  # )
  all_y1 <- character(0)
  all_y2 <- character(0)
  all_y3 <- lavaan::lavNames(
    object,
    "eqs.y"
  )
  all_y <- unique(c(all_y1, all_y2, all_y3))
  all_ind <- lavaan::lavNames(
    object,
    "ov.ind"
  )
  all_x <- setdiff(all_x, all_ind)
  all_y <- setdiff(all_y, all_ind)

  out0 <- expand.grid(
            x = all_x,
            y = all_y,
            stringsAsFactors = FALSE
          )

  # If no x-y pairs, out0 will have 0 rows

  out0
}

#' @noRd
x_y_ecov <- function(
  object
) {
  # Form a vector of covariances
  # between an exogenous variable
  # and an error terms.
  # To be used in `must_not_add`.

  # The output of x_y_pairs is always a data frame,
  # though may have zero row.
  out0 <- x_y_pairs(object)

  if (nrow(out0) == 0) {
    return(character(0))
  }

  # ==== Check for direct paths ====

  out0$direct <- FALSE
  for (i in seq_len(nrow(out0))) {
    ii <- (object$rhs == out0[i, "x"]) &
          (object$lhs == out0[i, "y"]) &
          (object$op == "~")
    if (any(ii)) {
      out0[i, "direct"] <- TRUE
    }
  }

  # ==== Check for indirect paths ====

  fit <- lavaan::sem(
    object,
    do.fit = FALSE
  )
  out0$indirect <- FALSE
  ind_paths <- manymome::all_indirect_paths(
    fit = fit,
    x = unique(out0$x),
    y = unique(out0$y)
  )
  if (length(ind_paths) > 0) {
    for (ii in ind_paths) {
      jj <- (out0$x == ii$x) &
            (out0$y == ii$y)
      out0$indirect[jj] <- TRUE
    }
  }

  i <- out0$direct | out0$indirect
  if (!any(i)) {
    return(character(0))
  }

  out0 <- out0[i, c("x", "y")]

  out1a <- apply(
      out0,
      MARGIN = 1,
      \(x) paste(x, collapse = "~~")
    )
  out1b <- apply(
      out0[, c("y", "x")],
      MARGIN = 1,
      \(x) paste(x, collapse = "~~")
    )
  out <- unique(c(out1a, out1b))
  out
}

#' @noRd
has_x_y_ecov <- function(
  object
) {
  # Check whether a model has
  # a covariance between an exogenous
  # variable and an error term
  chk <- x_y_ecov(object)
  if (length(chk) == 0) {
    return(FALSE)
  }
  if (inherits(object, "lavaan")) {
    object <- lavaan::parameterTable(object)
  }
  i1 <- object$op == "~~"
  i2 <- object$lhs != object$rhs
  i <- i1 & i2
  if (all(!i)) {
    return(FALSE)
  }
  all_cov <- apply(
    object[i, c("lhs", "op", "rhs")],
    MARGIN = 1,
    paste0,
    collapse = ""
  )
  any(all_cov %in% chk)
}

#' @noRd
rename_to_digest <- function(
  object_list
) {
  # Usually for eq_partables object
  # If the "gen_models_name" attribute is NULL
  # store the current name to this attribute,
  # then rename to the hash value (store or new)
  # Output:
  # - object_list with
  #   - attribute "gen_models_name" set
  #   - digest added
  #   - hash values as names

  old_names <- names(object_list)

  # ==== Add gen_models_name, if absent ====

  for (x in seq_along(object_list)) {
    tmp <- object_list[[x]]
    if (is.null(attr(tmp, "gen_models_name"))) {
      attr(tmp, "gen_models_name") <- old_names[x]
      object_list[[x]] <- tmp
    }
  }

  # ==== Add digest ====

  out <- add_digest_partables(object_list)

  # ==== Use digest as name ====

  new_names <- get_digest_partables(out)
  names(out) <- new_names

  out

}

partable_fixedx <- function(
  partable
) {
  xnames <- lavaan::lavNames(
    partable,
    "ov.x"
  )
  if (length(xnames) > 0) {
    # ==== fixed.x? ====
    fit0 <- lavaan::sem(
              model = partable,
              do.fit = FALSE
            )
    tmp <- lavaan::lavInspect(fit0,
            "free",
            drop.list.single.group = FALSE
          )[[1]]$psi
    fixed.x <- any(diag(tmp)[xnames] == 0)
  } else {
    fixed.x <- TRUE
  }
  fixed.x
}

fix_partable_for_new_exo <- function(
  partable
) {
  if (!partable_fixedx(partable)) {
    # Only process models with fixed.x = TRUE
    return(partable)
  }
  xnames <- lavaan::lavNames(
    partable,
    "ov.x"
  )
  dvs <- lavaan::lavNames(
    partable,
    "eqs.y"
  )
  pure_x <- setdiff(xnames, dvs)
  if (length(pure_x) == 0) {
    return(partable)
  }
  i <- partable$exo == 1
  j <- (partable$lhs == partable$rhs) &
       (partable$lhs %in% pure_x) &
       (partable$op == "~~")
  k <- j & !i
  if (isFALSE(any(k))) {
    return(partable)
  }
  out <- partable
  out$exo[k] <- 1
  out$free[k] <- 0
  m <- out$free > 0
  out$free[m] <- seq_len(sum(m))
  out
}

#' @noRd
alternative_pars <- function(
  partable
) {
  # If x~y has been dropped
  # then x~~y can be added.
  # If x~~y has been dropped
  # then x~y and y~x can be added
  if (is.null(attr(partable, "parameters_dropped"))) {
    return(character(0))
  }
  pars_dropped <- attr(partable, "parameters_dropped_list")
  f <- function(xx) {
    if (xx["op"] == "~") {
      out <- xx
      out["op"] <- "~~"
      out <- paste0(out, collapse = "")
    } else if (xx["op"] == "~~") {
      out1 <- xx
      out1["op"] <- "~"
      out2 <- c(lhs = unname(xx["rhs"]),
                op = "~",
                rhs = unname(xx["lhs"]))
      out1 <- paste0(out1, collapse = "")
      out2 <- paste0(out2, collapse = "")
      out <- c(out1, out2)
    } else {
      out <- character(0)
    }
    out
  }
  out <- lapply(
    pars_dropped,
    FUN = f
  )
  unlist(out)
}
