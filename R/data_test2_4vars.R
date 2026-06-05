#' @title Test Dataset: 4-Factor-3-Item
#'
#' @description A dataset for testing.
#'
#' @format A data frame with 500 rows
#' and 4 variables:
#' \describe{
#'   \item{x1}{Numeric.}
#'   \item{x2}{Numeric.}
#'   \item{x3}{Numeric.}
#'   \item{m1}{Numeric.}
#'   \item{m2}{Numeric.}
#'   \item{m3}{Numeric.}
#'   \item{m4}{Numeric.}
#'   \item{m5}{Numeric.}
#'   \item{m6}{Numeric.}
#'   \item{y1}{Numeric.}
#'   \item{y2}{Numeric.}
#'   \item{y3}{Numeric.}
#' }
#'
#' @examples
#' library(lavaan)
#' data(data_test_4_factor_3_item)
#' mod <-
#' "
#' fx =~ x1 + x2 + x3
#' fm1 =~ m1 + m2 + m3
#' fm2 =~ m4 + m5 + m6
#' fy =~ y1 + y2 + y3
#' "
#' fit <- sem(mod, data_test_4_factor_3_item)
#' parameterEstimates(fit)
"data_test_4_factor_3_item"
