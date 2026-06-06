#' @title Test Dataset: 3 Observed Variables
#'
#' @description A dataset for testing.
#'
#' @format A data frame with 200 rows
#' and 3 variables:
#' \describe{
#'   \item{fx}{Numeric.}
#'   \item{fm}{Numeric.}
#'   \item{fy}{Numeric.}
#' }
#'
#' @examples
#' library(lavaan)
#' data(data_test_3obvs)
#' mod <-
#' "
#' fm ~ fx
#' fy ~ fm + fx
#' "
#' fit <- sem(mod, data_test_3obvs)
#' parameterEstimates(fit)
"data_test_3obvs"
