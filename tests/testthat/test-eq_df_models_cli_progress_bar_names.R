library(testthat)

test_that("eq_df_models: 3 latent factors: Check names", {

skip_on_cran()

suppressMessages(library(lavaan))

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3_factor_3_item
        ))
pt <- parameterTable(fit)

# Set seed for reproducible results
set.seed(1)
out <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = TRUE
)
if (!is_testing()) {
print(out,
      names_to_use = "long")
}

# Set seed for reproducible results
set.seed(1)
out2 <- eq_df_models(
  sem_out = fit,
  parallel = FALSE,
  progress = FALSE
)
if (!is_testing()) {
print(out2,
      names_to_use = "long")
}

chk1 <- sapply(
  out,
  attr,
  which = "gen_models_name"
)
chk2 <- sapply(
  out2,
  attr,
  which = "gen_models_name"
)
expect_identical(
  chk1,
  chk2
)

})


test_that("eq_df_models: 3 latent factors: Check names", {

skip_if_not(interactive())

suppressMessages(library(lavaan))

mod <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
fm ~ fx
fy ~ fm + fx
"
fit <- do.call(
          sem,
          list(
            model = mod,
            data = data_test_3_factor_3_item
        ))
pt <- parameterTable(fit)

# Set seed for reproducible results
set.seed(1)
out <- eq_df_models(
  sem_out = fit,
  parallel = TRUE,
  progress = TRUE
)
if (!is_testing()) {
print(out,
      names_to_use = "long")
}

# Set seed for reproducible results
set.seed(1)
out2 <- eq_df_models(
  sem_out = fit,
  parallel = TRUE,
  progress = FALSE
)
if (!is_testing()) {
print(out2,
      names_to_use = "long")
}

chk1 <- sapply(
  out,
  attr,
  which = "gen_models_name"
)
chk2 <- sapply(
  out2,
  attr,
  which = "gen_models_name"
)
expect_identical(
  chk1,
  chk2
)

})
