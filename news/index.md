# Changelog

## semeqmodels 0.0.0.9040

- Initialize the package. (0.0.0.9000)

- Added a temp test helper to see whether it works. (0.0.0.9001)

- Added a test dataset. (0.0.0.9002)

- Added
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md).
  (0.0.0.9003, 0.0.0.9007)

- Set `testthat` to use parallel processing. (0.0.0.9004)

- Updated `dummy_data()` to randomly set free parameters to non-zero in
  the population. (0.0.0.9005)

- Added `combine_ptables()` and helpers. (0.0.0.9006)

- Added `empirical_eq()`. (0.0.0.9008)

- Updated
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  to disable the computation of `se` by default. (0.0.0.9009)

- Updated
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  to return an `eq_partables` object. (0.0.0.9009)

- Updated
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  to have the option to fit the models generated to a dataset.
  (0.0.0.9009)

- Added some helpers and methods to `eq_partables` objects. (0.0.0.9009)

- Updated `combine_ptables()` to handle a list of `eq_partables`
  objects. (0.0.0.9009)

- Updated `combine_ptables()` to convert parameter tables to
  `eq_partables` objects. (0.0.0.9009)

- Updated `empirical_eq()` to retrieve stored `lavaan` outputs if
  available. (0.0.0.9009)

- Updated `empirical_eq()` to work with `eq_partables` objects.
  (0.0.0.9009)

- Updated
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  to use `sem_out` to fit the models. To be used for empirical
  equivalence. (0.0.0.9010)

- Added helpers to generate known equivalent models for
  3-latent-variable and 4-latent-variable cases. (0.0.0.9010)

- Renamed `empirical_eq()` to
  [`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md),
  to be consistent in naming with other `eq_` functions. (0.0.0.9012)

- Added
  [`is_eq()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md),
  a version of
  [`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
  that returns a logical vector. (0.0.0.9012)

- Added
  [`setdiff_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  an internal function that may be exported in the future. (0.0.0.9012)

- Added
  [`as_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  an internal function that may be exported in the future. (0.0.0.9012)

- Added `x_y_ecov()`, an internal function that may be exported in the
  future. (0.0.0.9012)

- Added `has_x_y_ecov()`, an internal function that may be exported in
  the future. (0.0.0.9012)

- Added
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md),
  for generating models with the same model *df* as a fitted model.
  (0.0.0.9012)

- Added
  [`remove_x_y_ecov()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md),
  an internal function that may be exported in the future. (0.0.0.9012)

- Updated
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  to support parallel processing. (0.0.0.9013)

- Added a few subsetting and assingment methods for `eq_partables`
  objects. (0.0.0.9014)

- Added functions such as
  [`have_pars_all()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md)
  and
  [`have_pars_any()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md)
  for selecting models based on free parameters. (0.0.0.9015)

- Added a `print`-method for `eq_partables` objects to handle
  zero-length lists. (0.0.0.9015)

- Exported `digest_ptable()` and friends. (0.0.0.9016)

- Renamed all instances of `ptable` and `ptables` to `partable` and
  `partables`, respectively. Using both versions is confusing. Use only
  `partable` and `partables` from now on. (0.0.0.9017)

- Exported
  [`setdiff_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  [`remove_x_y_ecov()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md),
  and
  [`as_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md).
  (0.0.0.9018)

- Added
  [`union_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  [`intersect_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  [`is_element_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  [`match_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  `%pt_in%`, `%pt_notin%`,
  [`is_partable()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md),
  and
  [`is_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md).
  (0.0.0.9018)

- Updated
  [`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
  to accept more types of inputs without `partables`: a parameter table,
  a lavaan model syntax, or a `lavaan` output. It will call
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  to generate the list of models automatically. (0.0.0.9019)

- Added
  [`must_have_paths()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md),
  [`must_not_have_paths()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md),
  [`must_not_be_y()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md),
  and
  [`must_be_y()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md).
  (0.0.0.9020)

- Added
  [`model_diff()`](https://sfcheung.github.io/semeqmodels/reference/model_diff.md)
  to compare two parameter tables. (0.0.0.9021)

- Added
  [`eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md)
  to create an `eq_partables` object from parameter tables or lavaan
  output. (0.0.0.9022)

- Added `model_difF_many()` for comparing several models with one model.
  (0.0.0.9023)

- Improved parallel processing in
  [`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md).
  (0.0.0.9024)

- Added a get-started vignette. (0.0.0.9025)

- Some options of `digest_partable` can now be set through options.
  (0.0.0.9026)

- Added more arguments of
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  to
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md).
  (0.0.0.9026)

- Revised
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  to use digests as the names of model. Can resort to
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html)
  names by setting `short_names` to `FALSE`. (0.0.0.9026)

- The outputs of
  [`model_diff()`](https://sfcheung.github.io/semeqmodels/reference/model_diff.md)
  and
  [`model_diff_many()`](https://sfcheung.github.io/semeqmodels/reference/model_diff.md)
  are of the classes `model_diff` and `model_diff_many`, with
  `print`-methods for user-friendly printouts. (0.0.0.9027)

- Improved
  [`print.eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md).
  (0.0.0.9028)

- Updated
  [`add_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  and
  [`drop_k()`](https://sfcheung.github.io/semeqmodels/reference/modified_models.md)
  to work on observed-variable-only models. (0.0.0.9029)

- Updated \`digest_partable() to ignore order of variables in
  covariances. (0.0.0.9030)

- Fixed
  [`setdiff_eq_partables()`](https://sfcheung.github.io/semeqmodels/reference/partable_helpers.md)
  when one list is a proper subset of the other list. (0.0.0.9031)

- Added several internal functions to examine the search history. These
  functions may be exported in the future. (0.0.0.9032)

- Fixed
  [`model_diff()`](https://sfcheung.github.io/semeqmodels/reference/model_diff.md)
  to treat covariances like `x~~m` and `m~~x` as identical. (0.0.0.9033)

- Updated the search to be more liberal in handling covariances,
  resulting in more models identified in some cases. (0.0.0.9034)

- Added the internal function `has_x_y_ecov2()` to check for covariation
  between an `x` variable and the error term of its `y` variable, even
  indirectly. (0.0.0.9035, 0.0.0.9038)

- Updated
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md)
  to use `fix_call()`. (0.0.0.9037)

- Disallow `fixed.x = TRUE` for now. If a model is fitted with
  `fixed.x = TRUE`, the default in `lavaan`, an error will be thrown.
  (0.0.0.9038)

- If a model cannot be fitted using LISREL representation, RAM
  representation will be used automatically. (0.0.0.9039)

- In
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md),
  no free parameters will be added to two variables if their relation is
  fixed to zero in the original model. (0.0.0.9039)

- Added test datasets and tests for more models. (0.0.0.9040)
