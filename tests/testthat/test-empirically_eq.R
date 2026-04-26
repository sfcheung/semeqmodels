library(testthat)
suppressMessages(library(lavaan))

test_that("Empirically equivalent", {

empirical_eq <- function(
  ptables,
  sem_out,
  parallel = TRUE,
  ncores = max(parallel::detectCores(logical = FALSE) - 1, 1),
  make_cluster_args = list(),
  progress = TRUE,
  tolerance = 1e-5
) {

  # Keep models which are empirically equivalent
  # Input:
  # - The output of model_set()
  # - The original fit
  # NOTE:
  # - Empirical in-sample equivalence is used for now,
  #   not mathematical equivalence.

  # Assume ptables are unique
  # TODO:
  # - Keep only unique ptables

  sem_out_df <- unname(lavaan::fitMeasures(sem_out, "df"))
  sem_out_chisq <- unname(lavaan::fitMeasures(sem_out, "chisq"))

  fits <- modelbpp::fit_many(
            model_list = ptables,
            sem_out = sem_out,
            parallel = parallel,
            ncores = ncores,
            make_cluster_args = make_cluster_args,
            progress = progress
          )

  # TODO:
  # - Handle nonconvergence cases
  #   Models failed post.check can be kept

  dfs <- sapply(
    fits$fit,
    function(x) lavaan::fitMeasures(x, "df")
  )
  chisqs <- sapply(
    fits$fit,
    function(x) lavaan::fitMeasures(x, "chisq")
  )

  df_eq <- dfs == sem_out_df
  chisq_eq <- abs(chisqs - sem_out_chisq) <= tolerance

  i <- df_eq & chisq_eq

  ptables_eq <- ptables[i]
  class(ptables_eq) <- class(ptables)

  ptables_eq
}


mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- sem(
          model = mod,
          data = data_test_3_factor_3_item
        )
fit_1_more1 <- drop_k(fit)

fit_1_more_1_less <- lapply(
  fit_1_more1,
  add_k
)

mod2 <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3 + m3
fm ~ fx
fy ~ fm
"
fit2 <- sem(
          model = mod2,
          data = data_test_3_factor_3_item
        )
fit_2_more1 <- drop_k(fit2)

fit_2_more_1_less <- lapply(
  fit_2_more1,
  add_k
)

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
fit_3_more1 <- drop_k(fit3)

fit_3_more_1_less <- lapply(
  fit_3_more1,
  add_k
)

out0 <- combine_ptables(fit_1_more_1_less)

out0_not_eq <- combine_ptables(c(fit_1_more_1_less,
                                 fit_2_more_1_less))

out3 <- combine_ptables(fit_3_more_1_less)

fit0 <- lapply(
  out0,
  \(x) lavaan::update(fit,
                      model = x)
)

df0 <- sapply(
        fit0,
        \(x) fitMeasures(x, "df")
      )
df0

chisq0 <- sapply(
        fit0,
        \(x) fitMeasures(x, "chisq")
      )
chisq0

fit0_not_eq <- lapply(
  out0_not_eq,
  \(x) lavaan::update(fit,
                      model = x)
)

df0_not_eq <- sapply(
        fit0_not_eq,
        \(x) fitMeasures(x, "df")
      )
df0_not_eq

chisq0_not_eq <- sapply(
        fit0_not_eq,
        \(x) fitMeasures(x, "chisq")
      )
chisq0_not_eq

fit_list_3 <- lapply(
  out3,
  \(x) lavaan::update(fit3,
                      model = x)
)

df3 <- sapply(
        fit_list_3,
        \(x) fitMeasures(x, "df")
      )
df3

chisq3 <- sapply(
        fit_list_3,
        \(x) fitMeasures(x, "chisq")
      )
chisq3

eq_out_1 <- empirical_eq(
          out0,
          sem_out = fit,
          parallel = FALSE,
          progress = !is_testing()
        )

eq_out_2 <- empirical_eq(
          out0_not_eq,
          sem_out = fit,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_setequal(
  names(eq_out_1),
  names(eq_out_2)
)

expect_setequal(
  unname(sapply(eq_out_1, get_digest)),
  unname(sapply(eq_out_2, get_digest))
)

eq_out_3 <- empirical_eq(
          out3,
          sem_out = fit3,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_true(length(eq_out_3) == 1)

})
