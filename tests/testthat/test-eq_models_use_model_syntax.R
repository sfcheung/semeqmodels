skip("WIP")

library(testthat)
suppressMessages(library(lavaan))

test_that("Set original model", {

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
out1 <- eq_models(
  original_model = mod,
  progress = !is_testing()
)

fit <- sem(
  mod,
  do.fit = FALSE
)
tmp <- dummy_data(parameterTable(fit))
fit <- sem(
  mod,
  data = tmp
)
out2 <- eq_models(
  original_model = fit,
  progress = !is_testing()
)

layout_i <- matrix(c(  NA, "fm",  NA,
                     "fx",   NA, "fy"),
                   ncol = 3,
                   nrow = 2,
                   byrow = TRUE)
p1 <- partables_plots(
  out1,
  layout = layout_i,
  label.cex = 1.5,
  sizeLat = 15,
  edge.width = 5,
  asize = 5,
  structural = TRUE
)
if (!is_testing()) {
plot(
  p1,
  ncol = 4,
  nrow = 4
)
}
p2 <- partables_plots(
  out2,
  layout = layout_i,
  label.cex = 1.5,
  sizeLat = 15,
  edge.width = 5,
  asize = 5,
  structural = TRUE
)
if (!is_testing()) {
plot(
  p2,
  ncol = 4,
  nrow = 4
)
}

})
