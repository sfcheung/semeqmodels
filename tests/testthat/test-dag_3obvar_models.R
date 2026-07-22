# Use a DAG package to generate
# a set of equivalent models from
# a simple mediation model.
# This set will be used in tests.

library(testthat)
skip_on_cran()

skip_if_not_installed("dagitty")

test_that("Against DAG: 3obvar", {
library(dagitty)

# ==== Generate equivalent DAGs ====

# From DAG
g <- dagitty(
"dag{
  fx -> fm -> fy;
  fx -> fy
}"
)
g_out <- equivalentDAGs(g)

# Convert to lavaan models

g_out_lavaan <- lapply(
  g_out,
  dag_to_lavaan
)

# Fit the lavaan models
g_fit <- lapply(
  g_out_lavaan,
  \(x) {lavaan::sem(
      model = x,
      fixed.x = FALSE,
      do.fit = FALSE
    )
  }
)
names(g_fit) <- sapply(g_fit, digest_partable)

# Generate eq_partables
out <- do.call(eq_partables, g_fit)

# Generate models from eq_models
out1 <- eq_models(
          original_model = lavaan::parameterTable(g_fit[[1]]),
          parallel = FALSE,
          progress = !is_testing()
        )

# Check whether all DAG models in the output of eq_models()
expect_all_true(out %pt_in% out1)

})
