skip("WIP")

library(testthat)
suppressMessages(library(lavaan))

test_that("model differences: class", {

print_model_diff_many <- function(
  x,
  format = "summary",
  ...
) {
  # TODO:
  # - Retrieve the name of `target_model`
  other_names <- names(x)
  for (a in seq_along(x)) {
    cat("\n-------------\n\n")
    cat("Compared with: ",
        other_names[a],
        "\n",
        sep = "")
    print_model_diff(
      x[[a]],
      format = format,
      ...
    )
    flush.console()
  }
}

print_model_diff <- function(
  x,
  format = c("summary", "data.frame"),
  ...
) {
  format <- match.arg(format)
  # TODO:
  # - Retrieve model names
  model_names <- names(x)
  if (is.null(model_names)) {
    model_names <- paste0("[[", seq_along(model_names), "]]")
  }
  out0 <- lapply(
    x,
    partable_to_syntax
  )
  for (a in seq_along(x)) {
    cat("\nModel: ",
        model_names[a],
        "\n",
        sep = "")
    if (format == "data.frame") {
      print(x[[a]])
    }
    if (format == "summary") {
      if (length(out0[[a]]) == 0) {
        cat("No parameter only in this model.\n")
      } else {
        cat(out0[[a]],
            sep = "\n"
            )
      }
    }
  }
}

partable_to_syntax <- function(
  partable
) {
  # Convert a partable to lhs-op-rhs syntax strings
  if (nrow(partable) == 0) {
    return(character(0))
  }
  out0 <- lavaan::lav_partable_labels(partable)
  # TODO:
  # - Handle other rows such as user-defined parameters
  #   and equality constrains
  partable$label <- ""
  fixed <- partable$free == 0
  free <- partable$free > 0
  suffix <- character(length(out0))
  if (any(fixed)) {
    suffix[fixed] <- paste0("fixed to ", partable$start[fixed])
  }
  if (any(free)) {
    suffix[free] <- paste0("free")
  }
  out1 <- paste0(out0, " (", suffix, ")")
  out1
}

mod1 <-
"
m ~ x
y ~ m + x
"

mod2 <-
"
m ~ x
y ~ m
"

mod3 <-
"
y ~ m + x
"

pt1 <- sem(mod1, do.fit = FALSE)
pt2 <- sem(mod2, do.fit = FALSE)
pt3 <- sem(mod3, do.fit = FALSE)

pt <- combine_partables(
  list(
    as_eq_partables(pt1, model_name = "pt1"),
    as_eq_partables(pt2, model_name = "pt2"),
    as_eq_partables(pt3, model_name = "pt3")
  )
)

out <- model_diff(pt[[1]], pt[[2]])
partable_to_syntax(out[[1]])
partable_to_syntax(out[[2]])

print_model_diff(out)

out <- model_diff(pt[[1]], pt[[3]])
partable_to_syntax(out[[1]])
partable_to_syntax(out[[2]])

print_model_diff(out)

out <- model_diff(pt[[2]], pt[[3]])
partable_to_syntax(out[[1]])
partable_to_syntax(out[[2]])

print_model_diff(out)

# model_diff_many

pt_others <- pt[2:3]

out <- model_diff_many(
  pt1,
  pt_others
)

print_model_diff_many(out)
print_model_diff_many(out, format = "data.frame")

})
