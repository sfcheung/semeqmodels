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

## Value

A `lavaan.data.frame` (also a data frame) with parameter identifiers and
the requested aggregate columns:

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
#>    par_label lhs op rhs   mean    min    max n
#> 1      fm.fx  fm  ~  fx  0.207  0.206  0.208 2
#> 2      fm.fx  fx  ~  fm  0.206  0.206  0.206 1
#> 3      fm.fx  fx ~~  fm  0.206  0.206  0.206 1
#> 4      fm.fy  fm  ~  fy  0.320  0.320  0.320 1
#> 5      fm.fy  fy  ~  fm  0.334  0.334  0.334 2
#> 6      fm.fy  fm ~~  fy  0.327  0.327  0.327 1
#> 7      fx.fy  fy  ~  fx -0.041 -0.075 -0.007 4
#> 8      fm.m1  fm =~  m1  0.867  0.867  0.867 4
#> 9      fm.m2  fm =~  m2  0.487  0.487  0.487 4
#> 10     fm.m3  fm =~  m3  0.538  0.538  0.538 4
#> 11     fx.x1  fx =~  x1  0.609  0.609  0.609 4
#> 12     fx.x2  fx =~  x2  0.738  0.738  0.738 4
#> 13     fx.x3  fx =~  x3  0.492  0.492  0.492 4
#> 14     fy.y1  fy =~  y1  0.813  0.813  0.813 4
#> 15     fy.y2  fy =~  y2  0.497  0.497  0.497 4
#> 16     fy.y3  fy =~  y3  0.527  0.527  0.527 4
#> 17     fm.fm  fm r2      0.094  0.043  0.145 2
#> 18     fx.fx  fx r2      0.043  0.043  0.043 1
#> 19     fy.fy  fy r2      0.053  0.000  0.107 4
#> 20     m1.m1  m1 r2      0.751  0.751  0.751 4
#> 21     m2.m2  m2 r2      0.238  0.238  0.238 4
#> 22     m3.m3  m3 r2      0.290  0.290  0.290 4
#> 23     x1.x1  x1 r2      0.370  0.370  0.370 4
#> 24     x2.x2  x2 r2      0.545  0.545  0.545 4
#> 25     x3.x3  x3 r2      0.242  0.242  0.242 4
#> 26     y1.y1  y1 r2      0.662  0.662  0.662 4
#> 27     y2.y2  y2 r2      0.247  0.247  0.247 4
#> 28     y3.y3  y3 r2      0.278  0.278  0.278 4

# Select statistics and use unstandardized estimates
est_summary(
  eq_out_1,
  standardized = FALSE,
  col = c("mean", "n")
)
#>    par_label lhs op rhs   mean n
#> 1      fm.fm  fm ~~  fm  1.252 4
#> 2      fm.fx  fm  ~  fx  0.284 2
#> 3      fm.fx  fx  ~  fm  0.151 1
#> 4      fm.fx  fx ~~  fm  0.198 1
#> 5      fm.fy  fm  ~  fy  0.319 1
#> 6      fm.fy  fy  ~  fm  0.335 2
#> 7      fm.fy  fm ~~  fy  0.422 1
#> 8      fx.fx  fx ~~  fx  0.693 4
#> 9      fx.fy  fy  ~  fx -0.056 4
#> 10     fy.fy  fy ~~  fy  1.253 4
#> 11     m1.m1  m1 ~~  m1  0.434 4
#> 12     m2.m2  m2 ~~  m2  1.137 4
#> 13     m3.m3  m3 ~~  m3  0.848 4
#> 14     x1.x1  x1 ~~  x1  1.192 4
#> 15     x2.x2  x2 ~~  x2  0.683 4
#> 16     x3.x3  x3 ~~  x3  1.180 4
#> 17     y1.y1  y1 ~~  y1  0.676 4
#> 18     y2.y2  y2 ~~  y2  1.057 4
#> 19     y3.y3  y3 ~~  y3  1.003 4
#> 20     fm.m1  fm =~  m1  1.000 4
#> 21     fm.m2  fm =~  m2  0.519 4
#> 22     fm.m3  fm =~  m3  0.513 4
#> 23     fx.x1  fx =~  x1  1.000 4
#> 24     fx.x2  fx =~  x2  1.081 4
#> 25     fx.x3  fx =~  x3  0.733 4
#> 26     fy.y1  fy =~  y1  1.000 4
#> 27     fy.y2  fy =~  y2  0.512 4
#> 28     fy.y3  fy =~  y3  0.540 4

# The usual way to use eq_models:
# 'parallel' should be set to TRUE or omitted
# eq_out_all <- eq_models(
#           original_model = fit1
#         )
# eq_out_all
```
