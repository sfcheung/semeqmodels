library(testthat)
suppressMessages(library(lavaan))

skip("Internal: Benchmarking")

test_that("sort_cov_pairs: Compare strategies", {

tmp <- replicate(
  100,
  {x <- pt_list_4_lav; class(x) <- c("partables", class(x)); x},
  simplify = FALSE
)
pt_test <- to_eq_partables_list(tmp)
length(pt_test)
system.time(lapply(pt_test, sort_cov_pairs))
system.time(lapply(pt_test, sort_cov_pairs_old))

expect_identical(sort_cov_pairs_old(pt_test[[5]]),
                 sort_cov_pairs(pt_test[[5]]))

})
