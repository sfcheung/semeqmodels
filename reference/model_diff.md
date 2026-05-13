# Compare Two Models

Helper functions to compare two models (parameter tables) and find the
differences.

## Usage

``` r
model_diff(
  model_x,
  model_y,
  cols = c("lhs", "op", "rhs", "block", "group", "free", "ustart", "start"),
  digits = 6
)

model_diff_many(target_model, other_models, ...)
```

## Arguments

- model_x, model_y:

  Parameter tables (from `lavaan`) to be compared. They can also be
  `lavaan` objects, the output of functions such as
  [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html).

- cols:

  The columns to be compared. Two parameters are considered to be
  identical if they are identical on these columns (but see Details on
  how `free`, `ustart`, and `start` are compared).

- digits:

  The number of decimal places used to round `ustart` and `start` when
  doing the comparison.

- target_model:

  A model (`lavaan` parameter table or `lavaan` output) to which other
  models will be compared.

- other_models:

  A list of models (`lavaan` parameter tables o `lavaan` outputs) to be
  compared to the `target_model` by `model_diff()`.

- ...:

  For `model_diff_many()`, these are arguments to be passed to
  `model_diff()`.

## Value

The function `model_diff()` returns a list with two elements,
`model_x_only` and `model_y_only`. Each element is a parameter table
with parameters that are present only in one of the model.

The function `model_diff_many()` return a list of the results of
`model_diff()`.

## Details

The functions `model_diff()` takes two parameter tables and identify the
differences, if any.

The columns compared is specified by the argument `cols`.

For the `free` column, the actual values are ignored. Two parameters are
considered identical if they are both free (have non-zero values on
`free`).

For `ustart` and `start` columns, the values are used only if a
parameter is fixed. If a parameter is free, they will be recoded to `NA`
when being compared.

The function `model_diff_many()` compare one model (`target_model`)
against other models (`other_models`) using `model_diff()`.

## Examples

``` r

library(lavaan)


mod1 <-
"
m ~ x
y ~ m + x
"

mod2 <-
"
m ~ x
y ~ m
"

mod3 <-
"
y ~ m + x
"

pt1 <- parameterTable(sem(mod1, do.fit = FALSE))
pt2 <- parameterTable(sem(mod2, do.fit = FALSE))
pt3 <- parameterTable(sem(mod3, do.fit = FALSE))

model_diff(pt1, pt2)
#> $model_x_only
#>   id lhs op rhs user block group free ustart exo label plabel start est
#> 3  3   y  ~   x    1     1     1    3     NA   0         .p3.     0   0
#> 
#> $model_y_only
#>  [1] id     lhs    op     rhs    user   block  group  free   ustart exo   
#> [11] label  plabel start  est   
#> <0 rows> (or 0-length row.names)
#> 
model_diff(pt1, pt3)
#> $model_x_only
#>   id lhs op rhs user block group free ustart exo label plabel start est
#> 1  1   m  ~   x    1     1     1    1     NA   0         .p1.     0   0
#> 4  4   m ~~   m    0     1     1    4     NA   0         .p4.     1   1
#> 
#> $model_y_only
#>   id lhs op rhs user block group free ustart exo label plabel start est
#> 4  4   m ~~   m    0     1     1    0     NA   1         .p4.     1   1
#> 5  5   m ~~   x    0     1     1    0     NA   1         .p5.     0   0
#> 
model_diff(pt2, pt3)
#> $model_x_only
#>   id lhs op rhs user block group free ustart exo label plabel start est
#> 1  1   m  ~   x    1     1     1    1     NA   0         .p1.     0   0
#> 3  3   m ~~   m    0     1     1    3     NA   0         .p3.     1   1
#> 
#> $model_y_only
#>   id lhs op rhs user block group free ustart exo label plabel start est
#> 2  2   y  ~   x    1     1     1    2     NA   0         .p2.     0   0
#> 4  4   m ~~   m    0     1     1    0     NA   1         .p4.     1   1
#> 5  5   m ~~   x    0     1     1    0     NA   1         .p5.     0   0
#> 
```
