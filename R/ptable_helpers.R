#' @noRd
sort_ptable <- function(
  ptable,
  cols = c("lhs", "op", "rhs", "block", "group", "free", "ustart")
) {
  # Sort a parameter table
  # For comparing different tables

  # TODO:
  # - Handle labels and constraint
  # Sort rows in a parameter table.
  i <- do.call(
            order,
            ptable[, cols]
          )
  out0 <- ptable[i, ]
  out0
}

digest_ptable <- function(
  ptable,
  cols = c("lhs", "op", "rhs", "block", "group", "free", "ustart", "start"),
  digits = 6,
  ...
) {

  # Compute a value using a hash function.
  # For comparing tables

  # TODO:
  # - Handle labels and constraint
  out0 <- ptable[, cols]
  out0 <- as.data.frame(out0)
  row.names(out0) <- NULL
  i_free <- which(out0$free > 0)
  out0$free[i_free] <- seq_along(i_free)
  out0$start <- round(out0$start, digits = digits)
  do.call(
      digest::digest,
      list(object = out0,
          ...
      )
    )
}

add_digest <- function(
  ptable,
  args_sort_ptable = list(),
  args_digest_ptable = list()
) {

  # Add a digest to a parameter table
  # Return the parameter table with
  # the value added as the attribute "digest"

  out0 <- do.call(
            sort_ptable,
            c(list(ptable = ptable),
              args_sort_ptable)
          )
  out1 <- do.call(
            digest_ptable,
            c(list(ptable = out0),
              args_digest_ptable)
          )
  attr(ptable, "digest") <- out1
  ptable
}

get_digest <- function(
  ptable,
  args_sort_ptable = list(),
  args_digest_ptable = list()
) {

  # Retrieve the digest value, if available.
  # If not available, compute it.

  out <- attr(ptable, "digest")
  if (is.null(out)) {
    out0 <- do.call(
            add_digest,
            list(ptable = ptable,
                 args_sort_ptable = args_sort_ptable,
                 args_digest_ptable = args_digest_ptable)
          )
    out <- attr(out0, "digest")
  }
  out
}

#' @noRd
combine_ptables <- function(
  object_list,
  drop_duplicated = TRUE
) {
  # Combine a list of partables objects
  out0 <- unlist(
    object_list,
    recursive = FALSE
  )
  if (drop_duplicated) {
    out0_digest <- lapply(
      out0,
      add_digest
    )
    i <- sapply(
            out0_digest,
            get_digest
          )
    out0 <- out0[!duplicated(i)]
  }
  tmp <- class(out0)
  tmp <- tmp[tmp != "partables"]
  tmp <- c("partables", tmp)
  class(out0) <- tmp
  out0
}
