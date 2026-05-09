#' @title Generate Models with the Same Degrees of Freedom
#'
#' @description Generate a list of models
#' with *df* equal to a fitted model.
#'
#' @details
#' The following steps will be repeated
#' to generate models with the same
#' *df* as a fitted model:
#'
#' First, models with one less *df* than
#' the fitted model will be generated,
#' by fixing more free parameter to zero.
#'
#' Second, for each of the one-more-*df*
#' model, models with one more *df* will
#' be generated, usually by freeing one
#' fixed parameter to free (e.g., adding
#' a regression path). These models will
#' then have the same model *df* as the
#' fitted model.
#'
#' These two steps will be repeated
#' until no more new models are found.
#'
#' @return
#' The function [gen_eq_df_models()]
#' returns an `eq_partables` objects,
#' which is a list of parameter tables.
#'
#' @param sem_out A `lavaan` object, which
#' is usually the output of [lavaan::sem()]
#' or similar wrappers. Models will be
#' generated from this model.
#'
#' @param exclude_x_y_ecov If `TRUE`,
#' models with one or more covariance
#' between an exogenous variable and an
#' error term will be excluded.
#'
#' @param parallel Whether parallel
#' processing will be used. (NOT READY
#' FOR NOW.)
#'
#' @param progress If `TRUE`, messages
#' will be displayed to report the
#' progress of the search.
#'
#' @param gen_models_progress If `TRUE`,
#' then progress in each call to
#' [drop_k()] or [add_k()] will also
#' be displayed.
#'
#' @examples
#'
#' # TODO:
#' # The example is too long to run. Shorten it.
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
#'
#' out <- gen_eq_df_models(
#'   sem_out = fit1
#' )
#' out
#'
#' @export
gen_eq_df_models <- function(
  sem_out,
  exclude_x_y_ecov = TRUE,
  parallel = FALSE,
  progress = TRUE,
  gen_models_progress = FALSE
) {
  # Add other arguments later
  optwidth <- getOption("width")
  out <- as_eq_partables()
  out_drop_tried <- as_eq_partables()
  out_add_tried <- as_eq_partables()
  k_old <- -1
  k_new <- 0
  while (k_old < k_new) {
    k_old <- length(out)
    if (length(out) == 0) {
      out_i <- as_eq_partables(sem_out)
      sem_out0 <- sem_out
    } else {
      out_i <- out
      sem_out0 <- NULL
    }
    out_i <- setdiff_eq_partables(
              out_i,
              out_add_tried
            )
    # path_all(tmp)
    if (progress) {
      cat("Searching for models with one more degree of freedom ...")
    }
    out_drop_i <- lapply(
      out_i,
      drop_k,
      sem_out = sem_out0,
      fit_models = TRUE,
      parallel = FALSE,
      progress = gen_models_progress
    )
    out_add_tried <- c(out_i, out_add_tried)
    # path_all_list(out_drop_i)
    out_drop_i <- combine_ptables(
              out_drop_i
            )
    out_drop_i <- setdiff_eq_partables(
              out_drop_i,
              out_drop_tried
            )
    # path_all(out_drop_i)
    if (progress) {
      cat("\r", strrep(" ", optwidth), "\r")
      cat("Searching for models with the same degree of freedom ...")
    }
    out_add_i <- lapply(
      out_drop_i,
      add_k,
      sem_out = sem_out,
      fit_models = TRUE,
      parallel = FALSE,
      progress = gen_models_progress
    )
    out_drop_tried <- c(out_drop_tried, out_drop_i)
    # path_all_list(out_add_i)
    out_add_i <- combine_ptables(
              out_add_i
            )
    out <- c(out_add_i, out)
    # path_all(out)
    k_new <- length(out)
    if (progress) {
      k_diff <- k_new - k_old
      tmp <- sprintf(
        "New model(s): %1$d / Total model(s) found: %2$d\n",
        k_diff,
        k_new
      )
      cat("\r", strrep(" ", optwidth), "\r")
      cat(tmp)
    }
  }

  if (exclude_x_y_ecov) {

    # ==== Remove models with x_y_ecov ====

    chk <- sapply(
              out,
              has_x_y_ecov
            )
    if (any(chk)) {
      if (progress) {
        tmp <- sprintf(
          "Removed %d model(s) with x-error covariances.\n",
          round(sum(chk))
        )
        cat(tmp)
      }
      tmp <- class(out)
      out <- out[!chk]
      class(out) <- tmp
    }

  }

  if (progress) {
    tmp <- sprintf(
        "Model(s) retrained: %d\n",
        length(out)
      )
    cat(tmp)
  }

  # TODO:
  # - Should sem_out be excluded?
  out
}
