# Compare Two Models

Helper functions to compare two models (parameter tables) and find the
differences.

## Usage

``` r
model_diff(
  model_x,
  model_y,
  cols = getOption("semeqmodels.digest_cols", default = c("lhs", "op", "rhs", "block",
    "group", "free", "ustart", "start")),
  digits = 6,
  model_x_name = NULL,
  model_y_name = NULL
)

model_diff_many(
  target_model,
  other_models,
  ...,
  target_model_name = NULL,
  other_models_names = NULL
)

model_diff.print(x, format = c("summary", "data.frame"), ...)

# S3 method for class 'model_diff'
print(x, format = c("summary", "data.frame"), ...)

# S3 method for class 'model_diff_many'
print(x, format = "summary", ...)
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

- model_x_name, model_y_name:

  The names of the models used in the output. If `NULL`, the name will
  be generated automatically.

- target_model:

  A model (`lavaan` parameter table or `lavaan` output) to which other
  models will be compared.

- other_models:

  A list of models (`lavaan` parameter tables o `lavaan` outputs) to be
  compared to the `target_model` by `model_diff()`.

- ...:

  For `model_diff_many()`, these are arguments to be passed to
  `model_diff()`. For the `print`-methods, these arguments are ignored.

- target_model_name, other_models_names:

  Names of the models, to be passed to `model_diff()`. If `NULL`, they
  will be generated automatically.

- x:

  The object to be printed.

- format:

  The format of the output when printing model differences. Either a
  user-friendly summary (`"summary"`) or the original parameter table
  (`"data.frame"`).

## Value

The function `model_diff()` returns a list with two elements,
`model_x_only` and `model_y_only`. Each element is a parameter table
with parameters that are present only in one of the model.

The function `model_diff_many()` return a list of the results of
`model_diff()`.

The `print`-method of the output of `model_diff()` returns `x`
invisibly. It is called for its side-effect.

The `print`-method of the output of `model_diff()` returns `x`
invisibly. It is called for its side-effect.

The `print`-method of the output of `model_diff_many()` returns `x`
invisibly. It is called for its side-effect.

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

The `print` method of the output of `model_diff()` prints the
differences between models in a user-friendly way.

The `print` method of the output of `model_diff()` prints the
differences between models in a user-friendly way.

The `print` method of the output of `model_diff_many()` prints the list
of model differences in a user-friendly way.

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
#> 
#> Model: pt1
#> y~x (free)
#> 
#> Model: pt2
#> No parameter only in this model.
model_diff(pt1, pt3)
#> 
#> Model: pt1
#> m~x (free)
#> m~~m (free)
#> 
#> Model: pt3
#> m~~m (fixed to 1)
#> m~~x (fixed to 0)
model_diff(pt2, pt3)
#> 
#> Model: pt2
#> m~x (free)
#> m~~m (free)
#> 
#> Model: pt3
#> y~x (free)
#> m~~m (fixed to 1)
#> m~~x (fixed to 0)
```
