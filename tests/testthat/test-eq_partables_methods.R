library(testthat)
suppressMessages(library(lavaan))

test_that("eq_partables methods", {

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

fit_1_more1_with_fit <- drop_k(fit,
              fit_models = TRUE,
              parallel = FALSE)
fit_1_more1 <- drop_k(fit,
              fit_models = FALSE,
              parallel = FALSE)

fit_1_more_1_less_with_fit <- lapply(
  fit_1_more1_with_fit,
  add_k,
  fit_models = TRUE,
  parallel = FALSE
)

a1 <- fit_1_more_1_less_with_fit[[1]]
a2 <- fit_1_more_1_less_with_fit[[2]]
a3 <- fit_1_more_1_less_with_fit[[3]]

out <- eq_lavInspect(a1, "npar")
expect_all_equal(unlist(out),
                 21)

out <- eq_lavInspect(fit_1_more1, "npar")
expect_all_true(sapply(out, is.null))

out <- eq_fitMeasures(
          fit_1_more1_with_fit,
          fit.measures = c("chisq", "df", "cfi"))
expect_equal(colnames(out),
             names(fit_1_more1_with_fit))
chk <- sapply(
          eq_fits(fit_1_more1_with_fit),
          fitMeasures,
          simplify = TRUE
        )
expect_equal(unlist(out["cfi", ]),
             chk["cfi", ],
             ignore_attr = TRUE)

out <- eq_df(fit_1_more1_with_fit)
expect_equal(out,
             chk["df", ],
             ignore_attr = TRUE)

out <- eq_chisq(fit_1_more1_with_fit)
expect_equal(out,
             chk["chisq", ],
             ignore_attr = TRUE)

a1_1 <- a1[1]
class(a1_1) <- class(a1)
a1_2 <- a1[2]
class(a1_2) <- class(a1)
out1 <- to_eq_partables_list(a1, a2)
out2 <- to_eq_partables_list(a1_1, a2)
out3 <- to_eq_partables_list(list(a1_1, a2))
out4 <- to_eq_partables_list(list(a1_1, a1_2), a2)
out5 <- to_eq_partables_list(a2, list(a1_1, a1_2))
out6 <- to_eq_partables_list(a2, list(a1_1, a1_2), a3)
outc1 <- c(a1, a2)
outc2 <- c(a1_1, a2)
outc5 <- c(a2, list(a1_1, a1_2))
outc6 <- c(a2, list(a1_1, a1_2), a3)
outc7 <- c(a1, a2, a2)
outc8 <- c(a1, a1, a2)
outc9 <- c(a1, a1, a2, drop_duplicated = FALSE)

expect_identical(outc1, out1)
expect_identical(outc2, out2)
expect_identical(outc5, out5)
expect_identical(outc6, out6)
expect_identical(outc1, outc7)
expect_identical(outc1, outc8)
expect_true(any(duplicated(sapply(outc9, get_digest))))
expect_true(any(duplicated(outc9)))
expect_setequal(names(unique(outc9)),
                names(outc8))

expect_s3_class(out1, "eq_partables")
expect_s3_class(out2, "eq_partables")
expect_s3_class(out3, "eq_partables")
expect_s3_class(out4, "eq_partables")
expect_s3_class(out5, "eq_partables")
expect_s3_class(out6, "eq_partables")

expect_equal(
  names(out1),
  c(names(a1), names(a2))
)
expect_equal(
  names(out2),
  c(names(a1_1), names(a2))
)
expect_equal(
  names(out3),
  c(names(a1_1), names(a2))
)
expect_equal(
  names(out4),
  c(names(a1), names(a2))
)
expect_equal(
  names(out5),
  c(names(a2), names(a1))
)
expect_equal(
  names(out5),
  names(out6)
)

})
