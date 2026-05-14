library(testthat)
suppressMessages(library(lavaan))

test_that("model differences: class", {

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
expect_true(grepl(
              "y~x",
              partable_to_syntax(out[[1]])
            ))
expect_length(partable_to_syntax(out[[2]]), 0)
expect_output(print(out), "Model:")

out <- model_diff(pt[[1]], pt[[3]])
expect_true(grepl(
              "m~x",
              partable_to_syntax(out[[1]])[1]
            ))
expect_true(grepl(
              "m~~m",
              partable_to_syntax(out[[1]])[2]
            ))
expect_true(grepl(
              "m~~m",
              partable_to_syntax(out[[2]])[1]
            ))
expect_true(grepl(
              "m~~x",
              partable_to_syntax(out[[2]])[2]
            ))
expect_output(print(out), "Model:")

out <- model_diff(pt[[2]], pt[[3]])
expect_true(grepl(
              "m~x",
              partable_to_syntax(out[[1]])[1]
            ))
expect_true(grepl(
              "m~~m",
              partable_to_syntax(out[[1]])[2]
            ))
expect_length(partable_to_syntax(out[[2]]), 3)
expect_output(print(out), "Model:")

# model_diff_many

pt_others <- pt[2:3]

out <- model_diff_many(
  pt1,
  pt_others
)

expect_output(print(out), "Models:")
expect_output(print(out, format = "data.frame"),
              "lhs")

})
