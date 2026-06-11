# Helpers for 'eq_partables' Object

Helpers to work with an `eq_partables` object.

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

# S3 method for class 'eq_partables'
print(
  x,
  max_models = NULL,
  names_to_use = c("default", "long"),
  wrap_long_names = TRUE,
  readable_long_names = TRUE,
  ...
)

# S3 method for class 'eq_partables'
c(..., drop_duplicated = TRUE)

eq_partables(...)

as_eq_partables(sem_out = NULL, model_name = "original")

# S3 method for class 'eq_partables'
duplicated(x, incomparables = FALSE, ...)

# S3 method for class 'eq_partables'
unique(x, incomparables = FALSE, ...)
```

## Arguments

- object:

  An `eq_partables` object.

- ...:

  For `eq_lavInspect()` and `eq_fitMeasures()`, these are optional
  arguments to be passed to the `lavaan` functions to be called. For the
  `print`-method of `eq_partables` objects, these arguments are not
  used. For the `c`-method of `eq_partables` objects, these are
  `eq_partables` objects to be combined. For `eq_partables()`, it should
  be `lavaan` outputs or `lavaan` parameter tables.

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

  An `eq_partables` object.

- i:

  A numeric vector of model position(s), a character vector of model
  name(s), or a logical vector of model(s) to be selected.

- value:

  The value(s) to be assigned to the `eq_partables` object.

- max_models:

  The maximum number of models to print. If `NULL`, all models will be
  printed.

- names_to_use:

  If `"default"`, the names in `x`, which may not be descriptive, will
  be used. If `"long"`, the names from
  [`modelbpp::gen_models()`](https://sfcheung.github.io/modelbpp/reference/model_set.html)
  will be used if available. They can be very long, but describes the
  changes leading to a model.

- wrap_long_names:

  If `TRUE`, long names will be wrapped when printed. Used only when
  `names_to_use` is `"long"`.

- readable_long_names:

  If `TRUE`, the long names will be modified to make them more readable.

- drop_duplicated:

  Logical. Whether duplicated models will be removed.

- sem_out:

  A `lavaan` object or a `lavaan` parameter table. Can be `NULL`.

- model_name:

  The name of the model in the output.

- incomparables:

  Not used.

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

The `print`-method of `eq_partables` returns `x` invisibly. It is called
for its side-effect.

The `c`-method of `eq_partables` returns a list of the class
`eq_partables`.

The function `eq_partables()` returns an `eq_partables` object created
from one or more `lavaan` outputs or `lavaan` parameter tables.

The function `as_eq_partables()` returns a one-element `eq_partables`
object if `sem_out` is a `lavaan` output or a `lavaan` parameter table.
It returns a zero-length `eq_partables` object otherwise.

The `duplicated`-method of `eq_partables` returns a logical vector to
indicate which models, if any, are identical to other models earlier in
the list.

The `unique`-method of `eq_partables` returns an `eq_partables` object.

## Details

Although the functions are designed to work with the output of
[`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md),
they also work for a list of models (parameter tables), except for the
methods specifically for an `eq_partables` object.

The function `eq_lavInspect()` calls
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

The `print`-method of `eq_partables` object handles a zero-length list.
If not of zero-length, the `print`-method for `partables` will be used.

The `c`-method of `eq_partables` object combines `eq_partables` elements
to one single `eq_partables` elements.

The function `eq_partables()` creates an `eq_partables` object from
`lavaan` parameter tables or `lavaan` outputs.

The function `as_eq_partables()` is not a usual `as` function. It works
only on a `lavaan` output or `lavaan` parameter table. It converts
`sem_out` to a one-element list of the class `eq_partables`, with the
parameter table as the element and the `lavaan` output, if `sem_out` is
a `lavaan` output, in the attribute `"fit"`. If `sem_out` is not a
`lavaan` object nor a `lavaan` parameter table, a zero-length
`eq_partables` object will be returned.

The `duplicated`-method of `eq_partables` checks whether any models are
identical. If yes, the duplicated models, except for the first one, will
be denoted as duplicated.

The `unique`-method of `eq_partables` returns an `eq_partables` object
with duplicated models, if any, removed.

## Examples

``` r

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

# Remove 'parallel = FALSE' or set parallel to TRUE
# for faster generation.
out <- eq_models(
  original_model = fit1,
  parallel = FALSE
)
out
#> 
#> Number of models: 5
#> 
#> The models:
#> 
#>   Model   
#> 1 12672c47
#> 2 45f61ccf
#> 3 b0a9b170
#> 4 459cd495
#> 5 c02043f3 
#> 
#> NOTE: 'default' names are used. Call 'print()' and add 'names_to_use =
#> "long"' to use the long descriptive names, if available, for the
#> models.

eq_lavInspect(out, "implied")
#> $`12672c47`
#> $`12672c47`$cov
#>       fx    fm    fy
#> fx 1.002            
#> fm 0.245 0.943      
#> fy 0.062 0.237 0.927
#> 
#> 
#> $`45f61ccf`
#> $`45f61ccf`$cov
#>       fx    fy    fm
#> fx 1.002            
#> fy 0.062 0.927      
#> fm 0.245 0.237 0.943
#> 
#> 
#> $b0a9b170
#> $b0a9b170$cov
#>       fx    fm    fy
#> fx 1.002            
#> fm 0.245 0.943      
#> fy 0.062 0.237 0.927
#> 
#> 
#> $`459cd495`
#> $`459cd495`$cov
#>       fy    fm    fx
#> fy 0.927            
#> fm 0.237 0.943      
#> fx 0.062 0.245 1.002
#> 
#> 
#> $c02043f3
#> $c02043f3$cov
#>       fy    fm    fx
#> fy 0.927            
#> fm 0.237 0.943      
#> fx 0.062 0.245 1.002
#> 
#> 


eq_fitMeasures(out, c("cfi", "tli"))
#>     12672c47 45f61ccf b0a9b170 459cd495 c02043f3
#> cfi 1.000000 1.000000 1.000000 1.000000 1.000000
#> tli 1.128028 1.128028 1.128028 1.128028 1.128028



eq_df(out)
#> 12672c47 45f61ccf b0a9b170 459cd495 c02043f3 
#>        1        1        1        1        1 


eq_fits(out)
#> $`12672c47`
#> lavaan 0.6-21 ended normally after 1 iteration
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                         5
#> 
#>   Number of observations                           200
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                 0.001
#>   Degrees of freedom                                 1
#>   P-value (Chi-square)                           0.980
#> 
#> $`45f61ccf`
#> lavaan 0.6-21 ended normally after 1 iteration
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                         5
#> 
#>   Number of observations                           200
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                 0.001
#>   Degrees of freedom                                 1
#>   P-value (Chi-square)                           0.980
#> 
#> $b0a9b170
#> lavaan 0.6-21 ended normally after 1 iteration
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                         5
#> 
#>   Number of observations                           200
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                 0.001
#>   Degrees of freedom                                 1
#>   P-value (Chi-square)                           0.980
#> 
#> $`459cd495`
#> lavaan 0.6-21 ended normally after 1 iteration
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                         5
#> 
#>   Number of observations                           200
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                 0.001
#>   Degrees of freedom                                 1
#>   P-value (Chi-square)                           0.980
#> 
#> $c02043f3
#> lavaan 0.6-21 ended normally after 1 iteration
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                         5
#> 
#>   Number of observations                           200
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                 0.001
#>   Degrees of freedom                                 1
#>   P-value (Chi-square)                           0.980
#> 


out1 <- out[2:3]

out1
#> 
#> Number of models: 2
#> 
#> The models:
#> 
#>   Model   
#> 1 45f61ccf
#> 2 b0a9b170 
#> 
#> NOTE: 'default' names are used. Call 'print()' and add 'names_to_use =
#> "long"' to use the long descriptive names, if available, for the
#> models.
```
