library(testthat)
suppressMessages(library(lavaan))

test_that("eq_partables: select", {

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

# ==== Test: drop_k ====

fit_1_more1 <- drop_k(fit,
              fit_models = FALSE,
              parallel = FALSE)

fit_1_more_1_less <- lapply(
  fit_1_more1,
  add_k,
  fit_models = TRUE,
  parallel = FALSE
)

fit_1_more_1_less <- combine_ptables(fit_1_more_1_less)

# Tests

# any

out <- have_pars_any(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm")
)
chk <- fit_1_more_1_less[out]
chk1 <- has_par_i(chk[[1]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[1]], parse_pars_to_list("fm ~~ fx")[[1]])
chk2 <- has_par_i(chk[[2]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[2]], parse_pars_to_list("fm ~~ fx")[[1]])
expect_all_true(c(chk1, chk2))
out2 <- models_have_pars_any(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm")
)
expect_setequal(
  unname(get_digest_ptables(chk)),
  unname(get_digest_ptables(out2))
)

# all

out <- have_pars_all(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm")
)
expect_all_false(out)
out2 <- models_have_pars_all(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm")
)
expect_true(length(out2) == 0)

# none

out <- have_pars_none(
  fit_1_more_1_less,
  pars = c("fx~fm", "fy~~fm")
)
chk <- fit_1_more_1_less[out]
chk1 <- has_par_i(chk[[1]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[1]], parse_pars_to_list("fm ~~ fy")[[1]])
chk2 <- has_par_i(chk[[2]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[2]], parse_pars_to_list("fm ~~ fy")[[1]])
expect_all_false(c(chk1, chk2))
out2 <- models_have_pars_none(
  fit_1_more_1_less,
  pars = c("fm~~fy", "fx~fm")
)
expect_setequal(
  unname(get_digest_ptables(chk)),
  unname(get_digest_ptables(out2))
)

# Zero length



})
