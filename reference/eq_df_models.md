# Generate Models with the Same Degrees of Freedom

Generate a list of models with *df* equal to a fitted model.

## Usage

``` r
eq_df_models(
  sem_out,
  fit_models = FALSE,
  exclude_x_y_ecov = TRUE,
  parallel = FALSE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  progress = TRUE,
  gen_models_progress = FALSE
)
```

## Arguments

- sem_out:

  A `lavaan` object, which is usually the output of
  [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html) or similar
  wrappers. Models will be generated from this model.

- fit_models:

  Whether the models will be fitted to the data. To be passed to
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md).

- exclude_x_y_ecov:

  If `TRUE`, models with one or more covariance between an exogenous
  variable and an error term will be excluded.

- parallel:

  Whether parallel processing will be used. (NOT READY FOR NOW.)

- ncores:

  The number of CPU cores to be used if `parallel` is `TRUE`.

- progress:

  If `TRUE`, messages will be displayed to report the progress of the
  search.

- gen_models_progress:

  If `TRUE`, then progress in each call to
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  or
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  will also be displayed.

## Value

The function `eq_df_models()` returns an `eq_partables` objects, which
is a list of parameter tables.

## Details

The following steps will be repeated to generate models with the same
*df* as a fitted model:

First, models with one less *df* than the fitted model will be
generated, by fixing more free parameter to zero.

Second, for each of the one-more-*df* model, models with one more *df*
will be generated, usually by freeing one fixed parameter to free (e.g.,
adding a regression path). These models will then have the same model
*df* as the fitted model.

These two steps will be repeated until no more new models are found.

## Examples

``` r

# TODO:
# The example is too long to run. Shorten it.

library(lavaan)

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

out <- eq_df_models(
  sem_out = fit1
)
#> Searching for models with one more degree of freedom ...
#> Error in eval(x): object 'mod1' not found
out
#> Error: object 'out' not found
```
