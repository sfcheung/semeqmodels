#' @title Empirical Equivalent Models
#'
#' @description Identify model(s) in
#' a list of models (parameter tables) empirically
#' equivalent to the original model.
#'
#' @details
#'
#' ## `eq_models()`
#'
#' The function [eq_models()]
#' checks the model degrees of freedom
#' and model chi-squares of a list of
#' models (represented by `lavaan`
#' parameter tables) against an original model,
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
#' ## How to Generate the List of Models to Check
#'
#' Usually, the alternative models can be generated
#' automatically by leaving `partables`
#' at its default value (`NULL`). The function
#' [eq_df_models()] will be called using
#' `original_model` as the original model.
#' The generation can be customized by setting
#' the argument `eq_df_models_args`.
#'
#' Alternatively, the function [eq_df_models()]
#' can be called directly to generate
#' an initial list of models. This list
#' can then be filtered by helpers
#' in [partable_select], such as
#' [must_be_y()] or [must_not_have_paths()],
#' and use the resulting list as `partables`.
#'
#' @return
#' The function [eq_models()]
#' returns a list of the class `eq_partables`
#' (a subclass of `partables`)
#' of models that are empirically
#' equivalent to the original model.
#'
#' @param partables A list of the class
#' `partables`. If `NULL`, [eq_models()]
#' will try to generate the models
#' by calling [eq_df_models()] on the
#' argument of `original_model`.
#' For `[is_eq()]`, this argument cannot
#' be `NULL`.
#'
#' @param original_model The original
#' model, fitted by [lavaan::lavaan()]
#' or its wrapper, such as [lavaan::sem()].
#' If it is a `lavaan` parameter table
#' (the output of [lavaan::parameterTable()]),
#' data will be simulated to fit the model.
#' If it is `NULL`, then the first model
#' in `partables` will be used.
#'
#' @param ... Optional arguments to be
#' used when fitting models to the data,
#' to be passed to [lavaan::sem()].
#' Usually can be omitted.
#'
#' @param se How standard errors are to
#' be computed. To be passed to [lavaan::sem()].
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
#' progress will be displayed
#' on screen.
#'
#' @param tolerance The maximum absolute
#' difference
#' in a fit measure for two models
#' to be considered empirically equivalent.
#' It should be a named numeric vector,
#' with the names being an acceptable
#' value of the name of fit measures
#' in [lavaan::fitMeasures()]. For example,
#' the default fit measure is `"chisq"`,
#' model chi-square. If set to
#' `c(chisq = 1e-5, cfi = .01)`, then
#' two models are considered empirical
#' equivalent if their differences on
#' model chi-square and CFI are at most
#' 1e-5 and .01, respectively.
#'
#' @param eq_df_models_args If `partables`
#' is not supplied (`NULL`) but
#' `original_model` is set, [eq_df_models()]
#' will be called to generate the models.
#' This argument
#' must be a named list of additional arguments
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
#' # For illustration, only a few models are generated below,
#' # using drop_k() and add_k manually.
#' # These two functions are usually not used directly.
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
#' # The usual way to use eq_models:
#' # 'parallel' should be set to TRUE or omitted
#' # eq_out_all <- eq_models(
#' #           original_model = fit1
#' #         )
#' # eq_out_all
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
  progress = interactive(),
  tolerance = c(chisq = 1e-5),
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
#'
#' ## `is_eq()`
#'
#' The function [is_eq()] is similar to
#' [eq_models()], but returns a logical
#' vector to indicate which models in
#' `partables` are
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
#' @examples
#'
#' # Using is_eq()
#'
#' is_eq(
#'   partables1,
#'   original_model = fit1,
#'   parallel = FALSE
#' )
#'
#' is_eq(
#'   partables3,
#'   original_model = fit3,
#'   parallel = FALSE
#' )
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
  progress = interactive(),
  tolerance = c(chisq = 1e-5),
  eq_df_models_args = list()
) {

  if (is.null(partables) ||
      is.null(original_model)) {
    stop("is_eq should be used with both partables and original_model set.")
  }

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
  progress = interactive(),
  tolerance = c(chisq = 1e-5),
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
                      FUN = lavaan::sem,
                      model = original_model,
                      do.fit = FALSE,
                      warn = FALSE,
                      fixed.x = FALSE
                    ),
                )
        tmp <- tryCatch(
                  suppressWarnings(do.call(
                    auto_ram,
                    ddd1
                  )),
                  error = function(e) e
                )
        if (inherits(tmp, "error")) {
          tmp2 <- paste0("original_model is not a valid lavaan model. ",
                         "lavaan's error message: ",
                         tmp$message)
          stop(tmp2)
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
                    warn = FALSE,
                    fixed.x = FALSE,
                    representation = attr(dat_original, "fit_rep")
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
                        env_for_call = env_for_update
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

  # ==== Mark the original model ====

  tmp <- match_eq_partables(
          as_eq_partables(sem_out1),
          partables
        )
  if (!is.na(tmp)) {
    attr(partables[[tmp]], "is_original") <- TRUE
    attr(partables[[tmp]], "gen_models_name") <- "original"
  }

  sem_out_df <- unname(lavaan::fitMeasures(sem_out1, "df"))
  # TODO:
  # - Use robust chisq if available
  # sem_out_chisq <- unname(lavaan::fitMeasures(sem_out1, "chisq"))
  sem_out_fms <- lavaan::fitMeasures(sem_out1, names(tolerance))

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
      # chisqs <- eq_chisq(partables)
      fms <- eq_fitMeasures(
               partables,
               fit.measures = names(tolerance),
               output_format = "data.frame"
              )
      fms <- as.matrix(fms)
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
    fms_to_check <- names(tolerance)
    fms <- sapply(
      fits$fit,
      function(x) lavaan::fitMeasures(x, fms_to_check)
    )
    if (is.null(dim(fms))) {
      fms <- rbind(fms)
      rownames(fms) <- fms_to_check
    }
    # chisqs <- sapply(
    #   fits$fit,
    #   function(x) lavaan::fitMeasures(x, "chisq")
    # )
    partables <- add_fit_many(
                  partables,
                  fit_many_out = fits
                )
  }

  # TODO:
  # - Handle nonconvergence cases
  #   Models failed post.check can be kept
  df_eq <- dfs == sem_out_df
  # chisq_eq <- abs(chisqs - sem_out_chisq) <= tolerance
  # i <- df_eq & chisq_eq
  fms_eq <- fms - matrix(rep(sem_out_fms, ncol(fms)),
                         nrow = length(tolerance))
  fms_eq <- abs(fms_eq) <= matrix(rep(tolerance, ncol(fms)),
                                  nrow = length(tolerance))
  fms_eq <- apply(
              fms_eq,
              MARGIN = 2,
              all
            )
  i <- df_eq & fms_eq
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
                   se = se,
                   fixed.x = FALSE,
                   representation = attr(dat_original, "fit_rep"))
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
      fixed.x = FALSE,
      ...
    )
  } else if (fit_case == "user_fit") {
    sem_out <- original_model
  }
  sem_out
}