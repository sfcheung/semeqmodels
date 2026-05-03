#' @title Modified Models
#'
#' @description Generate a list of
#' models a certain number of degrees
#' different from an original model.
#'
#' @name modified_models
NULL

#' @details
#' The function [drop_k()] is
#' a helper
#' to generate a list of models *k* more
#' degrees of freedom different from an original
#' model fitted by `lavaan`, such as
#' [lavaan::sem()].
#'
#' @return
#' The function [drop_k()]
#' returns a list of the class `eq_partables`,
#' a subclass of `partables`. It is
#' an output of [modelbpp::gen_models()],
#' which are simplified versions of the
#' original model, usually with one or
#' more paths removed.
#'
#' @param object The original model. It
#' can be a `lavaan`-class object (the
#' output of [lavaan::lavaan()] or its
#' wrappers, such as [lavaan::sem()]).
#' It can also be a parameter table
#' generated in `lavaan`. If it is
#' a parameter table, dummy data will be
#' created, as it is required by
#' [modelbpp::gen_models()].
#'
#' @param df_change_drop The change in
#' the degrees of freedom when generating
#' simplified models. Default is one.
#' To be passed to [modelbpp::gen_models()].
#'
#' @param loadings_to_exclude_from_drop
#' How factor loadings will be handled.
#' Default is `"all"` and no factor loadings
#' will be dropped.
#' To be passed to [modelbpp::gen_models()].
#' This argument should not be changed.
#' Included for internal use.
#'
#' @param must_not_drop A character vector
#' of parameters that must not be removed,
#' and so will not be modified. To be
#' passed to [modelbpp::gen_models()].
#'
#' @param progress Whether the model
#' generation process will be displayed
#' on screen.
#'
#' @param fit_models Whether the models
#' will be fitted to the data.
#'
#' @param parallel Whether parallel
#' processing will be used when fitting
#' the models. Default is
#' `TRUE`.
#' Passed to [modelbpp::fit_many()].
#'
#' @param ncores The number of CPU cores
#' to be used if `parallel` is `TRUE`.
#' Passed to [modelbpp::fit_many()].
#'
#' @param make_cluster_args An optional
#' named list of arguments to be used
#' in [parallel::makeCluster()].
#' Passed to [modelbpp::fit_many()].
#'
#' @param se Whether standard error will
#' be computed. This argument will be
#' passed to [lavaan::lavaan()].
#' Default is `"none"`, and
#' this setting overrides the setting
#' in `object`. The standard errors are
#' irrelevant in checking whether two
#' models are equivalent.
#'
#' @param drop_original Logical. Whether
#' the original model will dropped from
#' the output. Default is `TRUE`.
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
#' @seealso [modelbpp::gen_models()] for
#' how the model generation is implemented.
#'
#' @examples
#'
#' library(lavaan)
#'
#' mod <-
#' "
#' fx =~ x1 + x2 + x3
#' fm =~ m1 + m2 + m3
#' fy =~ y1 + y2 + y3
#' fm ~ fx
#' fy ~ fm + fx
#' "
#' fit <- sem(
#'           model = mod,
#'           data = data_test_3_factor_3_item
#'         )
#' pt <- parameterTable(fit)
#'
#' # ==== Generate models one-less-df ====
#'
#' # ==== drop_k ====
#'
#' fit_1_more1 <- drop_k(fit)
#' fit_1_more1
#'
#' fit_1_more2 <- drop_k(pt)
#' fit_1_more2
#'
#' @rdname modified_models
#' @export
drop_k <- function(
  object,
  ...,
  loadings_to_exclude_from_drop = "all",
  df_change_drop = 1,
  must_not_drop = NULL,
  se = "none",
  progress = FALSE,
  fit_models = FALSE,
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  drop_original = TRUE
) {

  # - A function to generate a list of 1-more-df models.
  #   - Input:
  #     - A lavaan output.c
  #       - Can also be a parameter table.
  #         - A dummy dataset will be created in this case.
  #     - Relations that will not be removed (and so will not be changed).
  #   - Output:
  #     - A list of parameter table
  #     - For each model, the parameters removed must be stored.
  #       - To prevent reverting to the original model.

  # ==== Process the object ====

  # TODO:
  # - Convert the following to a helper
  if (inherits(object, "lavaan")) {
    # Need this for lavaan::update()
    tmp0 <- stats::getCall(object)
    tmp0$se <- se
    tmp <- lapply(
              tmp0,
              \(x, envir0) eval(x, envir0),
              envir0 = parent.frame()
            )
    tmp <- as.call(tmp)
    tmp[[1]] <- tmp0[[1]]
    object@call <- tmp
    fit <- object
    ptable <- lavaan::parameterTable(fit)
  } else {
    # Assume it is a parameter table
    ptable <- object
    dat <- dummy_data(ptable)
    # Need this for lavaan::update()
    fit <- suppressWarnings(
              do.call(
                lavaan::sem,
                list(
                  model = ptable,
                  data = dat,
                  se = se
                )
              )
            )
  }

  # ==== Generate models ====

  # TODO:
  # - Does not yet work with object = ptable,
  #   due to scoping issue with update()
  out0 <- modelbpp::gen_models(
            sem_out = fit,
            ...,
            loadings_to_exclude_from_drop = "all",
            must_not_drop = must_not_drop,
            df_change_drop = df_change_drop,
            df_change_add = 0,
            progress = progress
          )

  # ==== Drop original ====

  class_out0 <- class(out0)

  if (drop_original) {
    i <- !(names(out0) %in% "original")
    out0 <- out0[i]
  }

  class(out0) <- class_out0

  # Convert to eq_partables

  class(out0) <- c("eq_partables", class(out0))

  # ==== Refit the models ====

  if (fit_models &&
      length(out0) > 0) {
    # Need to suppress warnings because a model
    # may have Heywood cases.
    fit0 <- suppressWarnings(modelbpp::fit_many(
      out0,
      sem_out = fit,
      parallel = parallel,
      ncores = ncores,
      make_cluster_args = make_cluster_args,
      progress = progress
    ))
    out0 <- add_fit_many(
              out0,
              fit0
            )
  }

  out0

}

#' @details
#' The function [add_k()] is a
#' helper
#' to generate a list of models *k* less
#' degrees of freedom different from an
#' original model fitted by `lavaan`,
#' such as [lavaan::sem()].
#'
#' @return
#' The function [add_k()]
#' returns a list of the class `partables`,
#' an output of [modelbpp::gen_models()],
#' which are more complicated versions of the
#' original model, usually with one or
#' more free parameters added.
#'
#' @param ... Optional arguments to be
#' passed to [modelbpp::gen_models()].
#'
#' @param sem_out A `lavaan` object.
#' Not used for now.
#'
#' @param df_change_add The change in
#' the degrees of freedom when adding
#' free parameters.
#' To be passed to [modelbpp::gen_models()].
#' Default to one. Should not be changed
#' except for experimental use of this
#' function.
#'
#' @param must_not_add A character
#' vector of parameters that must not
#' be added. To be passed to [modelbpp::gen_models()].
#'
#' @param ptable_name The name of the
#' original model. Used only if it cannot
#' be generated from `object`.
#'
#' @param remove_zeros Whether a parameter
#' explicitly fixed to `zero` will be
#' removed before generating modified
#' models.
#'
#' @param add_name Whether the name of
#' the original model will be added as
#' a prefix to the names of the generated
#' models.
#'
#' @examples
#'
#' # ==== add_k ====
#'
#' # Remove 'parallel = FALSE' or use 'parallel = TRUE'
#' # to enable parallel processing, which is recommended.
#' fit_1_less <- add_k(
#'                 fit_1_more1[[1]],
#'                 add_name = TRUE,
#'                 parallel = FALSE
#'               )
#'
#' fit_1_less
#'
#' @rdname modified_models
#' @export
add_k <- function(
  object,
  ...,
  sem_out = NULL,
  df_change_add = 1,
  must_not_add = NULL,
  ptable_name = NULL,
  se = "none",
  progress = FALSE,
  fit_models = FALSE,
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  remove_zeros = FALSE,
  add_name = FALSE
) {

  # - A function to generate a list of 1-less-df models.
  #   - Input:
  #     - A lavaan output.
  #       - Can also be a parameter table.
  #         - A dummy dataset will be created in this case.
  #     - Parameters that must not be added.
  #       - To prevent reverting to the original model.
  #       - Can be stored in the attributes 'parameters_dropped'.
  #   - Output
  #     - A list of parameter tables

  # ==== Process the object ====

  # TODO:
  # - Convert the following to a helper
  if (inherits(object, "lavaan")) {
    # Need this for lavaan::update()
    tmp0 <- stats::getCall(object)
    tmp0$se <- se
    tmp <- lapply(
              tmp0,
              \(x, envir0) eval(x),
              envir0 = parent.frame()
            )
    tmp <- as.call(tmp)
    tmp[[1]] <- tmp0[[1]]
    object@call <- tmp
    fit <- object
    ptable <- lavaan::parameterTable(fit)
  } else {
    # Assume it is a parameter table
    ptable <- object
    dat <- dummy_data(ptable)
    # Need this for lavaan::update()
    fit <- suppressWarnings(
              do.call(
                lavaan::sem,
                list(
                  model = ptable,
                  data = dat,
                  se = se
                )
              )
            )
  }

  # ==== Remove coefficients fixed to zero ====

  ptable1 <- remove_dropped(ptable)

  if (remove_zeros) {
    ptable1 <- remove_fixed_zero(ptable)
  }

  # ==== Set must_not_add ====

  pd <- attr(ptable, "parameters_dropped")
  if (!is.null(pd)) {
    ptable_name <- paste0(
                    "drop: ",
                    attr(ptable, "parameters_dropped")
                  )
    must_not_add <- c(must_not_add,
                      pd)
  } else {
    ptable_name <- "original"
  }

  # ==== Fit without removed parameters ====

  # fit_i <- lavaan::sem(
  #             model = ptable1,
  #             data = dat,
  #             test = "standard",
  #             se = "none"
  #           )
  # TODO:
  # - Remove the need to use update
  fit_i <- suppressWarnings(
            lavaan::update(
              object = fit,
              model = ptable1,
              warn = FALSE
            )
          )

  # ==== Generate models ====

  args0 <- list(
    exclude_error_cov = TRUE,
    exclude_x_changed_to_y = FALSE,
    cross_add = NULL,
    df_change_drop = 0,
    df_change_add = df_change_add,
    drop_equivalent_models = FALSE,
    remove_duplicated = TRUE,
    must_not_add = must_not_add,
    # original = ptable_name,
    progress = progress
  )
  args1 <- utils::modifyList(
    args0,
    list(...)
  )
  args1 <- utils::modifyList(
    args1,
    list(sem_out = fit_i)
  )
  # out0 <- do.call(
  #   modelbpp::model_set,
  #   args1
  # )
  out0 <- do.call(
    modelbpp::gen_models,
    args1
  )

  # ==== Fix model names ====

  class_out0 <- class(out0)

  i <- !(names(out0) %in% "original")

  out0 <- out0[i]

  if (add_name) {
    if (length(out0) > 0) {
      names(out0) <- paste0(ptable_name,
                            "; ",
                            names(out0))
    }
  }

  class(out0) <- c("eq_partables", class_out0)

  if (length(out0) == 0) {
    out0 <- NULL
  }

  # ==== Refit the models ====

  if (fit_models &&
      length(out0) > 0) {
    # Need to suppress warnings because a model
    # may have Heywood cases.
    fit0 <- suppressWarnings(modelbpp::fit_many(
      out0,
      sem_out = fit_i,
      parallel = parallel,
      ncores = ncores,
      make_cluster_args = make_cluster_args,
      progress = progress
    ))
    out0 <- add_fit_many(
              out0,
              fit0
            )
  }

  out0

}
