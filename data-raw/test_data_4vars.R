# Generate data
library(lavaan)
n <- 500
mod_pop_4vars <-
"
fx =~ x1 + .70*x2 + .70*x3
fm1 =~ m1 + .70*m2 + .70*m3
fm2 =~ m4 + .70*m5 + .70*m6
fy =~ y1 + .70*y2 + .70*y3
fm1 ~ .30*fx
fm2 ~ .40*fx
fy ~ .20*fm2 + .10*fx
"
data_test_4_factor_3_item <- simulateData(
        model = mod_pop_4vars,
        sample.nobs = n,
        seed = 2345
      )
usethis::use_data(data_test_4_factor_3_item, overwrite = TRUE)
