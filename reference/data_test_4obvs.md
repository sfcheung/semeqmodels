# Test Dataset: 4obvs

A dataset for testing.

## Usage

``` r
data_test_4obvs
```

## Format

A data frame with 500 rows and 4 variables:

- fx:

  Numeric.

- fm1:

  Numeric.

- fm2:

  Numeric.

- fy:

  Numeric.

## Examples

``` r
library(lavaan)
data(data_med_4vars)
#> Warning: data set ‘data_med_4vars’ not found
mod <-
"
fm1 ~~ fm2
fm1 ~ fx
fm2 ~ fx
fy ~ fm1 + fm2 + fx
"
fit <- sem(mod, data_test_4obvs)
parameterEstimates(fit)
#>    lhs op rhs    est    se      z pvalue ci.lower ci.upper
#> 1  fm1 ~~ fm2  0.052 0.042  1.237  0.216   -0.030    0.134
#> 2  fm1  ~  fx  0.311 0.045  6.899  0.000    0.223    0.400
#> 3  fm2  ~  fx  0.418 0.045  9.219  0.000    0.329    0.506
#> 4   fy  ~ fm1 -0.073 0.047 -1.569  0.117   -0.165    0.018
#> 5   fy  ~ fm2  0.249 0.046  5.359  0.000    0.158    0.340
#> 6   fy  ~  fx  0.063 0.053  1.201  0.230   -0.040    0.166
#> 7  fm1 ~~ fm1  0.931 0.059 15.811  0.000    0.816    1.047
#> 8  fm2 ~~ fm2  0.939 0.059 15.811  0.000    0.823    1.056
#> 9   fy ~~  fy  1.009 0.064 15.811  0.000    0.884    1.134
#> 10  fx ~~  fx  0.915 0.000     NA     NA    0.915    0.915
```
