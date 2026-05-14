# Modified Models

Generate a list of models a certain number of degrees different from an
original model.

## Usage

``` r
drop_k(
  object,
  ...,
  sem_out = NULL,
  loadings_to_exclude_from_drop = "all",
  df_change_drop = 1,
  must_not_drop = NULL,
  se = "none",
  progress = FALSE,
  fit_models = FALSE,
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  drop_original = TRUE
)

add_k(
  object,
  ...,
  sem_out = NULL,
  df_change_add = 1,
  must_not_add = NULL,
  exclude_x_y_ecov = TRUE,
  partable_name = NULL,
  se = "none",
  progress = FALSE,
  fit_models = FALSE,
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  remove_zeros = FALSE,
  add_name = FALSE
)
```

## Arguments

- object:

  The original model. It can be a `lavaan`-class object (the output of
  [`lavaan::lavaan()`](https://rdrr.io/pkg/lavaan/man/lavaan.html) or
  its wrappers, such as
  [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html)). It can
  also be a parameter table generated in `lavaan`.

- ...:

  Optional arguments to be passed to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).

- sem_out:

  A `lavaan` object. If supplied and `fit_models` is `TRUE`, the
  generate models will be fitted by updating this object.

- loadings_to_exclude_from_drop:

  How factor loadings will be handled. Default is `"all"` and no factor
  loadings will be dropped. To be passed to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).
  This argument should not be changed. Included for internal use.

- df_change_drop:

  The change in the degrees of freedom when generating simplified
  models. Default is one. To be passed to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).

- must_not_drop:

  A character vector of parameters that must not be removed, and so will
  not be modified. To be passed to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).

- se:

  Whether standard error will be computed. This argument will be passed
  to [`lavaan::lavaan()`](https://rdrr.io/pkg/lavaan/man/lavaan.html).
  Default is `"none"`, and this setting overrides the setting in
  `object`. The standard errors are irrelevant in checking whether two
  models are equivalent.

- progress:

  Whether the model generation process will be displayed on screen.

- fit_models:

  Whether the models will be fitted to the data.

- parallel:

  Whether parallel processing will be used when fitting the models.
  Default is `TRUE`. Passed to
  [`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html).

- ncores:

  The number of CPU cores to be used if `parallel` is `TRUE`. Passed to
  [`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html).

- make_cluster_args:

  An optional named list of arguments to be used in
  [`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html).
  Passed to
  [`modelbpp::fit_many()`](https://sfcheung.github.io/modelbpp/reference/fit_many.html).

- drop_original:

  Logical. Whether the original model will dropped from the output.
  Default is `TRUE`.

- df_change_add:

  The change in the degrees of freedom when adding free parameters. To
  be passed to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).
  Default to one. Should not be changed except for experimental use of
  this function.

- must_not_add:

  A character vector of parameters that must not be added. To be passed
  to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html).

- exclude_x_y_ecov:

  If `TRUE`, covariances between an exogenous variable and an error term
  will not be added.

- partable_name:

  The name of the original model. Used only if it cannot be generated
  from `object`.

- remove_zeros:

  Whether a parameter explicitly fixed to `zero` will be removed before
  generating modified models.

- add_name:

  Whether the name of the original model will be added as a prefix to
  the names of the generated models.

## Value

The function `drop_k()` returns a list of the class `eq_partables`, a
subclass of `partables`. It is an output of
[`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html),
which are simplified versions of the original model, usually with one or
more paths removed.

The function `add_k()` returns a list of the class `eq_partables`, a
subclass of the output of
[`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html),
which are more complicated versions of the original model, usually with
one or more free parameters added.

## Details

The function `drop_k()` is a helper to generate a list of models *k*
more degrees of freedom different from an original model fitted by
`lavaan`, such as
[`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html).

The function `add_k()` is a helper to generate a list of models *k* less
degrees of freedom different from an original model fitted by `lavaan`,
such as [`lavaan::sem()`](https://rdrr.io/pkg/lavaan/man/sem.html).

## References

Pesigan, I. J. A., Cheung, S. F., Wu, H., Chang, F., & Leung, S. O.
(2026). How plausible is my model? Assessing model plausibility of
structural equation models using Bayesian posterior probabilities (BPP).
*Behavior Research Methods*, *58*(3), 73.
[doi:10.3758/s13428-025-02921-x](https://doi.org/10.3758/s13428-025-02921-x)

## See also

[`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html)
for how the model generation is implemented.

## Examples

``` r

library(lavaan)

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- sem(
          model = mod,
          data = data_test_3_factor_3_item
        )
pt <- parameterTable(fit)

# ==== Generate models one-less-df ====

# ==== drop_k ====

fit_1_more1 <- drop_k(fit)
#> Error in eval(x): object 'mod' not found
fit_1_more1
#> Error: object 'fit_1_more1' not found

fit_1_more2 <- drop_k(pt)
fit_1_more2
#> 
#> Number of models: 3
#> 
#> The models:
#> 
#>   Model      
#> 1 drop: fm~fx
#> 2 drop: fy~fm
#> 3 drop: fy~fx 
#> 
#> NOTE: 'default' names are used. Call 'print()' and add 'names_to_use =
#> "long"' to use the long descriptive names, if available, for the
#> models.


# ==== add_k ====

# Remove 'parallel = FALSE' or use 'parallel = TRUE'
# to enable parallel processing, which is recommended.
fit_1_less <- add_k(
                fit_1_more1[[1]],
                add_name = TRUE,
                parallel = FALSE
              )
#> Error: object 'fit_1_more1' not found

fit_1_less
#> Error: object 'fit_1_less' not found
```
