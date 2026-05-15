# Generate data with 4 observed variable
library(lavaan)
n <- 500
mod_pop_4obvs <-
"
fm1 ~ .30*fx
fm2 ~ .40*fx
fy ~ .20*fm2 + .10*fx
"
data_test_4obvs <- simulateData(
        model = mod_pop_4obvs,
        sample.nobs = n,
        seed = 2345
      )
usethis::use_data(data_test_4obvs, overwrite = TRUE)
