library(testthat)
suppressMessages(library(lavaan))

# No need to fit the model.
# Only the parameter tables are needed.

mod_measurement <-
"
fx =~ x1 + x2 + x3
fm =~ m1 + m2 + m3
fy =~ y1 + y2 + y3
"

mod1 <- c(
  mod_measurement,
  "fx ~~ fm",
  "fm ~~ fy",
  "fy ~~ fx"
)
fit1 <- sem(
          model = mod1,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt1 <- parameterTable(fit1)

mod2 <- c(
  mod_measurement,
  "fm ~ fx",
  "fy ~ fx",
  "fm ~~ fy"
)
fit2 <- sem(
          model = mod2,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt2 <- parameterTable(fit2)

mod3 <- c(
  mod_measurement,
  "fx ~ fm",
  "fy ~ fm",
  "fx ~~ fy"
)
fit3 <- sem(
          model = mod3,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt3 <- parameterTable(fit3)

mod4 <- c(
  mod_measurement,
  "fx ~ fy",
  "fm ~ fy",
  "fx ~~ fm"
)
fit4 <- sem(
          model = mod4,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt4 <- parameterTable(fit4)

mod5 <- c(
  mod_measurement,
  "fy ~ fx",
  "fy ~ fm",
  "fx ~~ fm"
)
fit5 <- sem(
          model = mod5,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt5 <- parameterTable(fit5)

mod6 <- c(
  mod_measurement,
  "fm ~ fx",
  "fm ~ fy",
  "fx ~~ fy"
)
fit6 <- sem(
          model = mod6,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt6 <- parameterTable(fit6)

mod7 <- c(
  mod_measurement,
  "fx ~ fm",
  "fx ~ fy",
  "fm ~~ fy"
)
fit7 <- sem(
          model = mod7,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt7 <- parameterTable(fit7)

mod8 <- c(
  mod_measurement,
  "fm ~ fx",
  "fy ~ fm",
  "fy ~ fx"
)
fit8 <- sem(
          model = mod8,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt8 <- parameterTable(fit8)

mod9 <- c(
  mod_measurement,
  "fy ~ fx",
  "fm ~ fy",
  "fm ~ fx"
)
fit9 <- sem(
          model = mod9,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt9 <- parameterTable(fit9)

mod10 <- c(
  mod_measurement,
  "fx ~ fm",
  "fy ~ fx",
  "fy ~ fm"
)
fit10 <- sem(
          model = mod10,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt10 <- parameterTable(fit10)

mod11 <- c(
  mod_measurement,
  "fy ~ fm",
  "fx ~ fy",
  "fx ~ fm"
)
fit11 <- sem(
          model = mod11,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt11 <- parameterTable(fit11)

mod12 <- c(
  mod_measurement,
  "fx ~ fy",
  "fm ~ fx",
  "fm ~ fy"
)
fit12 <- sem(
          model = mod12,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt12 <- parameterTable(fit12)

mod13 <- c(
  mod_measurement,
  "fm ~ fy",
  "fx ~ fm",
  "fx ~ fy"
)
fit13 <- sem(
          model = mod13,
          data = data_test_3_factor_3_item,
          do.fit = FALSE
        )
pt13 <- parameterTable(fit13)

pt_list_3_lav <- list(pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8, pt9, pt10, pt11, pt12, pt13)
