# Empirical Equivalent Models

Identify model(s) in a list of models (parameter tables) empirically
equivalent to the original model.

## Usage

``` r
eq_models(
  partables = NULL,
  original_model = NULL,
  ...,
  se = "none",
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  progress = interactive(),
  tolerance = 1e-05,
  eq_df_models_args = list()
)

is_eq(
  partables = NULL,
  original_model = NULL,
  ...,
  se = "none",
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  progress = interactive(),
  tolerance = 1e-05,
  eq_df_models_args = list()
)
```

## Arguments

- partables:

  A list of the class `partables`. If `NULL`, `eq_models()` will try to
  generate the models by calling
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  on the argument of `original_model`. For `[is_eq()]`, this argument
  cannot be `NULL`.

- original_model:

  The original model, fitted by
  [`lavaan::lavaan()`](https://rdrr.io/pkg/lavaan/man/lavaan.html) or
  its wrapper, such as
  [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html). If it is a
  `lavaan` parameter table (the output of
  [`lavaan::parameterTable()`](https://rdrr.io/pkg/lavaan/man/parTable.html)),
  data will be simulated to fit the model. If it is `NULL`, then the
  first model in `partables` will be used.

- ...:

  Optional arguments to be used when fitting models to the data, to be
  passed to [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html).
  Usually can be omitted.

- se:

  How standard errors are to be computed. To be passed to
  [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html). The
  default, `"none"`, is sufficient because the standard errors are not
  needed to check whether two models are empirically equivalent.

- parallel:

  Whether parallel processing will be used when fitting models. Default
  is `TRUE`. To be passed to
  [`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html).

- ncores:

  The number of CPU cores to use when parallel processing is used. To be
  passed to
  [`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html).

- make_cluster_args:

  Additional arguments to be passed to
  [`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html)
  when creating a cluster for parallel processing. To be passed to
  [`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html).

- progress:

  Whether the testing progress will be displayed on screen.

- tolerance:

  The maximum difference in model chi-squares for two models to be
  considered empirically equivalent.

- eq_df_models_args:

  If `partables` is not supplied (`NULL`) but `original_model` is set,
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  will be called to generate the models. This argument must be a named
  list of additional arguments to be passed to
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md).

## Value

The function `eq_models()` returns a list of the class `eq_partables` (a
subclass of `partables`) of models that are empirically equivalent to
the original model.

The function `is_eq()` returns a logical vector of the same length of
`patables`, with `TRUE` denotes that a model is empirically equivalent
to `original_model`.

## Details

### `eq_models()`

The function `eq_models()` checks the model degrees of freedom and model
chi-squares of a list of models (represented by `lavaan` parameter
tables) against an original model, fitted to a sample, to identify
models that are *empirically* *equivalent* to the original model *in
this sample*.

Two models are empirically equivalent if they (a) have the same model
degrees of freedom and (b) have a difference in model chi-squares equal
to or less than a tolerance (controlled by the argument `tolerance`).

If two models are mathematically equivalent, then they must be
empirically equivalent.

However, even if two models are not mathematically equivalent, they may
still be empirically equivalent for a sample.

### How to Generate the List of Models to Check

Usually, the alternative models can be generated automatically by
leaving `partables` at its default value (`NULL`). The function
[`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
will be called using `original_model` as the original model. The
generation can be customized by setting the argument
`eq_df_models_args`.

Alternatively, the function
[`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
can be called directly to generate an initial list of models. This list
can then be filtered by helpers in
[partable_select](https://sfcheung.github.io/semeqmodels/reference/partable_select.md),
such as
[`must_be_y()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md)
or
[`must_not_have_paths()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md),
and use the resulting list as `partables`.

### `is_eq()`

The function `is_eq()` is similar to `eq_models()`, but returns a
logical vector to indicate which models in `partables` are empirically
equivalent to the original model.

## References

Pesigan, I. J. A., Cheung, S. F., Wu, H., Chang, F., & Leung, S. O.
(2026). How plausible is my model? Assessing model plausibility of
structural equation models using Bayesian posterior probabilities (BPP).
*Behavior Research Methods*, *58*(3), 73.
[doi:10.3758/s13428-025-02921-x](https://doi.org/10.3758/s13428-025-02921-x)

## See also

[`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html)
for the function use to fit the models.

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

# Model 3

mod3 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm
"
fit3 <- sem(
          model = mod3,
          data = data_test_3_factor_3_item
        )
fit3_1_more <- drop_k(fit3)
fit3_1_more_1_less <- lapply(
  fit3_1_more,
  add_k
)

# All equivalent
partables1 <- combine_partables(fit1_1_more_1_less)

# Some equivalent
partables3 <- combine_partables(fit3_1_more_1_less)

eq_out_1 <- eq_models(
          partables1,
          original_model = fit1,
          parallel = FALSE
        )

eq_out_3 <- eq_models(
          partables3,
          original_model = fit3,
          parallel = FALSE
        )

# The usual way to use eq_models:
# 'parallel' should be set to TRUE or omitted
# eq_out_all <- eq_models(
#           original_model = fit1
#         )
# eq_out_all


# Using is_eq()

is_eq(
  partables1,
  original_model = fit1,
  parallel = FALSE
)
#> drop: fm~fx.add: fx~~fm  drop: fm~fx.add: fx~fm drop: fy~fm.add: fm~~fy 
#>                    TRUE                    TRUE                    TRUE 
#>  drop: fy~fm.add: fm~fy 
#>                    TRUE 

is_eq(
  partables3,
  original_model = fit3,
  parallel = FALSE
)
#> drop: fm~fx.add: fx~~fm drop: fm~fx.add: fx~~fy drop: fy~fm.add: fx~~fy 
#>                    TRUE                   FALSE                   FALSE 
#> drop: fy~fm.add: fm~~fy 
#>                   FALSE 
```
