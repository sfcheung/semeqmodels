library(testthat)
suppressMessages(library(lavaan))

skip("Internal: Benchmarking")

test_that("remove_x_y_ecov: Compare strategies", {

tmp <- replicate(
  5,
  {x <- pt_list_4_lav; class(x) <- c("partables", class(x)); x},
  simplify = FALSE
)
pt_test <- to_eq_partables_list(tmp)
fit_test <- lapply(
  pt_test,
  \(x) auto_ram(FUN = lavaan::sem, x, do.fit = FALSE, fixed.x = FALSE)
)
length(pt_test)
tmp0 <-  auto_ram(
      FUN = lavaan::sem,
      pt_test[[1]],
      do.fit = FALSE,
      fixed.x = FALSE
    )
tmp1 <-  auto_ram(
      FUN = lavaan::sem,
      pt_test[[18]],
      do.fit = FALSE,
      fixed.x = FALSE
    )
x_y_pairs(tmp0)
x_y_pairs(tmp1)
x_y_pairs(pt_test[[1]])
x_y_pairs(pt_test[[18]])
x_y_pairs_old(pt_test[[1]])
x_y_pairs_old(pt_test[[18]])

system.time(lapply(pt_test, x_y_pairs))
system.time(lapply(fit_test, x_y_pairs_new))

has_x_y_ecov2(pt_test[[18]])
system.time(lapply(pt_test, has_x_y_ecov2))
system.time(lapply(pt_test, has_x_y_ecov2_old))

# TO DELETE

# library(profvis)
# p_out <- profvis(lapply(pt_test, x_y_pairs))
# p_out
# p_out <- profvis(lapply(fit_test, x_y_pairs))
# p_out
# p_out <- profvis(lapply(pt_test, has_x_y_ecov2))
# p_out
# p_out <- profvis(lapply(pt_test, has_x_y_ecov2_old))
# p_out


})
