# Empirical Equivalent Models

Identify model(s) in a list of parameter tables empirically equivalent
to the original model.

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

  A list of the class `partables`. If `NULL`, then it will try to
  generate the models by calling
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  on the argument of `original_model`.

- original_model:

  The original model, fitted by
  [`lavaan::lavaan()`](https://rdrr.io/pkg/lavaan/man/lavaan.html) or
  its wrapper, such as
  [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html). If it is a
  `lavaan` parameter table, data will be simulated to fit the model. If
  it is `NULL`, then the first model in `partables` will be used.

- ...:

  Optional arguments to be used when fitting models to the data. Usually
  can be omitted.

- se:

  How standard errors are to be computed. To be passed to `lavaan`. The
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

  Whether the testing progresss will be displayed on screen.

- tolerance:

  The maximum difference in model chi-squares for two models to be
  considered empirically equivalent.

- eq_df_models_args:

  If `partables` is not supplied (`NULL`) but `original_model` is set,
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  will be called to generate the models, used a `partables`. This
  argument is a named list of additional arguments to be passed to
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md).

## Value

The function `eq_models()` returns a list of the class `partables`, of
models that are empirically equivalent to the original model.

The function `is_eq()` returns a logical vector of the same length of
`patables`, with `TRUE` denotes that a model is empirically equivalent
to `original_model`.

## Details

The function `eq_models()` checks the model degrees of freedom and model
chi-squares of a list of models against an original model, fitted to a
sample, to identify models that are *empirically* *equivalent* to the
original model *in this sample*.

Two models are empirically equivalent if they (a) have the same model
degrees of freedom and (b) have a difference in model chi-squares equal
to or less than a tolerance (controlled by the argument `tolerance`).

If two models are mathematically equivalent, then they must be
empirically equivalent.

However, even if two models are not mathematically equivalent, they may
still be empirically equivalent for a sample.

The function `is_eq()` is similar to `eq_models()`, but returns a
logical vector to indicate which models are empirically equivalent to
the original model.

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
#> Error in eval(x): object 'mod1' not found
fit1_1_more_1_less <- lapply(
  fit1_1_more,
  add_k
)
#> Error: object 'fit1_1_more' not found

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
#> Error in eval(x): object 'mod3' not found
fit3_1_more_1_less <- lapply(
  fit3_1_more,
  add_k
)
#> Error: object 'fit3_1_more' not found

# All equivalent
partables1 <- combine_partables(fit1_1_more_1_less)
#> Error: object 'fit1_1_more_1_less' not found

# Some equivalent
partables3 <- combine_partables(fit3_1_more_1_less)
#> Error: object 'fit3_1_more_1_less' not found

eq_out_1 <- eq_models(
          partables1,
          original_model = fit1,
          parallel = FALSE
        )
#> Error in FUN(X[[i]], ...): object 'partables1' not found

eq_out_3 <- eq_models(
          partables3,
          original_model = fit3,
          parallel = FALSE
        )
#> Error in FUN(X[[i]], ...): object 'partables3' not found
```
