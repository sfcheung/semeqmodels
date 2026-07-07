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
#' @noRd
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

#' @title Make a Covariance a Curve
#'
#' @description Identify covariances
#' in a `qgraph` object and set
#' their curve values.
#'
#' @details
#' This function can be used to automatically
#' identify covariances in a model, which
#' are represented by bidirectional edges,
#' and set each of the line as a curve.
#'
#' @param qgraph_obj A qgraph object.
#'
#' @param base_curve The curve value used
#' to make a line a curve. The same value
#' used by the argument `curve` of
#' [semPlot::semPaths()].
#'
#' @return An object of the same class
#' as the `qgraph_obj`, with lines of
#' covariances set to curves, if any.
#'
#' @examples
#'
#' library(lavaan)
#'
#' # Model 1
#'
#' mod1 <-
#' "
#' fx =~ x1 + x2 + x3
#' fm =~ m1 + m2 + m3
#' fy =~ y1 + y2 + y3
#' fm ~ fx
#' fy ~ fm + fx
#' "
#' fit1 <- sem(
#'           model = mod1,
#'           data = data_test_3_factor_3_item
#'         )
#' fit1_1_more <- drop_k(fit1)
#' fit1_1_more_1_less <- lapply(
#'   fit1_1_more,
#'   add_k
#' )
#'
#' partables1 <- combine_partables(fit1_1_more_1_less)
#' eq_out_1 <- eq_models(
#'           partables1,
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#'
#' eq_out_1 <- eq_models(
#'           partables1,
#'           original_model = fit1,
#'           parallel = FALSE
#'         )
#'
#' layout_i <- matrix(c(  NA, "fm",  NA,
#'                      "fx",   NA, "fy"),
#'                    ncol = 3,
#'                    nrow = 2,
#'                    byrow = TRUE)
#' layout_i
#' p <- partables_plots(
#'   eq_out_1,
#'   original_model = fit1,
#'   layout = layout_i,
#'   label.cex = 1.5,
#'   sizeLat = 15,
#'   edge.width = 5,
#'   asize = 5,
#'   structural = TRUE,
#'   par_diff_settings = list(
#'             color = "blue",
#'             width = 10
#'           )
#' )
#' plot(
#'   p,
#'   ncol = 3,
#'   nrow = 2
#' )
#'
#' # Process the covariances
#' p2 <- p %p>% auto_curve_covariance()
#' plot(
#'   p2,
#'   ncol = 3,
#'   nrow = 2
#' )
#'
#' @export
auto_curve_covariance <- function(
  qgraph_obj,
  base_curve = 3
) {
  # Check if the qgraph object is provided
  # if (missing(qgraph_obj) || is.null(qgraph_obj)) {
  #   stop("`qgraph_obj` is missing or NULL. Please provide a valid qgraph object.")
  # }
  if (!inherits(qgraph_obj, "qgraph")) {
    stop("`qgraph_obj` is not a qgraph object.")
  }
  # Extract the bidirectional edges from the qgraph object
  edges_bi <- bidirectional_edges(qgraph_obj)
  if (length(edges_bi) == 0) {
    # No bidirectional edges
    return(qgraph_obj)
  }
  qgraph_out <- qgraph_obj
  for (edges_bi_i in edges_bi) {
    qgraph_out <- auto_curve_covariance_i(
      edges_bi_i,
      qgraph_out,
      base_curve = base_curve,
      output = "qgraph"
    )
  }
  qgraph_out
}

#' @noRd
# The version by Wenting
auto_curve_covariance_original <- function(qgraph_obj) {
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

#' @noRd
bidirectional_edges <- function(
  qgraph_obj
) {
  # Extract the bidirectional edges from the qgraph object
  bi_id <- which(qgraph_obj$Edgelist$bidirectional)
  if (length(bi_id) == 0) {
    # No bidirectional edges
    return(list())
  }
  from <- qgraph_obj$Edgelist$from[bi_id]
  to <- qgraph_obj$Edgelist$to[bi_id]
  from_to <- mapply(
      function(x, y) {
        paste0(
          sort(c(x, y)),
          collapse = "_"
        )
      },
      x = from,
      y = to,
      SIMPLIFY = TRUE,
      USE.NAMES = FALSE
    )
  split(bi_id, factor(from_to))
}

#' @noRd
auto_curve_covariance_i <- function(
  edge_ids,
  qgraph_obj,
  base_curve = 1,
  output = c("curve", "qgraph")
) {
  output <- match.arg(output)
  # edge_ids is always a length-2 numeric vector
  # Only the first one is used
  edge_first <- edge_ids[1]
  edge_from <- unname(qgraph_obj$Edgelist$from[edge_first])
  edge_to <- unname(qgraph_obj$Edgelist$to[edge_first])
  layout_obj <- qgraph_obj$layout
  edge_position <- check_position(layout_obj[edge_from, ], layout_obj[edge_to, ])
  out <- switch(
    edge_position,
    left = -1 * base_curve,
    right = base_curve,
    collinear = base_curve
  )
  if (output == "curve") {
    node <- qgraph_obj$graphAttributes$Nodes
    node_names <- names(node$labels)
    if (is.null(node_names)) {
      node_names <- unlist(as.character(node$labels))
    }
    node_from <- node_names[edge_from]
    node_to <- node_names[edge_to]
    names(out) <- paste0(node_from, "~~", node_to)
    return(out)
  }
  if (output == "qgraph") {
    out_graph <- qgraph_obj
    out_graph$graphAttributes$Edges$curve[edge_ids] <- c(out, out)
    return(out_graph)
  }
  # Should never reach here
  out
}
