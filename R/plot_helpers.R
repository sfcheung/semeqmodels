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
  # SF: Vectorization
  out <- ifelse(
    cross > 0,
    yes = "left",
    no = ifelse(
          cross < 0,
          yes = "right",
          no = "collinear")
  )
  # SF: No need to throw an error. Just set to NA.
  out[!is.finite(cross)] <- NA
  # out <- if (cross > 0) {
  #   "left"
  # } else if (cross < 0) {
  #   "right"
  # } else if (cross == 0) {
  #   "collinear"
  # } else {
  #   stop("Invalid value of cross: ", cross)
  # }
  out
}

#' @title Determine the curve value for a given qgraph object.
#'
#' @description This function determines the curve
#' value for a given qgraph object. It returns both
#'  curve value and edge IDs which are double-headed arrows.
#'
#' @param qgraph_obj A qgraph object.
#'
#' @return A table contains node names of the bidirectional
#' edges, directions of the origins and the number of such edges.
#' As currently I'm not very sure what kind of data structure we want to retuen.
#'
#'
#' @export
auto_curve_covariance <- function(qgraph_obj) {
  # Check if the qgraph object is provided
  if (missing(qgraph_obj) || is.null(qgraph_obj)) {
    stop("`qgraph_obj` is missing or NULL. Please provide a valid qgraph object.")
  }

  # Extract the bidirectional edges from the qgraph object
  number_of_bidirectional_edges <- which(qgraph_obj$Edgelist$bidirectional)

  # If there are no bidirectional edges, return an empty data frame
  if (length(number_of_bidirectional_edges) == 0) {
      warning("No bidirectional edges found in this qgraph object. ",
              "Returning an empty data frame.")
      return(data.frame(
        from             = character(0),
        to               = character(0),
        origin_direction = character(0),
        edge_ids         = integer(0),
        from_coords      = I(list()),
        to_coords        = I(list()),
        stringsAsFactors = FALSE
      ))
    }

  # Extract the bidirectional edges from the qgraph object
  bi_from <- qgraph_obj$Edgelist$from[number_of_bidirectional_edges]
  bi_to   <- qgraph_obj$Edgelist$to[number_of_bidirectional_edges]

  # Determin the corresponding nodes' coordinates for the bidirectional edges
  bi_from_coords <- qgraph_obj$layout[bi_from, , drop = FALSE]
  bi_to_coords   <- qgraph_obj$layout[bi_to,   , drop = FALSE]

  # Determine the direction of the origin relative to each bidirectional edge
  origin_directions <- check_position(bi_from_coords, bi_to_coords)

  # get the node names for the bidirectional edges
  bi_from_names <- qgraph_obj$Arguments$labels[bi_from]
  bi_to_names   <- qgraph_obj$Arguments$labels[bi_to]

  # Create a data frame to store the results
  # as currently I'm not very sure what kind of data structure we want to retuen.
  result_df <- data.frame(
  from = bi_from_names,
  to   = bi_to_names,
  origin_direction = origin_directions,
  stringsAsFactors = FALSE,
  row.names = NULL,
  edge_ids = number_of_bidirectional_edges
)

result_df$from_coords <- asplit(bi_from_coords, 1)  # split into list by row
result_df$to_coords   <- asplit(bi_to_coords,   1)

result_df
}