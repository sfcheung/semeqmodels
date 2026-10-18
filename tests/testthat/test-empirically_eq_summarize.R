skip("WIP")

library(testthat)
suppressMessages(library(lavaan))

test_that("Summarize models", {

# ==== Models ====

# Model 1

mod1 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit1 <- do.call(
          sem,
          list(
            model = mod1,
            data = data_test_3_factor_3_item
          )
        )
pt1 <- parameterTable(fit1)

# Only original_model: A lavaan object

set.seed(1)
eq_out_1 <- eq_models(
          original_model = fit1,
          se = "standard",
          parallel = FALSE,
          progress = !is_testing()
        )
set.seed(1)
eq_out_1b <- eq_models(
          original_model = fit1,
          se = "standard",
          parallel = FALSE,
          progress = !is_testing(),
          passes = 2
        )

summary.eq_partables <- function(
  object,
  ...
) {
  object1 <- common_order(object)
  i_original <- which_original_model(object)
  has_original <- !is.na(unname(i_original))
  if (!has_original) {
    # Let the first model be the original
    i_original <- 1
  }
  model_original <- object1[[i_original]]
  original_order <- order(model_original$id)
  # Common order
  object1 <- lapply(
    object1,
    \(x) {x[original_order, ]}
  )
  fit_original <- attr(model_original, "fit")
  lavaan::lavParameterEstimates(fit_original)
}

common_order <- function(
  pt_list
) {
  sort_by <- c("lhs", "op", "rhs", "block", "group")
  lorbg <- lapply(
    pt_list,
    \(x) {
      x$op_original <- x$op
      x$op <- "~~"
      x <- sort_cov_pairs(x)
      out <- sort_partable(
        x,
        sort_by
      )
      out$par_label <- paste0(
        out$lhs,
        ".",
        out$rhs,
        ".",
        out$bloc,
        ".",
        out$group
      )
      out
    }
  )
  label_common <- lapply(
    lorbg,
    \(x) x$par_label
  )
  label_common <- unname(unique(unlist(label_common)))
  lorbg0 <- lapply(
    lorbg,
    \(x) {
      i <- which(colnames(x) %in% c("lhs", "rhs", "block", "group", "par_label"))
      x[, -i] <- NA
      x
    }
  )
  lorbg_common <- Reduce(
    function(x, y) {
      merge(x, y,
            all = TRUE)
    },
    lorbg0
  )
  lorbg <- lapply(
    lorbg,
    \(x) {
      par_no <- setdiff(
        label_common, x$par_label
      )
      if (length(par_no) == 0L) {
        return(x)
      }
      n_i <- length(par_no)
      i <- lorbg_common$par_label %in% par_no
      tmp <- lorbg_common[i, , drop = FALSE]
      x <- rbind(x, tmp)
      x[sort(x$par_label), , drop = FALSE]
    }
  )
  # tmp <- sapply(
  #   lorbg,
  #   \(x) x$par_label
  # )
  # apply(
  #   tmp,
  #   MARGIN = 1,
  #   \(x) {identical(length(unique(x)), 1L)}
  # )
  lorbg
}



})
