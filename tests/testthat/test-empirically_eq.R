library(testthat)
suppressMessages(library(lavaan))

test_that("Empirically equivalent", {

empirical_eq <- function(
  ptables,
  sem_out,
  ...,
  se = "none",
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

  sem_out1 <- lavaan::update(
    sem_out,
    se = se
  )

  fits <- modelbpp::fit_many(
            model_list = ptables,
            sem_out = sem_out1,
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

# ==== Models ====

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

fit1_1_more_1_less <- lapply(
  fit1_1_more,
  add_k
)

# Model 2

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
fit2_1_more <- drop_k(fit2)

fit2_1_more_1_less <- lapply(
  fit2_1_more,
  add_k
)

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
fit3_1_more <- drop_k(fit3)

fit3_1_more_1_less <- lapply(
  fit3_1_more,
  add_k
)

# ==== Parameter Tables ====

# All equivalent
ptables1 <- combine_ptables(fit1_1_more_1_less)

# Some not equivalent
ptables12 <- combine_ptables(c(fit1_1_more_1_less,
                               fit2_1_more_1_less))

# All equivalent
ptables3 <- combine_ptables(fit3_1_more_1_less)

# ==== Fits ====

fits1 <- lapply(
  ptables1,
  \(x) lavaan::update(fit1,
                      model = x)
)

df1 <- sapply(
        fits1,
        \(x) fitMeasures(x, "df")
      )
df1

chisq1 <- sapply(
        fits1,
        \(x) fitMeasures(x, "chisq")
      )
chisq1

fits12 <- lapply(
  ptables12,
  \(x) lavaan::update(fit1,
                      model = x)
)

df12 <- sapply(
        fits12,
        \(x) fitMeasures(x, "df")
      )
df12

chisq12 <- sapply(
        fits12,
        \(x) fitMeasures(x, "chisq")
      )
chisq12

fits3 <- lapply(
  ptables3,
  \(x) lavaan::update(fit3,
                      model = x)
)

df3 <- sapply(
        fits3,
        \(x) fitMeasures(x, "df")
      )
df3

chisq3 <- sapply(
        fits3,
        \(x) fitMeasures(x, "chisq")
      )
chisq3

eq_out_1 <- empirical_eq(
          ptables1,
          sem_out = fit1,
          parallel = FALSE,
          progress = !is_testing()
        )

eq_out_2 <- empirical_eq(
          ptables12,
          sem_out = fit1,
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
          ptables3,
          sem_out = fit3,
          parallel = FALSE,
          progress = !is_testing()
        )

expect_true(length(eq_out_3) == 1)

})
