# semeqmodels 0.0.0.9010

- Initialize the package.
  (0.0.0.9000)

- Added a temp test helper to see whether
  it works.
  (0.0.0.9001)

- Added a test dataset.
  (0.0.0.9002)

- Added `drop_k()` and `add_k()`.
  (0.0.0.9003, 0.0.0.9007)

- Set `testthat` to use parallel
  processing.
  (0.0.0.9004)

- Updated `dummy_data()` to randomly
  set free parameters to non-zero in
  the population.
  (0.0.0.9005)

- Added `combine_ptables()` and helpers.
  (0.0.0.9006)

- Added `empirical_eq()`.
  (0.0.0.9008)

- Updated `drop_k()` and `add_k()` to
  disable the computation of `se` by
  default. (0.0.0.9009)

- Updated `drop_k()` and `add_k()` to
  return an `eq_partables` object.
  (0.0.0.9009)

- Updated `drop_k()` and `add_k()` to
  have the option to fit the models
  generated to a dataset.
  (0.0.0.9009)

- Added some helpers and methods to
  `eq_partables` objects.
  (0.0.0.9009)

- Updated `combine_ptables()` to
  handle a list of `eq_partables` objects.
  (0.0.0.9009)

- Updated `combine_ptables()` to
  convert parameter tables to
  `eq_partables` objects.
  (0.0.0.9009)

- Updated `empirical_eq()` to retrieve
  stored `lavaan` outputs if available.
  (0.0.0.9009)

- Updated `empirical_eq()` to work with
  `eq_partables` objects.
  (0.0.0.9009)

- Updated `drop_k()` and `add_k()` to
  use `sem_out` to fit the models. To
  be used for empirical equivalence.
  (0.0.0.9010)