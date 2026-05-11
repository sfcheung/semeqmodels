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
