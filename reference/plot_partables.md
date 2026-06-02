# Plot Functions for a List of Parameter Tables

Various plot functions for the output of
[`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
and similar functions.

## Usage

``` r
partables_plots(
  partables,
  ...,
  original_model = NULL,
  auto_node_color = TRUE,
  par_diff_settings = list(color = "blue", width = 2),
  fix_pars_fixed_zero = TRUE,
  par_fixed_zero_settings = list(color = "white", width = 0),
  exclude_original_model = TRUE
)

# S3 method for class 'partables_plots'
plot(
  x,
  ...,
  title_mode = c("digest", "name", "none"),
  title_adj = 1.4,
  title_args = list(),
  ncol = 1,
  nrow = 1,
  scale_plots = c("auto", "always"),
  scale = NULL,
  elements_to_scale = c("Nodes:width", "Nodes:height", "Edges:width", "Edges:asize"),
  original_model_mode = c("exclude", "include", "side_by_side")
)
```

## Arguments

- partables:

  It should be a list of parameter tables, such as the output of
  [`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
  or
  [`eq_df_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_df_models.md).

- ...:

  Optional arguments to be passed to
  [`semPlot::semPaths()`](https://rdrr.io/pkg/semPlot/man/semPaths.html).

- original_model:

  The model to which models in `partables` will be compared to. If
  `NULL`, then the plots will be generated without checking for
  differences between a model and `original_model`.

- auto_node_color:

  If `TRUE`, and the number of nodes is less 12 or less, they will be
  automatically set to different colors. Ignored if `color` of nodes is
  in `...`.

- par_diff_settings:

  A named list of settings to configure the change of a parameter from
  `original_model` to a model in `partables`. For now, two settings are
  supported: `color` for the color and `width` for the width of an edge
  (arrow).

- fix_pars_fixed_zero:

  If `TRUE`, parameters fixed to zero will be modified based on
  `par_fixed_zero_settings`.

- par_fixed_zero_settings:

  A named settings to configure edges (arrows) fixed to zero. For now,
  two settings are supported: `color` for the color and `width` for the
  width of an edge (arrow). Setting the width to zer0, the default,
  effectively hide an arrow.

- exclude_original_model:

  If `TRUE` and `original_model` is set, the output will not include the
  plot of the original model, though this plot will be stored in the
  attribute `"original_model"`, as a one-element list.

- x:

  The output of `partables_plots()`, a `partables_plots` object.

- title_mode:

  What will be used as the title. If `"digest"`, then the digest value
  of a model will be used as its title. If `"name"`, then its name in
  `x` will be used. If `"none"`, then no title will be drawn with the
  plot.

- title_adj:

  Adjust the position of the title. Increase this value if the plot is
  too close to the title, and decrease this value if the space between
  the plot and its title is too large.

- title_args:

  A named list of arguments to be passed to
  [`title()`](https://rdrr.io/r/graphics/title.html) when printing the
  title.

- ncol, nrow:

  The number of columns and rows when drawing the models. Used by
  `mfrow` in [`par()`](https://rdrr.io/r/graphics/par.html).

- scale_plots:

  How the models will be scaled. If `"auto"`, then the models will be
  scaled based on `ncol` and `nrow`, using `scale` as a reference. If
  `"always"`, then `scale` will always be used to scale the models, even
  if they are drawn one by one.

- scale:

  How the model will be furthered scaled when drawn. If this value is
  greater than one, then elements in `elements_to_scale` will be
  increased by this ratio. If this value is less than one, then elements
  in `elements_to_scale` will be decreased by this ratio.

- elements_to_scale:

  Elements in the `qgraph` object that will be scaled based on the
  values of `scale_plots` and `scale`.

- original_model_mode:

  How original model, if present will be handled when drawing the
  models. If `"exclude"`, then the original model will not be drawn. If
  `"include"`, the original model will be drawn as the first model,
  along with other models. If `"side_by_side"`, then number of columns
  is always two and the number of rows is always one. In each plot, the
  original model will be drawn on the left and the other model will be
  drawn on the right.

## Value

The function `partables_plots()` returns a list of `qgraph` objects
generated from
[`semPlot::semPaths()`](https://rdrr.io/pkg/semPlot/man/semPaths.html),
of the class `partables_plots`.

The `plot` method of the output of `partables_plots()` return `x`
invisibly. Called for its side effect.

## Details

The functions provide different ways to visualize the models. Basic
knowledge of
[`semPlot::semPaths()`](https://rdrr.io/pkg/semPlot/man/semPaths.html)
from the package `semPlot` is required.

## See also

See
[`eq_models()`](https://sfcheung.github.io/semeqmodels/reference/eq_models.md)
on the type of output supported.

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
eq_out_1 <- eq_models(
          partables1,
          original_model = fit1,
          parallel = FALSE
        )
#> Error in FUN(X[[i]], ...): object 'partables1' not found

eq_out_1 <- eq_models(
          partables1,
          original_model = fit1,
          parallel = FALSE
        )
#> Error in FUN(X[[i]], ...): object 'partables1' not found

layout_i <- matrix(c(  NA, "fm",  NA,
                     "fx",   NA, "fy"),
                   ncol = 3,
                   nrow = 2,
                   byrow = TRUE)
layout_i
#>      [,1] [,2] [,3]
#> [1,] NA   "fm" NA  
#> [2,] "fx" NA   "fy"
p <- partables_plots(
  eq_out_1,
  original_model = fit1,
  layout = layout_i,
  label.cex = 1.8,
  sizeMan = 11,
  edge.width = 5,
  asize = 5,
  structural = TRUE,
  par_diff_settings = list(
            color = "blue",
            width = 10
          )
)
#> Error: object 'eq_out_1' not found
plot(p)
#> Error: object 'p' not found

```
