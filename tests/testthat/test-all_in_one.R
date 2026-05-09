skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("gen_eq_models: 3 latent factors", {

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
  # For testing
  # Only useful in this test
  a <- names(object)
  for (j in seq_along(object)) {
    cat(a[j], ":\n")
    pt <- object[[j]]
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
  # For testing
  for (i in seq_along(object)) {
    cat("i: ", i, "\n")
    path_all(object[[i]])
  }
}

# ==== eq_models ====

gen_eq_models <- function(
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

expect_identical(names(out),
                 names(out1))

})
