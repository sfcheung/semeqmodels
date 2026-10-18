library(testthat)
suppressMessages(library(lavaan))

test_that("Summarize models", {

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
fit1 <- do.call(
          sem,
          list(
            model = mod1,
            data = data_test_3_factor_3_item
          )
        )
pt1 <- parameterTable(fit1)

# Only original_model: A lavaan object

set.seed(1)
eq_out_1 <- eq_models(
          original_model = fit1,
          se = "none",
          parallel = FALSE,
          progress = !is_testing()
        )
set.seed(1)
eq_out_1b <- eq_models(
          original_model = fit1,
          se = "standard",
          parallel = FALSE,
          progress = !is_testing(),
          passes = 2
        )

est_summary_1 <- est_summary(eq_out_1)
if (!is_testing()) print(est_summary_1)

est_summary_1b <- est_summary(eq_out_1b)
if (!is_testing()) print(est_summary_1b)

expect_equal(
  est_summary_1$mean,
  est_summary_1b$mean
)
expect_equal(
  est_summary_1$min,
  est_summary_1b$min
)
expect_equal(
  est_summary_1$max,
  est_summary_1b$max
)

expect_true(
  max(est_summary(eq_out_1b, standardized = FALSE)$max) > 1
)
expect_error(est_summary(eq_out_1b, col = "x"))
expect_error(est_summary(eq_out_1b, col = character(0)))

# The following tests added by Copilot
# The summary is a lavaan data frame with one row per parameter.
expect_s3_class(est_summary_1b, "lavaan.data.frame")
expect_identical(
  row.names(est_summary_1b),
  as.character(seq_len(nrow(est_summary_1b)))
)
expect_true(
  all(c("par_label", "lhs", "op", "rhs", "mean", "min", "max", "n") %in%
        names(est_summary_1b))
)

# Only requested aggregate columns should be returned.
mean_summary <- est_summary(eq_out_1b, col = "mean")
expect_true("mean" %in% names(mean_summary))
expect_false(any(c("min", "max", "n") %in% names(mean_summary)))

mean_n_summary <- est_summary(eq_out_1b, col = c("mean", "n"))
expect_true(all(c("mean", "n") %in% names(mean_n_summary)))
expect_false(any(c("min", "max") %in% names(mean_n_summary)))

# Aggregate values should be consistent with each other.
expect_true(all(est_summary_1b$min <= est_summary_1b$max, na.rm = TRUE))
expect_true(all(est_summary_1b$mean >= est_summary_1b$min, na.rm = TRUE))
expect_true(all(est_summary_1b$mean <= est_summary_1b$max, na.rm = TRUE))
expect_true(all(est_summary_1b$n >= 1))

# Standardized variances are reported as R-squares; unstandardized
# output retains the variance parameters.
expect_true(any(est_summary_1b$op == "r2"))
unstandardized_summary <- est_summary(eq_out_1b, standardized = FALSE)
expect_true(any(unstandardized_summary$op == "~~"))
expect_false(any(unstandardized_summary$op == "r2"))

# Without an explicit original-model marker, the first model is used.
eq_out_1b_unmarked <- eq_out_1b
for (i in seq_along(eq_out_1b_unmarked)) {
  attr(eq_out_1b_unmarked[[i]], "is_original") <- NULL
}
eq_out_1b_first_marked <- eq_out_1b_unmarked
attr(eq_out_1b_first_marked[[1]], "is_original") <- TRUE
expect_equal(
  est_summary(eq_out_1b_unmarked),
  est_summary(eq_out_1b_first_marked)
)

# Trimming removes the generated suffix when all parameter labels have it.
untrimmed_summary <- est_summary(eq_out_1b, trim_par_label = FALSE)
trimmed_summary <- est_summary(eq_out_1b, trim_par_label = TRUE)
expected_labels <- untrimmed_summary$par_label
if (all(grepl("\\.1\\.1$", expected_labels))) {
  expected_labels <- sub("\\.1\\.1$", "", expected_labels)
}
expect_setequal(trimmed_summary$par_label, expected_labels)

})
