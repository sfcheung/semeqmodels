# Summary of Parameter Estimates Across Models

Summarize parameter estimates across a set of equivalent models,
returning the requested aggregate statistics for each parameter.

## Usage

``` r
est_summary(
  object,
  level = 0.95,
  standardized = TRUE,
  trim_par_label = TRUE,
  col = c("mean", "min", "max", "n")
)

# S3 method for class 'est_summary'
print(x, drop_constant = TRUE, constant_tolerance = 5e-05, nd = 3, ...)
```

## Arguments

- object:

  A `partables` object, typically the output of
  [`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md).

- level:

  A confidence level passed to the functions that extract parameter
  estimates from each fitted model. Confidence intervals are not
  included in the summary, so this argument does not affect the returned
  aggregate estimates for now. It may be used in the future.

- standardized:

  Logical; if `TRUE` (the default), summarize fully standardized
  (`std.all`) estimates; if `FALSE`, summarize unstandardized estimates.
  Standardized error variances are reported as R-squares.

- trim_par_label:

  Logical; if `TRUE` (the default), remove the trailing `.1.1` from
  `par_label` when all labels have that suffix (the single-block,
  single-group case). Set to `FALSE` to retain the block and group
  indices.

- col:

  Character vector selecting which aggregate columns to return. Choose
  from `"mean"`, `"min"`, `"max"`, and `"n"`; the default returns all
  four. At least one value is required. The identifier columns are
  always returned.

- x:

  An `est_summary` object, which is the output of `est_summary()`.

- drop_constant:

  Logical. Whether parameters having the nearly the same estimates
  across models will be dropped in the printout.

- constant_tolerance:

  The tolerance used to determine whether a parameter has nearly
  identical estimates across models. If the range is less than or equal
  to this value, the estimates are considered constant.

- nd:

  The number of decimal places to print.

- ...:

  Optional parameters. Not used.

## Value

A `est_summary` object (also a data frame and a `lavaan.data.frame`)
with parameter identifiers and the requested aggregate columns:

- `par_label`: A label based on the two variables, block, and group,
  independent of the operator. For example, `x ~ y`, `y ~ x`, and
  `x ~~ y` share the same label. The block and group suffix is omitted
  by default when all parameters are from block 1 and group 1.

- `lhs`, `op`, `rhs`: The left-hand side, operator, and right-hand side
  of the parameter, as in `lavaan` model syntax. If `op` is `"r2"`,
  `lhs` identifies the variable whose R-square is reported and `rhs` is
  empty.

- `mean`, `min`, `max`: If requested, the arithmetic mean, minimum, and
  maximum of the available estimates for that parameter across models.

- `n`: If requested, the number of non-missing estimates included in the
  aggregates. It can be smaller than the number of models when a
  parameter is absent or has no estimate in some models.

The `print`-method of `est_summary` object returns `x` invisibly. It is
called for its side-effect.

## Details

The input is usually the result of
[`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md),
but any `partables` object containing fitted models can be used.
Estimates are grouped by the parameter label and its `lhs`, `op`, and
`rhs` values, then summarized across models. Parameters without an
estimate in a model are omitted from that model's aggregates.

The function summarizes fully standardized (`std.all`) estimates. For
standardized output, variances (`~~` parameters with the same variable
on both sides) are represented as R-squares (`op = "r2"`), calculated as
one minus the standardized error variance. Set `standardized = FALSE` to
summarize unstandardized estimates instead.

If no model is marked as the original model, the first model in `object`
is used to establish the common parameter ordering.

The `print`-method of `est_summary` object print the results in a
user-friendly way.

## See also

[`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
for the function to generate the models.

## Examples

``` r

library(lavaan)

# For illustration, only a few models are generated below,
# using drop_k() and add_k manually.
# These two functions are usually not used directly.

# Model 1

mod1 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit1 <- sem(
          model = mod1,
          data = data_test_3_factor_3_item
        )
fit1_1_more <- drop_k(fit1)
fit1_1_more_1_less <- lapply(
  fit1_1_more,
  add_k
)

# All equivalent
partables1 <- combine_partables(fit1_1_more_1_less)

eq_out_1 <- eq_models(
          partables1,
          original_model = fit1,
          parallel = FALSE
        )

est_summary(eq_out_1)
#> Number of models: 4
#> Parameter Estimates: Standardized
#> Parameter estimates nearly identical across models are not printed.
#> - 24 such parameter(s).
#> 
#> Variables: fm fx 
#>         Mean    Min    Max N
#> fm~fx  0.207  0.206  0.208 2
#> 
#> Variables: fx fy 
#>         Mean    Min    Max N
#> fy~fx -0.041 -0.075 -0.007 4
#> 
#> R-Squares:
#>         Mean    Min    Max N
#> fm     0.094  0.043  0.145 2
#> fy     0.053  0.000  0.107 4
#> 
#> Notes:
#> - Mean: The mean of estimates.
#> - Min/Max: The minimum/maximum of estimates.
#> - N: The number of models with this parameter (not fixed).

# Select statistics and use unstandardized estimates
est_summary(
  eq_out_1,
  standardized = FALSE,
  col = c("mean", "n")
)
#> The max and min columns are absent drop_constant ignored.
#> Number of models: 4
#> Parameter Estimates: Not standardized
#> 
#> Variables: fm 
#>          Mean N
#> fm~~fm  1.252 4
#> 
#> Variables: fm fx 
#>          Mean N
#> fm~fx   0.284 2
#> fx~fm   0.151 1
#> fx~~fm  0.198 1
#> 
#> Variables: fm fy 
#>          Mean N
#> fm~fy   0.319 1
#> fy~fm   0.335 2
#> fm~~fy  0.422 1
#> 
#> Variables: fx 
#>          Mean N
#> fx~~fx  0.693 4
#> 
#> Variables: fx fy 
#>          Mean N
#> fy~fx  -0.056 4
#> 
#> Variables: fy 
#>          Mean N
#> fy~~fy  1.253 4
#> 
#> Variables: m1 
#>          Mean N
#> m1~~m1  0.434 4
#> 
#> Variables: m2 
#>          Mean N
#> m2~~m2  1.137 4
#> 
#> Variables: m3 
#>          Mean N
#> m3~~m3  0.848 4
#> 
#> Variables: x1 
#>          Mean N
#> x1~~x1  1.192 4
#> 
#> Variables: x2 
#>          Mean N
#> x2~~x2  0.683 4
#> 
#> Variables: x3 
#>          Mean N
#> x3~~x3  1.180 4
#> 
#> Variables: y1 
#>          Mean N
#> y1~~y1  0.676 4
#> 
#> Variables: y2 
#>          Mean N
#> y2~~y2  1.057 4
#> 
#> Variables: y3 
#>          Mean N
#> y3~~y3  1.003 4
#> 
#> Variables: fm m1 
#>          Mean N
#> fm=~m1  1.000 4
#> 
#> Variables: fm m2 
#>          Mean N
#> fm=~m2  0.519 4
#> 
#> Variables: fm m3 
#>          Mean N
#> fm=~m3  0.513 4
#> 
#> Variables: fx x1 
#>          Mean N
#> fx=~x1  1.000 4
#> 
#> Variables: fx x2 
#>          Mean N
#> fx=~x2  1.081 4
#> 
#> Variables: fx x3 
#>          Mean N
#> fx=~x3  0.733 4
#> 
#> Variables: fy y1 
#>          Mean N
#> fy=~y1  1.000 4
#> 
#> Variables: fy y2 
#>          Mean N
#> fy=~y2  0.512 4
#> 
#> Variables: fy y3 
#>          Mean N
#> fy=~y3  0.540 4
#> 
#> Notes:
#> - Mean: The mean of estimates.
#> - N: The number of models with this parameter (not fixed).

# The usual way to use eq_models:
# 'parallel' should be set to TRUE or omitted
# eq_out_all <- eq_models(
#           original_model = fit1
#         )
# eq_out_all
```
