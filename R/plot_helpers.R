#' @title Determine Which Side of a Vector
#' the Origin Is On
#'
#' @description Given coordinates of two
#' points A (`from`) and B (`to`) defining
#' a directed vector from A to B, determine
#' whether the origin (0, 0) is to the
#' "left" or "right" of that vector.
#'
#' @details
#' The function uses the cross product
#' of the position vectors to determine
#' the side. Specifically, it computes
#' `Ax * By - Ay * Bx`. If this value
#' is positive, the origin is to the
#' "left"; if negative, the origin is
#' to the "right"; if zero, the origin
#' is on the line defined by the vector.
#'
#' @param from A numeric vector of length 2
#' (x, y coordinates of the starting point),
#' or a two-column matrix where each row
#' is a starting point.
#'
#' @param to A numeric vector of length 2
#' (x, y coordinates of the ending point),
#' or a two-column matrix where each row
#' is an ending point.
#'
#' @return A character vector with values
#' `"left"`, `"right"`, or `"collinear"`.
#'
#' @examples
#' p1 <- c(.5, .5)
#' p2 <- c(.75, -.5)
#' p3 <- c(-.5, .5)
#' p4 <- c(-.25, -.75)
#'
#' check_position(p1, p2)
#' # "right"
#'
#' check_position(p3, p4)
#' # "left"
#'
#' # Vectorized
#' check_position(rbind(p1, p3), rbind(p2, p4))
#' # c("right", "left")
#'
#' @export
check_position <- function(from, to) {
  if (is.null(dim(from))) {
    from <- matrix(from, nrow = 1)
  }
  if (is.null(dim(to))) {
    to <- matrix(to, nrow = 1)
  }
  # Cross product: Bx * Ay - By * Ax
  cross <- from[, 1] * to[, 2] - from[, 2] * to[, 1]
  out <- if (cross > 0) {
  "left"
} else if (cross < 0) {
  "right"
} else if (cross == 0) {
  "collinear"
} else {
  stop("Invalid value of cross: ", cross)
}
  out
}
