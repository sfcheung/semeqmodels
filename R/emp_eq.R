#' @title Empirical Equivalent Models
#'
#' @description Identify model(s) in
#' a list of parameter tables empirically
#' equivalent to the original model.
#'
#' @details
#' The function [eq_models()]
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
#' The function [eq_models()]
#' returns a list of the class `partables`,
#' of models that are empirically
#' equivalent to the original model.
#'
#' @param partables A list of the class
#' `partables`. If `NULL`, then
#' it will try to generate the models
#' by calling [eq_df_models()] on the
#' argument of `original_model`.
#'
#' @param original_model The original
#' model, fitted by [lavaan::lavaan()]
#' or its wrapper, such as [lavaan::sem()].
#' If it is a `lavaan` parameter table,
#' data will be simulated to fit the model.
#' If it is `NULL`, then the first model
#' in `partables` will be used.
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
#' @param eq_df_models_args If `partables`
#' is not supplied (`NULL`) but
#' `original_model` is set, [eq_df_models()]
#' will be called to generate the models,
#' used a `partables`. This argument
#' is a named list of additional arguments
#' to be passed to [eq_df_models()].
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
#' partables1 <- combine_partables(fit1_1_more_1_less)
#'
#' # Some equivalent
#' partables3 <- combine_partables(fit3_1_more_1_less)
#'
#' eq_out_1 <- eq_models(
#'           partables1,
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#'
#' eq_out_3 <- eq_models(
#'           partables3,
#'           original_model = fit3,
#'           parallel = FALSE
#'         )
#'
#' @export
eq_models <- function(
  partables = NULL,
  original_model = NULL,
  ...,
  se = "none",
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  progress = TRUE,
  tolerance = 1e-5,
  eq_df_models_args = list()
) {

  args <- as.list(match.call()[-1])
  args <- lapply(
            args,
            eval,
            envir = parent.frame()
          )
  args1 <- utils::modifyList(
            args,
            list(
              output = "models",
              env_for_update = parent.frame()
            )
          )
  out <- do.call(
    eq_models_internal,
    args1
  )
  out

}

#' @details
#' The function [is_eq()] is similar to
#' [eq_models()], but returns a logical
#' vector to indicate which models are
#' empirically equivalent to the original
#' model.
#'
#' @return
#' The function [is_eq()] returns a
#' logical vector of the same length
#' of `patables`, with `TRUE` denotes
#' that a model is empirically equivalent
#' to `original_model`.
#'
#' @rdname eq_models
#' @export
is_eq <- function(
  partables = NULL,
  original_model = NULL,
  ...,
  se = "none",
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  progress = TRUE,
  tolerance = 1e-5,
  eq_df_models_args = list()
) {

  args <- as.list(match.call()[-1])
  args <- lapply(
            args,
            eval,
            envir = parent.frame()
          )
  args1 <- utils::modifyList(
            args,
            list(
              output = "logical",
              env_for_update = parent.frame()
            )
          )
  out <- do.call(
    eq_models_internal,
    args1
  )
  out

}

#' @noRd
eq_models_internal <- function(
  partables = NULL,
  original_model = NULL,
  ...,
  se = "none",
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  progress = TRUE,
  tolerance = 1e-5,
  env_for_update = parent.frame(),
  eq_df_models_args = list(),
  output = c("logical", "models")
) {

  # Keep models which are empirically equivalent
  # Input:
  # - The output of model_set()
  # - A eq_partables object
  # - The original fit
  # NOTE:
  # - Empirical in-sample equivalence is used for now,
  #   not mathematical equivalence.

  # Assume partables are unique
  # TODO:
  # - Keep only unique partables

  output <- match.arg(output)

  # ==== Handle main objects ====

  if (is.null(partables) &&
      is.null(original_model)) {
    stop("partables and original_model cannot be both NULL.")
  }

  # ==== Handle 'partables' is NULL ====

  # original_model must not be NULL

  if (is.null(partables) &&
      !is.null(original_model)) {

    # ==== Call eq_df_models ====

    if (inherits(original_model, "lavaan")) {

      # Use original_model in eq_df_models

      # Placeholder

    } else if (is_partable(original_model) ||
               is.character(original_model)) {

      if (is.character(original_model)) {

        # original_model is character

        # Try to parse the model and
        # create a parameter table

        ddd1 <- utils::modifyList(
                  list(...),
                  list(
                      model = original_model,
                      do.fit = FALSE,
                      warn = FALSE
                    ),
                )
        tmp <- tryCatch(
                  suppressWarnings(do.call(
                    lavaan::sem,
                    ddd1
                  )),
                  error = function(e) e
                )
        if (inherits(tmp, "error")) {
          stop("original_model is not a valid lavaan model.")
        }

        partables_original <- lavaan::parameterTable(tmp)

        # Use original_model in eq_df_models

      } else {

        # original_model is a parameter table

        partables_original <- original_model

      }

      dat_original <- dummy_data(partables_original)

      ddd1 <- utils::modifyList(
                list(...),
                list(
                    model = partables_original,
                    data = dat_original,
                    se = "none",
                    warn = FALSE
                  ),
              )
      # Heywood case can be ignored
      original_model <- suppressWarnings(do.call(
          lavaan::sem,
          ddd1
        ))

    } else {
      stop("original model is not a supported object.")
    }

    # Call eq_df_models
    # Set the output to partables

    if (progress) {
      tmp <- paste(
              "Models not provided. They will be",
              "generated from 'original_model'."
            )
      cat(strwrap(
            tmp,
          ),
          sep = "\n")
    }

    original_model <- fix_call(
                        original_model,
                        env_for_call = parent.frame()
                      )
    eq_df_models_args0 <- eq_df_models_args
    eq_df_models_args0 <- utils::modifyList(
      eq_df_models_args0,
      list(
        sem_out = original_model,
        parallel = parallel,
        ncores = ncores,
        progress = progress
      )
    )
    partables <- do.call(
                  eq_df_models,
                  eq_df_models_args0
                )

  }

  # ==== Handle 'original_model' ====

  # partables is not NULL,
  # original model may or may not be NULL

  sem_out1 <- emp_eq_fix_input(
    partables = partables,
    original_model = original_model,
    ...,
    se = se,
    env_for_update = env_for_update
  )

  # sem_out1 is used instead of original_model

  sem_out_df <- unname(lavaan::fitMeasures(sem_out1, "df"))
  # TODO:
  # - Use robust chisq if available
  sem_out_chisq <- unname(lavaan::fitMeasures(sem_out1, "chisq"))

  do_fit_many <- TRUE

  # ==== Handle eq_partables =====

  if (inherits(partables, "eq_partables")) {
    fits <- eq_fits(partables)
    fits_is_lavaan <- sapply(
            fits,
            inherits,
            what = "lavaan"
          )
    if (all(fits_is_lavaan)) {
      fits_same_data <- eq_same_data(partables)
    } else {
      fits_same_data <- FALSE
    }
    if (all(fits_is_lavaan) &&
        fits_same_data) {
      do_fit_many <- FALSE
      dfs <- eq_df(partables)
      chisqs <- eq_chisq(partables)
    }
  }

  # Heywood cases can be ignored, and
  # so we need to suppress the warnings

  # ==== Do fit_many ====

  if (do_fit_many) {
    fits <- suppressWarnings(modelbpp::fit_many(
              model_list = partables,
              sem_out = sem_out1,
              parallel = parallel,
              ncores = ncores,
              make_cluster_args = make_cluster_args,
              progress = progress
            ))
    dfs <- sapply(
      fits$fit,
      function(x) lavaan::fitMeasures(x, "df")
    )
    chisqs <- sapply(
      fits$fit,
      function(x) lavaan::fitMeasures(x, "chisq")
    )
    partables <- add_fit_many(
                  partables,
                  fit_many_out = fits
                )
  }

  # TODO:
  # - Handle nonconvergence cases
  #   Models failed post.check can be kept

  df_eq <- dfs == sem_out_df
  chisq_eq <- abs(chisqs - sem_out_chisq) <= tolerance

  i <- df_eq & chisq_eq

  if (output == "logical") {

    # ==== output: logical ====

    out <- i
    names(out) <- names(partables)
    return(out)
  }

  if (output == "models") {

    # ==== output: models ====

    partables_eq <- partables[i]
    class(partables_eq) <- class(partables)

    return(partables_eq)
  }

  # Should not reach here

}

#' @noRd
emp_eq_fix_input <- function(
  partables = NULL,
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
    # Use the first table in partables as the original model
    if (!isTRUE(is_partable(partables[[1]]))) {
      stop("partables is not a list of parameter tables")
    }
    partable_original <- partables[[1]]
    original_model <- attr(partable_original, "fit")
    if (inherits(original_model, "lavaan")) {
      if ((lavaan::lavInspect(original_model, "options")$se != se) ||
          (length(ddd) != 0)) {
        fit_case <- "update_fit"
      } else {
        fit_case <- "user_fit"
      }
    } else {
      original_model <- NULL
      fit_case <- "new_data"
    }
  } else if (is_partable(original_model)) {
    # original_model is a parameter table.
    # Create the dummy data and sem_out
    partable_original <- original_model
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
    dat_original <- dummy_data(partable_original)
    ddd0 <- utils::modifyList(
              ddd,
              list(model = partable_original,
                   data = dat_original,
                   se = se)
            )
    # Heywood case can be ignored
    sem_out <- suppressWarnings(do.call(
        lavaan::sem,
        ddd0
      ))
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