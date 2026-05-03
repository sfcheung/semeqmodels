#' @title Empirical Equivalent Models
#'
#' @description Identify model(s) in
#' a list of parameter tables empirically
#' equivalent to the original model.
#'
#' @details
#' The function [empirical_eq()]
#' checks the model degrees of freedom
#' and model chi-squares of a list of
#' models against an original model,
#' fitted to a sample, to identify models
#' that are *empirically* *equivalent*
#' to the original model *in this sample*.
#'
#' Two models are empirically equivalent
#' if they (a) have the same model degrees
#' of freedom and (b) have a difference
#' in model chi-squares equal to or less
#' than a tolerance (controlled by the
#' argument `tolerance`).
#'
#' If two models are mathematically
#' equivalent, then they must be empirically
#' equivalent.
#'
#' However, even if two models are not
#' mathematically equivalent, they may
#' still be empirically equivalent for
#' a sample.
#'
#' @return
#' The function [empirical_eq()]
#' returns a list of the class `partables`,
#' of models that are empirically
#' equivalent to the original model.
#'
#' @param ptables A list of the class
#' `partables`.
#'
#' @param original_model The original
#' model, fitted by [lavaan::lavaan()]
#' or its wrapper, such as [lavaan::sem()].
#'
#' @param ... Optional arguments to be
#' used when fitting models to the data.
#' Usually can be omitted.
#'
#' @param se How standard errors are to
#' be computed. To be passed to `lavaan`.
#' The default, `"none"`, is sufficient
#' because the standard errors are not
#' needed to check whether two models
#' are empirically equivalent.
#'
#' @param parallel Whether parallel
#' processing will be used when fitting
#' models. Default is `TRUE`.
#' To be passed
#' to [modelbpp::fit_many()].
#'
#' @param ncores The number of CPU cores
#' to use when parallel processing is used.
#' To be passed
#' to [modelbpp::fit_many()].
#'
#' @param make_cluster_args Additional
#' arguments to be passed to
#' [modelbpp::fit_many()] when creating
#' a cluster for parallel processing.
#' To be passed
#' to [modelbpp::fit_many()].
#'
#' @param progress Whether the testing
#' progresss will be displayed
#' on screen.
#'
#' @param tolerance The maximum difference
#' in model chi-squares for two models
#' to be considered empirically equivalent.
#'
#' @references
#' Pesigan, I. J. A., Cheung, S. F.,
#' Wu, H., Chang, F., & Leung, S. O. (2026).
#' How plausible is my model? Assessing
#' model plausibility of structural
#' equation models using Bayesian
#' posterior probabilities (BPP).
#' *Behavior Research Methods*, *58*(3),
#' 73.
#' \doi{10.3758/s13428-025-02921-x}
#'
#' @seealso [modelbpp::fit_many()] for
#' the function use to fit the models.
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
#' # Model 3
#'
#' mod3 <-
#' "
#' fx =~ x1 + x2 + x3
#' fm =~ m1 + m2 + m3
#' fy =~ y1 + y2 + y3
#' fm ~ fx
#' fy ~ fm
#' "
#' fit3 <- sem(
#'           model = mod3,
#'           data = data_test_3_factor_3_item
#'         )
#' fit3_1_more <- drop_k(fit3)
#' fit3_1_more_1_less <- lapply(
#'   fit3_1_more,
#'   add_k
#' )
#'
#' # All equivalent
#' ptables1 <- combine_ptables(fit1_1_more_1_less)
#'
#' # Some equivalent
#' ptables3 <- combine_ptables(fit3_1_more_1_less)
#'
#' eq_out_1 <- empirical_eq(
#'           ptables1,
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#'
#' eq_out_3 <- empirical_eq(
#'           ptables3,
#'           original_model = fit3,
#'           parallel = FALSE
#'         )
#'
#' @export
empirical_eq <- function(
  ptables,
  original_model = NULL,
  ...,
  se = "none",
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  progress = TRUE,
  tolerance = 1e-5
) {

  # Keep models which are empirically equivalent
  # Input:
  # - The output of model_set()
  # - A eq_partables object
  # - The original fit
  # NOTE:
  # - Empirical in-sample equivalence is used for now,
  #   not mathematical equivalence.

  # Assume ptables are unique
  # TODO:
  # - Keep only unique ptables

  # TODO:
  # - Generate dummy data if original_model
  #   is a parameter table.

  sem_out1 <- emp_eq_fix_input(
    ptables = ptables,
    original_model = original_model,
    ...,
    se = se,
    env_for_update = parent.frame()
  )

  # sem_out1 is used instead of original_model

  sem_out_df <- unname(lavaan::fitMeasures(sem_out1, "df"))
  # TODO:
  # - Use robust chisq if available
  sem_out_chisq <- unname(lavaan::fitMeasures(sem_out1, "chisq"))

  fits <- modelbpp::fit_many(
            model_list = ptables,
            sem_out = sem_out1,
            parallel = parallel,
            ncores = ncores,
            make_cluster_args = make_cluster_args,
            progress = progress
          )

  # TODO:
  # - Handle nonconvergence cases
  #   Models failed post.check can be kept

  dfs <- sapply(
    fits$fit,
    function(x) lavaan::fitMeasures(x, "df")
  )
  chisqs <- sapply(
    fits$fit,
    function(x) lavaan::fitMeasures(x, "chisq")
  )

  df_eq <- dfs == sem_out_df
  chisq_eq <- abs(chisqs - sem_out_chisq) <= tolerance

  i <- df_eq & chisq_eq

  ptables_eq <- ptables[i]
  class(ptables_eq) <- class(ptables)

  ptables_eq
}

#' @noRd
emp_eq_fix_input <- function(
  ptables,
  original_model = NULL,
  ...,
  se = "none",
  env_for_update = parent.frame()
) {
  ddd <- list(...)
  # Output
  # - A lavaan fit object
  fit_case <- "none"
  if (is.null(original_model)) {
    # Use the first table in ptables as the original model
    if (!isTRUE(is_partable(ptables[[1]]))) {
      stop("ptables is not a list of parameter tables")
    }
    ptable_original <- ptables[[1]]
    fit_case <- "new_data"
  } else if (is_partable(original_model)) {
    # original_model is a parameter table.
    # Create the dummy data and sem_out
    ptable_original <- original_model
    fit_case <- "new_data"
  } else if (inherits(original_model, "lavaan")) {
    # original_model is a lavaan object.
    # Check if update is necessary
    if ((lavaan::lavInspect(original_model, "options")$se != se) ||
        (length(ddd) != 0)) {
      fit_case <- "update_fit"
    } else {
      fit_case <- "user_fit"
    }
  } else {
    stop("original_model is not a supported object")
  }

  if (fit_case == "new_data") {
    # TODO:
    # - Handle failed cases
    dat_original <- dummy_data(ptable_original)
    ddd0 <- utils::modifyList(
              ddd,
              model = ptables_tmp,
              data = dat,
              se = se
            )
    sem_out <- do.call(
        lavaan::sem,
        ddd0
      )
  } else if (fit_case == "update_fit") {
    # Need this for lavaan::update()
    # TODO:
    # - Should lavaan::lavaan() be used?
    tmp0 <- stats::getCall(original_model)
    tmp0$se <- se
    tmp <- lapply(
              tmp0,
              \(x, envir0) eval(x, envir0),
              envir0 = env_for_update
            )
    tmp <- as.call(tmp)
    tmp[[1]] <- tmp0[[1]]
    original_model@call <- tmp
    sem_out <- lavaan::update(
      original_model,
      se = se,
      ...
    )
  } else if (fit_case == "user_fit") {
    sem_out <- original_model
  }
  sem_out
}