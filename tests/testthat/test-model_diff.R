library(testthat)
suppressMessages(library(lavaan))

test_that("model differences", {

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
expect_true(has_par_i(
                out[[1]],
                lavParseModelString("y ~ x", as.data.frame. = TRUE)
            ))
expect_true(nrow(out[[2]]) == 0)

out <- model_diff(pt[[1]], pt[[3]],
                  model_x_name = "Model 1")
expect_true(has_pars_i(
                out[[1]],
                list(lavParseModelString("m ~ x", as.data.frame. = TRUE),
                     lavParseModelString("m ~~ m", as.data.frame. = TRUE))
            ))
expect_false(has_pars_i(
                out[[2]],
                list(lavParseModelString("m ~~ x", as.data.frame. = TRUE),
                     lavParseModelString("m ~~ m", as.data.frame. = TRUE))
            ))
expect_all_true(out[[2]]$free == 0)

out <- model_diff(pt[[2]], pt[[3]],
                  model_y_name = "Model2")
expect_true(has_pars_i(
                out[[1]],
                list(lavParseModelString("m ~ x", as.data.frame. = TRUE),
                     lavParseModelString("m ~~ m", as.data.frame. = TRUE))
            ))
expect_true(has_pars_i(
                out[[2]],
                list(lavParseModelString("y ~ x", as.data.frame. = TRUE))
            ))
expect_false(has_pars_i(
                out[[2]],
                list(lavParseModelString("m ~~ x", as.data.frame. = TRUE))
            ))
expect_equal(sum(out[[2]]$free == 0), 2)

# Use lavaan output as input

out2 <- model_diff(pt2, pt3,
                   model_x_name = "Modelx",
                   model_y_name = "Model 2")
expect_equal(as.data.frame(out2[[1]]),
             as.data.frame(out[[1]]),
             ignore_attr = TRUE)
expect_equal(as.data.frame(out2[[2]]),
             as.data.frame(out[[2]]),
             ignore_attr = TRUE)

# model_diff_many

pt_others <- pt[2:3]

out <- model_diff_many(
  pt1,
  pt_others
)

chk1 <- model_diff(pt1, pt2)
chk2 <- model_diff(pt1, pt3)
expect_equal(as.data.frame(out[[1]][[1]]),
             as.data.frame(chk1[[1]]),
             ignore_attr = TRUE)
expect_equal(as.data.frame(out[[2]][[1]]),
             as.data.frame(chk2[[1]]),
             ignore_attr = TRUE)

})
