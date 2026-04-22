library(testthat)
library(lavaan)

test_that("+/- df", {


# - A function to generate a list of 1-more-df models.
#   - Input:
#     - A lavaan output.
#       - Can also be a parameter table.
#         - A dummy dataset will be created in this case.
#     - Relations that will not be removed (and so will not be changed).
#   - Output:
#     - A list of parameter table
#     - For each model, the parameters removed must be stored.
#       - To prevent reverting to the original model.

get_drop_i <- function(
  object,
  must_not_drop = NULL,
  progress = FALSE,
  drop_original = TRUE
) {

  # ==== Process the object ====

  # TODO:
  # - Convert the following to a helper
  if (inherits(object, "lavaan")) {
    # Need this for lavaan::update()
    tmp0 <- stats::getCall(object)
    tmp <- lapply(tmp0, \(x) eval(x))
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
                  se = "none"
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
            loadings_to_exclude_from_drop = "all",
            must_not_drop = must_not_drop,
            df_change_drop = 1,
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

  out0

}

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

get_add_i <- function(
  object,
  ...,
  sem_out = NULL,
  must_not_add = NULL,
  ptable_name = NULL,
  progress = FALSE,
  remove_zeros = FALSE,
  add_name = FALSE
) {

  # ==== Process the object ====

  # TODO:
  # - Convert the following to a helper
  if (inherits(object, "lavaan")) {
    # Need this for lavaan::update()
    tmp0 <- stats::getCall(object)
    tmp <- lapply(tmp0, \(x) eval(x))
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
                  se = "none"
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
    df_change_add = 1,
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

  class(out0) <- class_out0

  if (length(out0) == 0) {
    out0 <- NULL
  }

  out0

}

# Remove parameter(s) fixed to zero when
# generated from the original model
remove_dropped <- function(
  ptable
) {
  ids <- attr(ptable, "ids_dropped")
  if (length(ids) > 0) {
    ptable <- ptable[-ids, ]
  }
  ptable
}

# Remove parameter(s) fixed to zero
remove_fixed_zero <- function(
  ptable,
  op = c("~~", "~")
) {
  i_free <- ptable$free == 0
  i_zero <- ptable$start == 0
  i_op <- ptable$op %in% op
  i <- i_free & i_zero & i_op
  out <- ptable
  out[!i, ]
}

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

dummy_data <- function(
  ptable,
  n = NULL
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
    n <- p * 20
  }
  out <- suppressWarnings(
            lavaan::simulateData(
              model = ptable,
              sample.nobs = n
            )
          )
  out
}

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- sem(
          model = mod,
          data = data_test_3_factor_3_item
        )
pt <- parameterTable(fit)

# ==== Test: get_drop_i ====

fit_1_more1 <- get_drop_i(fit)

fit_1_more2 <- get_drop_i(pt)

expect_setequal(names(fit_1_more1),
                names(fit_1_more2))

# ==== Test: get_add_i ====

fit_1_less <- get_add_i(
                fit_1_more1[[1]],
                add_name = TRUE
              )

fit_1_more_1_less <- lapply(
  fit_1_more1,
  get_add_i
)

fit_1_more_1_less <- unlist(
    fit_1_more_1_less,
    recursive = FALSE
  )

class(fit_1_more_1_less) <- c("partables", class(fit_1_more_1_less))

tmp <- sapply(
        fit_1_more_1_less,
        attr,
        which = "parameters_added",
        USE.NAMES = FALSE
      )

chk <- c(
  "fx~~fm",
  "fx~fm",
  "fm~~fy",
  "fm~fy"
)
expect_setequal(tmp,
                chk)

})
