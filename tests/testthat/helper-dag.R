skip_if_not_installed("dagitty")

library(dagitty)

dag_to_lavaan <- function(
  object
) {
  # Only for directed paths
  x2y <- dagitty::edges(object)
  out0 <- apply(
    x2y[, c("w", "v")],
    MARGIN = 1,
    \(x) paste0(x, collapse = "~")
  )
  out1 <- paste0(
    out0,
    collapse = "\n"
  )
  out1
}
