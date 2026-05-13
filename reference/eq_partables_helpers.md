# Helpers for 'eq_partables' Object

Helpers to extract information from the elements of an \`eq_partables“
object.

## Usage

``` r
eq_lavInspect(object, ..., simplify = FALSE)

eq_fitMeasures(object, ..., output_format = c("data.frame", "list"))

eq_df(object)

eq_chisq(object)

eq_fits(object)

# S3 method for class 'eq_partables'
x[i]

# S3 method for class 'eq_partables'
x[i] <- value

# S3 method for class 'eq_partables'
x[[i]] <- value
```

## Arguments

- object:

  An `eq_partables` object.

- ...:

  Optional arguments to be passed to the `lavaan` functions to be
  called. For the subsetting and assignment methods, they are arguments
  to be passed to those methods.

- simplify:

  To be passed to [`sapply()`](https://rdrr.io/r/base/lapply.html). Note
  that the default is `FALSE`, different from
  [`sapply()`](https://rdrr.io/r/base/lapply.html).

- output_format:

  The format of the output of `eq_fitMeasures()`. If `output_format` is
  `"data.frame`, then the output will be a data frame with the number of
  columns equal to the number of models, and rows equal to the number of
  values returned by
  [`lavaan::fitMeasures()`](https://rdrr.io/pkg/lavaan/man/fitMeasures.html).
  If `output_format` is `"list"`, then the output will be a list of
  numeric vectors.

- x:

  A 'eq_partables'-class object.

- i:

  A numeric vector of model position(s), a character vector of model
  name(s), or a logical vector of model(s) to be selected.

- value:

  The value(s) to be assigned to the `eq_partables` object.

## Value

The function `eq_lavInspect()` returns the output of
[`lavaan::lavInspect()`](https://rdrr.io/pkg/lavaan/man/lavInspect.html).
Whether it is a vector, list, or other type of objects depends on the
argument `simplify`, used by
[`sapply()`](https://rdrr.io/r/base/lapply.html).

The function `eq_fitMeasures()` returns the output of
[`lavaan::fitMeasures()`](https://rdrr.io/pkg/lavaan/man/fitMeasures.html).
The format is determined by `output_format`.

The function `eq_fits()` returns a list of `lavaan` outputs for the
models in `object`. If absent for a model, the value returned is `NULL`.

The `[`, `[<-`, and `[[<-` methods return an `eq_partables` object.

## Details

The function `eq_lavInspect()` call
[`lavaan::lavInspect()`](https://rdrr.io/pkg/lavaan/man/lavInspect.html)
on the elements of an `eq_partables` object.

The function `eq_fitMeasures()` call
[`lavaan::fitMeasures()`](https://rdrr.io/pkg/lavaan/man/fitMeasures.html)
on the elements of an `eq_partables` object.

The function `eq_df()` is a wrapper that call `eq_fitMeasures()` with
`fit.measures` set to `"df"`. It always return a numeric vector.

The function `eq_chisq()` is a wrapper that call `eq_fitMeasures()` with
`fit.measures` set to `"chisq"`. It always return a numeric vector.

The function `eq_fits()` extracts the `lavaan` outputs stored for each
model, if present.

The class `eq_partables` has `[`, `[<-`, and `[[<-` methods for
extracting and changing elements.

Though available, it is not advised to assign models to an
`eq_partables` object because there is no guarantee that the names still
reflect how the models are created.

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
fit3_1_more <- drop_k(fit3, fit_models = TRUE)
#> Error in eval(x): object 'mod3' not found
fit3_1_more_1_less <- lapply(
  fit3_1_more,
  add_k,
  fit_models = TRUE
)
#> Error: object 'fit3_1_more' not found
```
