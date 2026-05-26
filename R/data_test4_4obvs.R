#' @title Test Dataset: 4obvs
#'
#' @description A dataset for testing.
#'
#' @format A data frame with 500 rows
#' and 4 variables:
#' \describe{
#'   \item{fx}{Numeric.}
#'   \item{fm1}{Numeric.}
#'   \item{fm2}{Numeric.}
#'   \item{fy}{Numeric.}
#' }
#'
#' @examples
#' library(lavaan)
#' data(data_med_4vars)
#' mod <-
#' "
#' fm1 ~~ fm2
#' fm1 ~ fx
#' fm2 ~ fx
#' fy ~ fm1 + fm2 + fx
#' "
#' fit <- sem(mod, data_test_4obvs)
#' parameterEstimates(fit)
"data_test_4obvs"
