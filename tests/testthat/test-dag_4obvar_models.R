# Use a DAG package to generate
# a set of equivalent models from
# a serial mediation model or just
# a model with four variables.
# This set will be used in tests.

library(testthat)
skip_on_cran()

skip_if_not_installed("dagitty")

test_that("Against DAG: 4obvar", {

  library(dagitty)

  # ==== Generate equivalent DAGs ====

  # This model corresponds to mod52 in helper-4obvar_models.R.
  g <- dagitty(
    "dag{
      fx -> fm1;
      fx -> fm2;
      fx -> fy;
      fm1 -> fm2;
      fm1 -> fy;
      fm2 -> fy
    }"
  )

  g_out <- equivalentDAGs(g)

  # A complete four-variable DAG has 4! equivalent DAGs.
  expect_length(g_out, 24)

  # Convert the equivalent DAGs to lavaan models.
  g_out_lavaan <- lapply(
    g_out,
    dag_to_lavaan
  )

  # Create lavaan objects without fitting the models.
  g_fit <- lapply(
    g_out_lavaan,
    \(x) {
      lavaan::sem(
        model = x,
        fixed.x = FALSE,
        do.fit = FALSE
      )
    }
  )

  names(g_fit) <- sapply(g_fit, digest_partable)

  # Check that the 24 DAGs remain distinct after conversion.
  expect_length(unique(names(g_fit)), 24)

  # Generate parameter tables for the DAG reference set.
  out <- do.call(eq_partables, g_fit)

  # Use the explicitly specified original DAG for eq_models().
  g_original_fit <- lavaan::sem(
    model = dag_to_lavaan(g),
    fixed.x = FALSE,
    do.fit = FALSE
  )

  # Use the pre-generated models
  # It is OK because eq_models() also use the same tests.
  # So, this test checks the "answers" used to test eq_models()
  # An indirect way to compare dagitty and eq_models()

  out1 <- do.call(eq_partables, pt_list_4_obv)
  names(out1) <- sapply(out1, digest_partable)

  # # The following is too slow if run without parallel
  # out1 <- eq_models(
  #   original_model = lavaan::parameterTable(g_original_fit),
  #   parallel = FALSE,
  #   progress = !is_testing()
  # )

  # Check whether all equivalent DAGs are identified by eq_models().
  expect_all_true(out %pt_in% out1)

})