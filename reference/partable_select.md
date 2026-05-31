# Select Parameter Tables

Helper functions to select parameter tables based on parameters.

## Usage

``` r
have_pars_all(
  partables,
  pars = NULL,
  output = c("models", "partables", "logical")
)

have_pars_any(
  partables,
  pars = NULL,
  output = c("models", "partables", "logical")
)

have_pars_none(
  partables,
  pars = NULL,
  output = c("models", "partables", "logical")
)

remove_x_y_ecov(partables, output = c("models", "partables", "logical"))

must_not_be_y(
  partables,
  vars = NULL,
  output = c("models", "partables", "logical")
)

must_be_y(partables, vars = NULL, output = c("models", "partables", "logical"))

must_not_have_paths(
  partables,
  y_on_x = NULL,
  output = c("models", "partables", "logical")
)

must_have_paths(
  partables,
  y_on_x = NULL,
  output = c("models", "partables", "logical")
)
```

## Arguments

- partables:

  A list of parameter tables, such as a `partables` or `eq_partables`
  object.

- pars:

  A character vector of `lavaan` model syntax that can be converted to a
  parameter table. It can be a vector of parameters, such as
  `c("y ~ x", "m ~~ x")`, but can also be of other forms as long as
  [`lavaan::lavParseModelString()`](https://rdrr.io/pkg/lavaan/man/model.syntax.html)
  can process it. Covariances such as `"m ~~ x"` and `"x ~~ m"` are
  treated as the same and so only one of them is necessary.

- output:

  The type of output. If `"models"` or `"partables"`, a list of `lavaan`
  parameter tables is returned. If `"logical"`, a logical vector of the
  same length as `partables` is returned to indicate models that match
  the selection criteria.

- vars:

  A character vector of variables to be checked.

- y_on_x:

  A character vector of pairs of variables, specified as `"y ~ x"`, for
  which paths will be checked.

## Value

The function `have_pars_all()`, by default, returns a list of parameter
tables that have all the free parameters specified in `pars`. If
`output` set to `"logical"`, it returns a logical vector to indicate
models that have all the free parameters specified.

The function `have_pars_any()`, by default, returns a list of parameter
tables that have any of the free parameters specified in `pars`. If
`output` set to `"logical"`, it returns a logical vector to indicate
models that have all any of free parameters specified.

The function `have_pars_none()`, by default, returns a list of parameter
tables that have all the free parameters specified in `pars`. If
`output` set to `"logical"`, it returns a logical vector to indicate
models that have all the free parameters specified.

The function `remove_x_y_ecov()`, by default, returns a list of
parameter tables, of the same class as `partables`. If `output` is
`"logical"`, it returns a logical vector for selecting models identical
to the output of `remove_x_y_ecov()`.

The function `must_not_be_y()` returns a list of parameter tables, of
the same class as `partables`. If `output` is `"logical"`, it returns a
logical vector for selecting models identical to the output of
`must_not_be_y()`.

The function `must_be_y()` returns a list of parameter tables, of the
same class as `partables`. If `output` is `"logical"`, it returns a
logical vector for selecting models identical to the output of
`must_be_y()`.

The function `must_not_have_paths()` returns a list of parameter tables,
of the same class as `partables`. If `output` is `"logical"`, it returns
a logical vector for selecting models identical to the output of
`must_not_have_paths()`.

The function `must_have_paths()` returns a list of parameter tables, of
the same class as `partables`. If `output` is `"logical"`, it returns a
logical vector for selecting models identical to the output of
`must_have_paths()`.

## Details

The function `have_pars_all()` identify models that have all the free
parameters specified in `pars`.

The function `have_pars_any()` identify models that have any of the free
parameters specified in `pars`.

The function `have_pars_none()` identify models that have none of the
free parameters specified in `pars`.

The function `remove_x_y_ecov()` remove models from `partables` that
have one or more covariances between an exogenous variable (observed or
latent) and an error term.

The function `must_not_be_y()` keep only models with variables (observed
or latent) does not appear as the outcome in a regression equation
(indicators not counted). They are defined as variables not in `"eqs.y"`
as returned by
[`lavaan::lavNames()`](https://rdrr.io/pkg/lavaan/man/lavNames.html).

The function `must_be_y()` keep only models with variables (observed or
latent) appear as the outcome in at least one regression equation
(indicators not counted). They are defined as variables in `"eqs.y"` as
returned by
[`lavaan::lavNames()`](https://rdrr.io/pkg/lavaan/man/lavNames.html).

The function `must_not_have_paths()` keep only models that do not have
any paths, direct or indirect, between selected pairs of variables.

The function `must_have_paths()` keep only models at least one path,
direct or indirect, between selected pairs of variables.

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

partables1 <- combine_partables(fit1_1_more_1_less)
#> Error: object 'fit1_1_more_1_less' not found
partables1
#> Error: object 'partables1' not found

have_pars_all(partables1, c("fx ~~ fm", "fy ~ fx"))
#> Error: object 'partables1' not found
have_pars_all(partables1, c("fx ~~ fm", "fy ~ fx"),
              output = "logical")
#> Error: object 'partables1' not found


have_pars_any(partables1, c("fx ~~ fm", "fm ~ fx"))
#> Error: object 'partables1' not found
have_pars_any(partables1, c("fx ~~ fm", "fm ~ fx"),
              output = "logical")
#> Error: object 'partables1' not found


have_pars_none(partables1, c("fx ~~ fm", "fm ~ fx"))
#> Error: object 'partables1' not found
have_pars_none(partables1, c("fx ~~ fm", "fm ~ fx"),
               output = "logical")
#> Error: object 'partables1' not found
```
