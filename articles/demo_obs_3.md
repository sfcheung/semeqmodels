# Workflow Demo: 3 Observed Variables

## Introduction

This article is part of a [series of
articles](https://sfcheung.github.io/semeqmodels/articles/index.html#demonstrations)
to demonstrate how to use
[semeqmodels](https://sfcheung.github.io/semeqmodels/) to identify
models empirically equivalent to a target model, called the *original*
*model*.

NOTE: To make articles in this series self-contained, some sections are
repeated across articles.

## Scope

A simple mediation model will be used as an example. This model is
trivial, but is simple enough to illustrate how to use `semeqmodels`.

## Original Model

Suppose this the original model we fitted to dataset `data_test_3obvs`
(installed with the package):

``` r

library(semeqmodels)
round(head(data_test_3obvs), 2)
#>      fm    fy   fx
#> 1  0.75 -0.84 2.69
#> 2 -0.78 -0.64 0.33
#> 3 -0.31  0.41 0.12
#> 4 -0.33 -0.82 0.62
#> 5  0.42 -0.59 0.62
#> 6  0.98  0.97 0.13
```

![Simple Mediation Model](demo_obs_3_model-1.png)

Simple Mediation Model

This is the model:

``` r

mod <-
"
fm ~ fx
fy ~ fm + fx
"
```

This is the lavaan results for the model:

``` r

library(lavaan)
fit <- sem(
  model = mod,
  data = data_test_3obvs,
  fixed.x = FALSE
)
fit
#> lavaan 0.7-1.3032 ended normally after 1 iteration
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                         6
#> 
#>   Number of observations                           200
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                 0.000
#>   Degrees of freedom                                 0
```

NOTE: For now, `semeqmodels` only support models fitted with
`fixed.x = FALSE`, such that all observed variables can be freely
changed.

This model is a saturated model, with model *df* equals to zero.
Therefore, all empirically equivalent models will also be saturated
because they will also have zero *df*.

## Empirical Equivalence

Suppose we are would like to find *some* models that are *empirically*
*equivalent* to this model:

In this package, two models are defined to be empirically equivalent if
the following conditions are met:

- They have the same model degrees of freedom.

- Their absolute differences on selected fit measures are equal to or
  smaller than a user-defined tolerance.

See [this section](#equivalence-in-principle-and-empirical-equivalence)
on a discussion of equivalence

We will start the demonstration using model $`\chi^2`$, with a tolerance
of 0.00001.

## Generating Empirically Equivalent Models

To generate models that are empirically equivalent to a fitted model, we
can simply call
[`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
and set `original_model` to the output of `lavaan`:

``` r

library(semeqmodels)
out <- eq_models(
  original_model = fit
)
```

The search can be customized if necessary. Please refer to the help page
of
[`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
for available options.

This is the text output:

``` r

out
#> 
#> Number of models: 13
#> 
#> The models:
#> 
#>    Model   
#> 1  0e2f16c3
#> 2  08abece1
#> 3  3e72d53b
#> 4  da6c9353
#> 5  8f9f269c
#> 6  2251354d
#> 7  85214c93
#> 8  53162624
#> 9  ffd41199
#> 10 efd952f3
#> 11 cf9c713d
#> 12 63cacac9
#> 13 50dce357 
#> 
#> NOTE: 'default' names are used. Call 'print()' and add 'names_to_use =
#> "long"' to use the long descriptive names, if available, for the
#> models.
```

The default names are generated to uniquely identify the models. Treat
them as identification numbers. They are useful IDs because they are
short. However, it is much easier to examine the models by drawing them.

The function
[`eq_chisq()`](https://sfcheung.github.io/semeqmodels/reference/eq_partables_helpers.md)
can be used to extract the model $`\chi^2`$s, to verify that they have
model $`\chi^2`$s close to the that of the original model:

``` r

eq_chisq(out)
#>     0e2f16c3     08abece1     3e72d53b     da6c9353     8f9f269c     2251354d 
#> 0.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00 
#>     85214c93     53162624     ffd41199     efd952f3     cf9c713d     63cacac9 
#> 0.000000e+00 8.881784e-14 8.881784e-14 0.000000e+00 0.000000e+00 8.881784e-14 
#>     50dce357 
#> 8.881784e-14
```

``` r

fitMeasures(fit, "chisq")
#> chisq 
#>     0
```

These models also have model degrees of freedom equal to that of the
original model:

``` r

eq_df(out)
#> 0e2f16c3 08abece1 3e72d53b da6c9353 8f9f269c 2251354d 85214c93 53162624 
#>        0        0        0        0        0        0        0        0 
#> ffd41199 efd952f3 cf9c713d 63cacac9 50dce357 
#>        0        0        0        0        0
```

## Drawing the Models

To draw the models, the function
[`partables_plots()`](https://sfcheung.github.io/semeqmodels/reference/plot_partables.md)
can be used. It used the function
[`semPlot::semPaths()`](https://rdrr.io/pkg/semPlot/man/semPaths.html)
from the `semPlot` package to draw the model. Therefore, basic knowledge
of
[`semPlot::semPaths()`](https://rdrr.io/pkg/semPlot/man/semPaths.html)
is required.

To draw the model, we need a common layout, in the form of a matrix of
names:

``` r

# Set the layout of the plots
m <- matrix(
  c(  NA, "fm",   NA,
    "fx",   NA, "fy"),
  nrow = 2,
  ncol = 3,
  byrow = TRUE)
m
#>      [,1] [,2] [,3]
#> [1,] NA   "fm" NA  
#> [2,] "fx" NA   "fy"
```

We can then generate the plots:

``` r

p <- partables_plots(
  out,
  original_model = fit,
  layout = m,
  label.cex = 1.5,
  sizeMan = 11,
  edge.width = 5,
  asize = 5
)
```

We can then call
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) to plot the
models. By default, they will be drawn one by one. To draw them in a
grid, use the arguments `ncol` and `nrow`:

``` r

plot(
  p,
  ncol = 5,
  nrow = 3,
  title_adj = 2
)
```

![Empirically Equivalent Models](demo_obs_3_eqmodels-1.png)

Empirically Equivalent Models

The model labelled `Original` is the original model. The other models
are empirically equivalent to this model in this dataset.

By default:

- Paths or covariances different form the original model are colored.

- Covariances are displayed using curves.

There are other ways to customize how the models are drawn. Please refer
to the help page of
[`plot.partables_plots()`](https://sfcheung.github.io/semeqmodels/reference/plot_partables.md).

## Filter the Models

The package `semeqmodels` has functions for selecting models, listed
[here](https://sfcheung.github.io/semeqmodels/reference/partable_select.md).
They can also be used to filter the output of `partables_plot()`. Some
of them are demonstrated below.

### `fx` Must Not Be a DV (`y`-variables)

Suppose that we have reasons to argue that `fx` cannot be an outcome of
any other variables in the model. For example, `fx` is measured one
month before the other variables.

We can use
[`must_not_be_y()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md)
to specify variables that cannot be a “DV.”

``` r

p1 <- p |>
  must_not_be_y(
    vars = "fx"
  )
plot(
  p1,
  ncol = 5,
  nrow = 2,
  title_adj = 2
)
```

![fx Must Not Be a y-Variable](demo_obs_3_not_y-1.png)

fx Must Not Be a y-Variable

Note: A variable is a “DV” if it appears as the outcome of at least one
other variable. Therefore, a mediator is also a DV.

### `fy` Must Be a DV (`y`-variables)

Suppose that we have reasons to argue that `fy` must be an outcome of at
least one other variable.

We can use
[`must_be_y()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md)
to specify variables that must be a “DV.”

``` r

p2 <- p |>
  must_be_y(
    vars = "fy"
  )
plot(
  p2,
  ncol = 5,
  nrow = 2,
  title_adj = 2
)
```

![fy Must Be a y-Variable](demo_obs_3_be_y-1.png)

fy Must Be a y-Variable

### Must Not Have Any Paths from `fy` to `fx`

Suppose that, theoretically, `fy` cannot have any effect on `fx`,
directly or indirectly. We can use
[`must_not_have_paths()`](https://sfcheung.github.io/semeqmodels/reference/partable_select.md).

``` r

p3 <- p |>
  must_not_have_paths(
    y_on_x = "fx ~ fy"
  )
plot(
  p3,
  ncol = 5,
  nrow = 2,
  title_adj = 2
)
```

![No Paths from fy to fx](demo_obs_3_no_paths-1.png)

No Paths from fy to fx

### Chaining the Selections

The selectors can be chained together using `|>`.

``` r

p5 <- p |>
  must_have_paths(
    y_on_x = "fy ~ fx"
  ) |>
  must_not_be_y(
    vars = "fx"
  )
plot(
  p5,
  ncol = 5,
  nrow = 1,
  title_adj = 2
)
```

![Chained Filter](demo_obs_3_chained-1.png)

Chained Filter

## Final Remarks

### Customize the Search

There are many other ways to customize the search and the plots. Please
refer to the corresponding halp pages for details.

Demonstrations of other models and cases can be found in the [other
demonstration
articles](https://sfcheung.github.io/semeqmodels/articles/index.html#demonstrations)

### Equivalence-In-Principle and Empirical Equivalence

The concept of mathematically equivalence models, or two models being
equivalent in principle (Lee & Hershberger, 1990), has a long history in
the literature on structural equation modeling Williams (2012). Two
models are considered to be mathematically equivalent if they
necessarily imply the same covariance matrix regardless of the data.
There are methods to generate them and tools to generate them
automatically (e.g., Lee & Hershberger, 1990).

Our definition of empirical equivalence is similar to *empirical
occurrence of equivalence* (EOE, Lee & Hershberger, 1990). However, we
include the requirement of equal degrees of freedom: two models must
also be equal in parsimony. We also allow for the possibility of using
any fit measures deem appropriate (e.g., CFI, RMSEA), and also the use
of tolerance values that are appropriate for a situation.

Although our focus is on empirical equivalence, two models that are
mathematically equivalent in the conventional sense are necessarily
empirically equivalent. Note that the reverse is not true: two models
that are empirically equivalent are not necessarily mathematically
equivalent.

Nevertheless, when the tolerance is set to be very small, the models
identified, though not necessarily, are likely to be mathematically
equivalent. Therefore, the package can also be used to identify models
that are likely mathematically equivalent.

## Reference(s)

Lee, S., & Hershberger, S. (1990). A simple rule for generating
equivalent models in covariance structure modeling. *Multivariate
Behavioral Research*, *25*(3), 313–334.
<https://doi.org/10.1207/s15327906mbr2503_4>

MacCallum, R. C., Wegener, D. T., Uchino, B. N., & Fabrigar, L. R.
(1993). The problem of equivalent models in applications of covariance
structure analysis. *Psychological Bulletin*, *114*(1), 185–199.
<https://doi.org/10.1037/0033-2909.114.1.185>

Williams, L. J. (2012). Equivalent models: Concepts, problems,
alternatives. In R. H. Hoyle (Ed.), *Handbook of Structural Equation
Modeling*. The Guilford Press.
