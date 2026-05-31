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

fit_1_more_1_less <- combine_partables(fit_1_more_1_less)

# Tests

# any

out <- have_pars_any(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm"),
  output = "logical"
)
chk <- fit_1_more_1_less[out]
chk1 <- has_par_i(chk[[1]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[1]], parse_pars_to_list("fm ~~ fx")[[1]])
chk2 <- has_par_i(chk[[2]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[2]], parse_pars_to_list("fm ~~ fx")[[1]])
expect_all_true(c(chk1, chk2))
out2 <- have_pars_any(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm"),
  output = "models"
)
expect_setequal(
  unname(get_digest_partables(chk)),
  unname(get_digest_partables(out2))
)

# all

out <- have_pars_all(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm"),
  output = "logical"
)
expect_all_false(out)
out2 <- have_pars_all(
  fit_1_more_1_less,
  pars = c("fx~fm", "fx~~fm"),
  output = "models"
)
expect_true(length(out2) == 0)

# none

out <- have_pars_none(
  fit_1_more_1_less,
  pars = c("fx~fm", "fy~~fm"),
  output = "logical"
)
chk <- fit_1_more_1_less[out]
chk1 <- has_par_i(chk[[1]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[1]], parse_pars_to_list("fm ~~ fy")[[1]])
chk2 <- has_par_i(chk[[2]], parse_pars_to_list("fx ~ fm")[[1]]) ||
        has_par_i(chk[[2]], parse_pars_to_list("fm ~~ fy")[[1]])
expect_all_false(c(chk1, chk2))
out2 <- have_pars_none(
  fit_1_more_1_less,
  pars = c("fm~~fy", "fx~fm"),
  output = "models"
)
expect_setequal(
  unname(get_digest_partables(chk)),
  unname(get_digest_partables(out2))
)

# must_not_be_y

out <- must_not_be_y(
          fit_1_more_1_less,
          vars = "fx"
        )
expect_all_false(sapply(out, \(x) "fx" %in% lavNames(x, "lv.nox")))

out <- must_not_be_y(
          fit_1_more_1_less,
          vars = "fy"
        )
expect_length(out, 0)

out <- must_not_be_y(
          fit_1_more_1_less,
          vars = "fm"
        )
expect_all_false(sapply(out, \(x) "fm" %in% lavNames(x, "lv.nox")))

out <- must_not_be_y(
          fit_1_more_1_less,
          vars = c("fy", "fm")
        )
expect_length(out, 0)

out <- must_not_be_y(
          fit_1_more_1_less,
          vars = c("fx", "fm")
        )
expect_all_false(sapply(out, \(x) "fm" %in% lavNames(x, "lv.nox")))
expect_all_false(sapply(out, \(x) "fx" %in% lavNames(x, "lv.nox")))

# must_be_y

out <- must_be_y(
          fit_1_more_1_less,
          vars = "fx"
        )
expect_all_true(sapply(out, \(x) "fx" %in% lavNames(x, "lv.nox")))

out <- must_be_y(
          fit_1_more_1_less,
          vars = "fy"
        )
expect_length(out, 4)

out <- must_be_y(
          fit_1_more_1_less,
          vars = "fm"
        )
expect_all_true(sapply(out, \(x) "fm" %in% lavNames(x, "lv.nox")))

out <- must_be_y(
          fit_1_more_1_less,
          vars = c("fy", "fm")
        )
expect_length(out, 4)

out <- must_be_y(
          fit_1_more_1_less,
          vars = c("fx", "fm")
        )
expect_all_true(sapply(out, \(x) "fm" %in% lavNames(x, "lv.nox")) |
                sapply(out, \(x) "fx" %in% lavNames(x, "lv.nox")))

# must_not_have_paths

out <- must_not_have_paths(
          fit_1_more_1_less,
          y_on_x = "fy ~ fx"
        )
expect_length(out, 0)

out <- must_not_have_paths(
          fit_1_more_1_less,
          y_on_x = "fx ~ fy"
        )
expect_length(out, 4)

out <- must_not_have_paths(
          fit_1_more_1_less,
          y_on_x = "fm ~ fx"
        )
expect_length(out, 2)

out <- must_not_have_paths(
          fit_1_more_1_less,
          y_on_x = "fm ~ x"
        )
expect_length(out, 4)

out <- must_not_have_paths(
          fit_1_more_1_less,
          y_on_x = c("fm ~ fx", "fx ~ fy")
        )
expect_length(out, 2)


# must_have_paths

out <- must_have_paths(
          fit_1_more_1_less,
          y_on_x = "fy ~ fx"
        )
expect_length(out, 4)

out <- must_have_paths(
          fit_1_more_1_less,
          y_on_x = "fx ~ fy"
        )
expect_length(out, 0)

out <- must_have_paths(
          fit_1_more_1_less,
          y_on_x = "fm ~ fx"
        )
expect_length(out, 2)

out <- must_have_paths(
          fit_1_more_1_less,
          y_on_x = "fm ~ x"
        )
expect_length(out, 0)

out <- must_have_paths(
          fit_1_more_1_less,
          y_on_x = c("fm ~ fx", "fx ~ fy")
        )
expect_length(out, 2)

})
