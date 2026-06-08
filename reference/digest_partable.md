# Helpers to Compare Models

Helper functions that compute and use hash digests for models (parameter
tables) to facilitate comparisons.

## Usage

``` r
digest_partable(
  partable,
  cols = getOption("semeqmodels.digest_cols", default = c("lhs", "op", "rhs", "block",
    "group", "free", "ustart", "start")),
  digits = getOption("semeqmodels.digest_digits", default = 6),
  sort_rows = TRUE,
  sort_by = getOption("semeqmodels.digest_sort_by", default = c("lhs", "op", "rhs",
    "block", "group")),
  algo = getOption("semeqmodels.algo", default = "xxhash32"),
  ...
)

add_digest(partable, ...)

get_digest(partable, ...)

add_digest_partables(partables, ...)

get_digest_partables(partables, ...)
```

## Arguments

- partable:

  A `lavaan` parameter table. If it is a `lavaan` output, the parameter
  table will be retrieved by
  [`lavaan::parameterTable()`](https://rdrr.io/pkg/lavaan/man/parTable.html).

- cols:

  The columns to be used to compute the hash value. Note that `start`
  and `ustart` will be rounded based on `digits`, `free` will be
  converted to 0s and 1s (any values greater than 0 will be converted to
  0), and `start` and `ustart` will be set to `NA` for free parameters.

- digits:

  The number of digits when rounding `ustart` and `start` by
  [`round()`](https://rdrr.io/r/base/Round.html).

- sort_rows:

  Whether the parameter tables will be sorted by `cols` before computing
  the hash value.

- sort_by:

  The columns used when sorting the rows, if `sort_rows` is `TRUE`.

- algo:

  The algorithm used to by
  [`digest::digest()`](https://eddelbuettel.github.io/digest/man/digest.html).
  Note that the default value is different from that of
  [`digest::digest()`](https://eddelbuettel.github.io/digest/man/digest.html)

- ...:

  For `digest_partable()`, these are optional arguments to be passed to
  [`digest::digest()`](https://eddelbuettel.github.io/digest/man/digest.html).
  For `add_digest()`, `get_digest()`, `add_digest_partables()`, and
  `get_digest_partables()`, these are arguments to be passed to
  `digest_partable()`.

- partables:

  A list of `lavaan` parameter tables.

## Value

The function `digest_partable()` returns a character string, the output
of
[`digest::digest()`](https://eddelbuettel.github.io/digest/man/digest.html).

The function `add_digest()` returns the parameter table, with the hash
value stored in the attribute `"digest"`.

The function `get_digest()` returns the hash value of a parameter table.

The function add_digest_partables returns the list of parameter tables,
with hash values stored.

The function get_digest_partables returns a character vector, the
outputs of `get_digest()` for the parameter tables.

## Details

The function `digest_partable()` uses
[`digest::digest()`](https://eddelbuettel.github.io/digest/man/digest.html)
to compute a hash value for a parameter, after sorting some essential
columns (see the `cols` argument) If two `lavaan` parameter tables are
identical on the values for these columns, they should have the same
hash value and will be considered as identical.

Note that there may be cases in which two models cannot be correctly
identified using this approach. Nevertheless, they should be sufficient
for typical models used in this package.

The function `add_digest()` computes the hash value of a parameter table
and adds it to the attribute `"digest"` of the table,

The function `get_digest()` retrieves the stored hash value from a
parameter table, if available. If not available, it will call
`digest_partable()` to compute the hash value.

The function add_digest_partables calls `add_digest()` on a list of
parameter tables.

The function get_digest_partables calls `get_digest()` on a list of
parameter tables.

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
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )

mod2 <-
"
fy =~ y1 + y2 + y3
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy ~ fm + fx
fm ~ fx
"
fit2 <- sem(
          model = mod2,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )

pt1 <- parameterTable(fit1)
pt2 <- parameterTable(fit2)

pt1
#>    id lhs op rhs user block group free ustart exo label plabel start   est
#> 1   1  fx =~  x1    1     1     1    0      1   0         .p1. 1.000 1.000
#> 2   2  fx =~  x2    1     1     1    1     NA   0         .p2. 1.127 1.127
#> 3   3  fx =~  x3    1     1     1    2     NA   0         .p3. 0.756 0.756
#> 4   4  fm =~  m1    1     1     1    0      1   0         .p4. 1.000 1.000
#> 5   5  fm =~  m2    1     1     1    3     NA   0         .p5. 0.658 0.658
#> 6   6  fm =~  m3    1     1     1    4     NA   0         .p6. 0.669 0.669
#> 7   7  fy =~  y1    1     1     1    0      1   0         .p7. 1.000 1.000
#> 8   8  fy =~  y2    1     1     1    5     NA   0         .p8. 0.486 0.486
#> 9   9  fy =~  y3    1     1     1    6     NA   0         .p9. 0.502 0.502
#> 10 10  fm  ~  fx    1     1     1    7     NA   0        .p10. 0.000 0.000
#> 11 11  fy  ~  fm    1     1     1    8     NA   0        .p11. 0.000 0.000
#> 12 12  fy  ~  fx    1     1     1    9     NA   0        .p12. 0.000 0.000
#> 13 13  x1 ~~  x1    0     1     1   10     NA   0        .p13. 0.946 0.946
#> 14 14  x2 ~~  x2    0     1     1   11     NA   0        .p14. 0.751 0.751
#> 15 15  x3 ~~  x3    0     1     1   12     NA   0        .p15. 0.778 0.778
#> 16 16  m1 ~~  m1    0     1     1   13     NA   0        .p16. 0.874 0.874
#> 17 17  m2 ~~  m2    0     1     1   14     NA   0        .p17. 0.746 0.746
#> 18 18  m3 ~~  m3    0     1     1   15     NA   0        .p18. 0.597 0.597
#> 19 19  y1 ~~  y1    0     1     1   16     NA   0        .p19. 1.000 1.000
#> 20 20  y2 ~~  y2    0     1     1   17     NA   0        .p20. 0.702 0.702
#> 21 21  y3 ~~  y3    0     1     1   18     NA   0        .p21. 0.695 0.695
#> 22 22  fx ~~  fx    0     1     1   19     NA   0        .p22. 0.050 0.050
#> 23 23  fm ~~  fm    0     1     1   20     NA   0        .p23. 0.050 0.050
#> 24 24  fy ~~  fy    0     1     1   21     NA   0        .p24. 0.050 0.050
pt2
#>    id lhs op rhs user block group free ustart exo label plabel start   est
#> 1   1  fy =~  y1    1     1     1    0      1   0         .p1. 1.000 1.000
#> 2   2  fy =~  y2    1     1     1    1     NA   0         .p2. 0.486 0.486
#> 3   3  fy =~  y3    1     1     1    2     NA   0         .p3. 0.502 0.502
#> 4   4  fx =~  x1    1     1     1    0      1   0         .p4. 1.000 1.000
#> 5   5  fx =~  x2    1     1     1    3     NA   0         .p5. 1.127 1.127
#> 6   6  fx =~  x3    1     1     1    4     NA   0         .p6. 0.756 0.756
#> 7   7  fm =~  m1    1     1     1    0      1   0         .p7. 1.000 1.000
#> 8   8  fm =~  m2    1     1     1    5     NA   0         .p8. 0.658 0.658
#> 9   9  fm =~  m3    1     1     1    6     NA   0         .p9. 0.669 0.669
#> 10 10  fy  ~  fm    1     1     1    7     NA   0        .p10. 0.000 0.000
#> 11 11  fy  ~  fx    1     1     1    8     NA   0        .p11. 0.000 0.000
#> 12 12  fm  ~  fx    1     1     1    9     NA   0        .p12. 0.000 0.000
#> 13 13  y1 ~~  y1    0     1     1   10     NA   0        .p13. 1.000 1.000
#> 14 14  y2 ~~  y2    0     1     1   11     NA   0        .p14. 0.702 0.702
#> 15 15  y3 ~~  y3    0     1     1   12     NA   0        .p15. 0.695 0.695
#> 16 16  x1 ~~  x1    0     1     1   13     NA   0        .p16. 0.946 0.946
#> 17 17  x2 ~~  x2    0     1     1   14     NA   0        .p17. 0.751 0.751
#> 18 18  x3 ~~  x3    0     1     1   15     NA   0        .p18. 0.778 0.778
#> 19 19  m1 ~~  m1    0     1     1   16     NA   0        .p19. 0.874 0.874
#> 20 20  m2 ~~  m2    0     1     1   17     NA   0        .p20. 0.746 0.746
#> 21 21  m3 ~~  m3    0     1     1   18     NA   0        .p21. 0.597 0.597
#> 22 22  fy ~~  fy    0     1     1   19     NA   0        .p22. 0.050 0.050
#> 23 23  fx ~~  fx    0     1     1   20     NA   0        .p23. 0.050 0.050
#> 24 24  fm ~~  fm    0     1     1   21     NA   0        .p24. 0.050 0.050

digest_partable(pt1)
#> [1] "fd631766"
digest_partable(pt2)
#> [1] "fd631766"
```
