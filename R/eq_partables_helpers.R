#' @noRd
add_fit_many <- function(
  object,
  fit_many_out
) {
  # Add fit_many() outputs to each of the models
  for (i in seq_along(object)) {
    attr(object[[i]], "fit") <- fit_many_out$fit[[i]]
    attr(object[[i]], "converged") <- fit_many_out$converged[[i]]
    attr(object[[i]], "post_check") <- fit_many_out$post_check[[i]]
    attr(object[[i]], "model_df") <- fit_many_out$model_df[[i]]
  }
  object
}

#' @noRd
is_partable <- function(
  object,
  colchk = c("id", "lhs", "op", "rhs")
) {
  # Check if a data frame is "likely" a
  # lavaan parameter table
  # Use only column names
  # Not a 100% correct check but good enough
  if (!is.data.frame(object)) {
    return(FALSE)
  }
  col0 <- colnames(object)
  if (all(colchk %in% col0)) {
    return(TRUE)
  }
  return(FALSE)
}
