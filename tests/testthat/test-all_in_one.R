skip("WIP")

library(testthat)
suppressMessages(library(lavaan))

test_that("+/- df: fit_models", {

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3_factor_3_item
        ))
pt <- parameterTable(fit)

path_all <- function(
  object
) {
  for (pt in object) {
    i1 <- pt$lhs %in% c("fx", "fm", "fy")
    i2 <- pt$rhs %in% c("fx", "fm", "fy")
    i3 <- pt$lhs != pt$rhs
    i <- i1 & i2 & i3
    print(pt[i, c("lhs", "op", "rhs", "start", "est", "free")])
    flush.console()
  }
}

path_all_list <- function(
  object
) {
  for (i in seq_along(object)) {
    cat("i: ", i, "\n")
    path_all(object[[i]])
  }
}

# ==== eq_models ====

gen_eq_models <- function(
  sem_out,
  parallel = FALSE,
  progress = TRUE
) {
  # Add other arguments later

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
    out_drop_i <- lapply(
      out_i,
      drop_k,
      sem_out = sem_out0,
      fit_models = TRUE,
      parallel = FALSE,
      progress = progress
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
    out_add_i <- lapply(
      out_drop_i,
      add_k,
      sem_out = sem_out,
      fit_models = TRUE,
      parallel = FALSE,
      progress = progress
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
      cat(k_diff, "new model(s); ",
          k_new, "model(s) found\n")
    }
  }
  # TODO:
  # - Should sem_out be excluded?
  out
}

out <- gen_eq_models(
  sem_out = fit,
  parallel = FALSE
)
out

out1 <- empirical_eq(
          out,
          original_model = fit,
          parallel = FALSE,
          progress = !is_testing()
        )
out1
# saveRDS(out1, "C:/temp/3var_models.rds")

# TO PROCESS

# ==== Test: drop_k ====

fit_1_more1_with_fit <- drop_k(fit,
              fit_models = TRUE,
              parallel = FALSE)
expect_s4_class(attr(fit_1_more1_with_fit[[1]], "fit"),
                "lavaan")
expect_equal(
  lavInspect(eq_fits(fit_1_more1_with_fit)[[1]], "sampstat")$cov,
  lavInspect(fit, "sampstat")$cov
)

# ==== Test: add_k ====

fit_1_less_with_fit <- add_k(
                fit_1_more1_with_fit[[1]],
                sem_out = fit,
                add_name = TRUE,
                fit_models = TRUE,
                parallel = FALSE
              )
expect_s4_class(attr(fit_1_less_with_fit[[1]], "fit"),
                "lavaan")
expect_equal(
  lavInspect(eq_fits(fit_1_less_with_fit)[[1]], "sampstat")$cov,
  lavInspect(fit, "sampstat")$cov
)

# ==== Test: drop_k: Using add_k output ====

fit_1_more1_from_less1_with_fit <- drop_k(
              fit_1_less_with_fit[[1]],
              sem_out = fit,
              fit_models = TRUE,
              parallel = FALSE)
expect_s4_class(attr(fit_1_more1_from_less1_with_fit[[1]], "fit"),
                "lavaan")
expect_equal(
  lavInspect(eq_fits(fit_1_more1_from_less1_with_fit)[[1]], "sampstat")$cov,
  lavInspect(fit, "sampstat")$cov
)

})
