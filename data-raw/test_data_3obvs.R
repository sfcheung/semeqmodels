# Generate data with 3 observed variable
library(lavaan)
n <- 200
mod_pop_3obvs <-
"
fm ~ .30*fx
fy ~ .20*fm + .10*fx
"
data_test_3obvs <- simulateData(
        model = mod_pop_3obvs,
        sample.nobs = n,
        seed = 2345
      )
usethis::use_data(data_test_3obvs, overwrite = TRUE)
