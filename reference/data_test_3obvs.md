# Test Dataset: 3obvs

A dataset for testing.

## Usage

``` r
data_test_3obvs
```

## Format

A data frame with 200 rows and 3 variables:

- fx:

  Numeric.

- fm:

  Numeric.

- fy:

  Numeric.

## Examples

``` r
library(lavaan)
data(data_med_3obvs)
#> Warning: data set ‘data_med_3obvs’ not found
mod <-
"
fm ~ fx
fy ~ fm + fx
"
fit <- sem(mod, data_test_3obvs)
parameterEstimates(fit)
#>   lhs op rhs    est    se      z pvalue ci.lower ci.upper
#> 1  fm  ~  fx  0.245 0.066  3.691   0.00    0.115    0.375
#> 2  fy  ~  fm  0.251 0.070  3.586   0.00    0.114    0.389
#> 3  fy  ~  fx -0.002 0.068 -0.026   0.98   -0.135    0.132
#> 4  fm ~~  fm  0.883 0.088 10.000   0.00    0.710    1.056
#> 5  fy ~~  fy  0.868 0.087 10.000   0.00    0.698    1.038
#> 6  fx ~~  fx  1.002 0.000     NA     NA    1.002    1.002
```
