skip_on_cran()

library(testthat)
suppressMessages(library(lavaan))

test_that("Set original model", {

mod <-
"
fm ~ fx
fy ~ fm + fx
"
out1 <- eq_models(
  original_model = mod,
  progress = !is_testing(),
  parallel = FALSE
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
  asize = 5
)
expect_s3_class(
  attr(p1, "original_model")[[1]],
  "qgraph"
)
if (!is_testing()) {
plot(
  p1,
  ncol = 4,
  nrow = 4
)
}

})
