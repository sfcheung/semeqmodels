# Generate Models with the Same Degrees of Freedom

Generate a list of models with *df* equal to a fitted model.

## Usage

``` r
eq_df_models(
  sem_out,
  fit_models = FALSE,
  loadings_to_exclude_from_drop = "all",
  must_not_drop = NULL,
  must_not_add = NULL,
  se = "none",
  exclude_x_y_ecov = TRUE,
  parallel = FALSE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  progress = interactive(),
  gen_models_progress = FALSE,
  short_names = TRUE,
  must_not_add_nil_parameters = TRUE
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

- loadings_to_exclude_from_drop:

  How factor loadings will be handled. Default is `"all"` and no factor
  loadings will be dropped. To be passed to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).
  This argument should not be changed. Included for internal use.

- must_not_drop:

  A character vector of parameters that must not be removed, and so will
  not be modified. To be passed to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).

- must_not_add:

  A character vector of parameters that must not be added. To be passed
  to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).

- se:

  Whether standard error will be computed. This argument will be passed
  to [`lavaan::lavaan()`](https://rdrr.io/pkg/lavaan/man/lavaan.html).
  Default is `"none"`, and this setting overrides the setting in
  `object`. The standard errors are irrelevant in checking whether two
  models are equivalent.

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

- short_names:

  If `TRUE`, then short names (from the digests) will be used to name
  the models. Though these names are not meaning words, the full names
  describing the changes can be very long.

- must_not_add_nil_parameters:

  If `TRUE`, nil parameters (paths or covariances fixed to zer) will not
  be added. They will be added to `must_not_add`.

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
fm ~ fx
fy ~ fm
"
fit1 <- sem(
          model = mod1,
          data = data_test_3obvs,
          fixed.x = FALSE
        )

out <- eq_df_models(
  sem_out = fit1
)
out
#> 
#> Number of models: 9
#> 
#> The models:
#> 
#>   Model   
#> 1 f6b32a38
#> 2 12672c47
#> 3 45f61ccf
#> 4 b0a9b170
#> 5 efdeea17
#> 6 6f675f0c
#> 7 81fb9dff
#> 8 459cd495
#> 9 c02043f3 
#> 
#> NOTE: 'default' names are used. Call 'print()' and add 'names_to_use =
#> "long"' to use the long descriptive names, if available, for the
#> models.
```
