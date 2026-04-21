# Generate data
library(lavaan)
n <- 200
mod_pop <-
"
fx =~ x1 + .70*x2 + .70*x3
fm =~ m1 + .70*m2 + .70*m3
fy =~ y1 + .70*y2 + .70*y3
fm ~ .30*fx
fy ~ .20*fm + .10*fx
"
data_test_3_factor_3_item <- simulateData(
        model = mod_pop,
        sample.nobs = n,
        seed = 2345
      )
usethis::use_data(data_test_3_factor_3_item, overwrite = TRUE)

