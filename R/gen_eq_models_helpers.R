#' @noRd
partables_a_to_b <- function(
  object,
  a_to_b = c("same_to_more", "more_to_same"),
  iteration = 1
) {
  # Return a matrix of the relations
  # between models in the i-th iteration.
  # From more-df models to same-df models,
  # or from same-df models to more-df models.
  a_to_b <- match.arg(a_to_b)
  a <- switch(
        a_to_b,
        same_to_more = "same",
        more_to_same = "more"
  )
  b <- switch(
        a_to_b,
        same_to_more = "more",
        more_to_same = "same"
  )
  pts_a_to_b_history <- switch(
      a,
      same = attr(object, "pts_same_to_more_history"),
      more = attr(object, "pts_more_to_same_history")
    )
  pts_a_to_b_history_i <- pts_a_to_b_history[[iteration]]
  pts_a_i <- names(pts_a_to_b_history_i)
  pts_b_i <- unique(unname(unlist(pts_a_to_b_history_i)))
  k_a_i <- length(pts_a_i)
  k_b_i <- length(pts_b_i)
  # TODO:
  # Handle zero row/column
  out0 <- matrix(
            0,
            ncol = k_a_i,
            nrow = k_b_i
          )
  colnames(out0) <- pts_a_i
  rownames(out0) <- pts_b_i
  if (min(dim(out0)) == 0) {
    return(out0)
  }
  for (xx in pts_a_i) {
    yy <- pts_a_to_b_history_i[[xx]]
    if (length(yy) > 0) {
      out0[yy, xx] <- iteration
    }
  }
  out0
}

#' @noRd
inspect_search <- function(
  object,
  a_to_b = c("same_to_more", "more_to_same"),
  iteration = 1,
  what = c("partables", "model_diff")
) {
  # Find the changes in an iteration
  what <- match.arg(what)
  a_to_b <- match.arg(a_to_b)
  a_to_b_matrix <- partables_a_to_b(
    object = object,
    a_to_b = a_to_b,
    iteration = iteration
  )
  # TODO:
  # - Sanity check: zero row/column
  pts_same <- c(object, attr(object, "pts_excluded"))
  pts_same <- rename_to_digest(pts_same)
  pts_more <- attr(object, "pts_more_df_all")
  pts_a <- switch(
    a_to_b,
    "same_to_more" = pts_same,
    "more_to_same" = pts_more
  )
  pts_b <- switch(
    a_to_b,
    "same_to_more" = pts_more,
    "more_to_same" = pts_same
  )
  a_names <- colnames(a_to_b_matrix)
  b_names <- rownames(a_to_b_matrix)
  pts_a_i <- pts_a[a_names]
  pts_b_i <- pts_b[b_names]
  f_model_diff <- function(
    xx,
    pts_a_i,
    pts_b_i,
    a_to_b_matrix) {
    tmp <- a_to_b_matrix[, xx] > 0
    if (isFALSE(any(tmp))) {
      return(NA)
    }
    b_names_xx <- rownames(a_to_b_matrix)[tmp]
    out_i <- model_diff_many(
      target_model = pts_a_i[[xx]],
      other_models = pts_b_i[b_names_xx],
      target_model_name = xx,
      other_models_names = b_names_xx
    )
    out_i
  }
  f_partables <- function(
    xx,
    pts_a_i,
    pts_b_i,
    a_to_b_matrix) {
    tmp <- a_to_b_matrix[, xx] > 0
    if (isFALSE(any(tmp))) {
      return(NA)
    }
    b_names_xx <- rownames(a_to_b_matrix)[tmp]
    out_i <- list(
      from_model = pts_a_i[[xx]],
      to_model = pts_b_i[b_names_xx]
    )
    out_i
  }
  f <- switch(
            what,
            model_diff = f_model_diff,
            partables = f_partables
         )
  out0 <- sapply(
    a_names,
    FUN = f,
    pts_a_i = pts_a_i,
    pts_b_i = pts_b_i,
    a_to_b_matrix = a_to_b_matrix,
    simplify = FALSE,
    USE.NAMES = TRUE
  )
  out0
}
