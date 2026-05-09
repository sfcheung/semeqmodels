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
#' The function [eq_df_models()]
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
#' @param fit_models Whether the models
#' will be fitted to the data. To be
#' passed to [drop_k()] and [add_k()].
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
#' out <- eq_df_models(
#'   sem_out = fit1
#' )
#' out
#'
#' @export
eq_df_models <- function(
  sem_out,
  fit_models = FALSE,
  exclude_x_y_ecov = TRUE,
  parallel = FALSE,
  progress = TRUE,
  gen_models_progress = FALSE
) {
  # TODO:
  # - Add other arguments, e.g., for add_k() and drop_k().
  optwidth <- getOption("width")
  out <- as_eq_partables()
  out_drop_tried <- as_eq_partables()
  out_add_tried <- as_eq_partables()
  k_old <- -1
  k_new <- 0

  # ==== Start the loop ====

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
    if (length(out_i) == 0) {
      break
    }

    # ==== Find 1-more-df models ====

    if (progress) {
      cat("Searching for models with one more degree of freedom ...")
    }
    out_add_tried <- c(out_i, out_add_tried)
    out_drop_i <- lapply(
      out_i,
      drop_k,
      sem_out = sem_out0,
      fit_models = fit_models,
      parallel = FALSE,
      progress = gen_models_progress
    )

    out_drop_i <- combine_ptables(
              out_drop_i
            )
    out_drop_i <- setdiff_eq_partables(
              out_drop_i,
              out_drop_tried
            )

    if (progress) {
      cat("\r", strrep(" ", optwidth), "\r")
      cat("Searching for models with the same degree of freedom ...")
    }

    if (exclude_x_y_ecov && FALSE) {

      # ==== Exclude variables with x-error covariances ====

      # Disabled for now

      tmp <- length(out_drop_i)
      out_drop_i <- remove_x_y_ecov(
          out_drop_i,
          progress = FALSE
        )
      if ((tmp > length(out_drop_i)) &&
          progress) {
        cat("\r", strrep(" ", optwidth), "\r")
        tmp2 <- sprintf(
          "Removed %d model(s) with x-error covariances.\n",
          round(tmp - length(out_drop_i))
        )
        cat(tmp2)
      }

    }

    # ==== Find 1-less-df models ====

    out_drop_tried <- c(out_drop_tried, out_drop_i)
    out_add_i <- lapply(
      out_drop_i,
      add_k,
      sem_out = sem_out,
      fit_models = fit_models,
      parallel = FALSE,
      progress = gen_models_progress
    )

    out_add_i <- combine_ptables(
              out_add_i
            )
    out <- c(out_add_i, out)

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

  # ==== End the loop ====

  # ==== Prepare the output ====

  # ==== Exclude models with x-error covariances ====

  if (exclude_x_y_ecov) {
    tmp <- length(out)
    out <- remove_x_y_ecov(
        out,
        progress = progress
      )
    if (tmp > length(out)) {
      cat("\n")
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
