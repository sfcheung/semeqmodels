library(testthat)
suppressMessages(library(lavaan))

# No need to fit the model.
# Only the parameter tables are needed.

mod_measurement <-
  "
  fx =~ x1 + x2 + x3
  fm1 =~ m1 + m2 + m3
  fm2 =~ m4 + m5 + m6
  fy =~ y1 + y2 + y3
  "

mod1 <- c(
  mod_measurement,
  "fm1 ~~ fx",
  "fy ~~ fm1",
  "fy ~~ fm2",
  "fx ~~ fm2",
  "fm1 ~~ fm2",
  "fy ~~ fx"
)

mod2 <- c(
  mod_measurement,
  "fm1 ~ fx",
  "fy ~~ fm1",
  "fy ~~ fm2",
  "fm2 ~ fx",
  "fm1 ~~ fm2",
  "fy ~ fx"
)

mod3 <- c(
  mod_measurement,
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fx ~~ fm2",
  "fy ~~ fx",
  "fy ~~ fm2"
)

mod4 <- c(
  mod_measurement,
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fx ~~ fm1",
  "fy ~~ fx",
  "fy ~~ fm1"
)

mod5 <- c(
  mod_measurement,
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fx ~~ fm1",
  "fx ~~ fm2",
  "fm1 ~~ fm2"
)

mod6 <- c(
  mod_measurement,
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fx ~~ fm1",
  "fm2 ~~ fy"
)

mod7 <- c(
  mod_measurement,
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fx ~~ fm2",
  "fm1 ~~ fy"
)

mod8 <- c(
  mod_measurement,
  "fx ~~ fy",
  "fm1 ~~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod9 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fx ~~ fy",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod10 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fx ~~ fm2",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod11 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fx ~~ fm1",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod12 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fx ~~ fm2",
  "fm1 ~~ fm2",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod13 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fx ~~ fy",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod14 <- c(
  mod_measurement,
  "fx ~~ fm2",
  "fx ~~ fy",
  "fm2 ~~ fy",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod15 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm1 ~~ fy",
  "fm2 ~~ fy",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod16 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod17 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod18 <- c(
  mod_measurement,
  "fx ~~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fy ~ fm1"
)

mod19 <- c(
  mod_measurement,
  "fx ~~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod20 <- c(
  mod_measurement,
  "fx ~~ fy",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fm1"
)

mod21 <- c(
  mod_measurement,
  "fx ~~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm1 ~ fm2"
)

mod22 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2",
  "fy ~ fx"
)

mod23 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fy ~ fm1",
  "fy ~ fm2",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod24 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fx"
)

mod25 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fx ~ fm1",
  "fx ~ fy",
  "fx ~ fm2"
)

mod26 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fx"
)

mod27 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fx ~ fm2",
  "fx ~ fy",
  "fx ~ fm1"
)

mod28 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm1 ~ fx",
  "fm2 ~ fx",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod29 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fm1 ~ fx",
  "fy ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod30 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod31 <- c(
  mod_measurement,
  "fx ~~ fm2",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fy ~ fx",
  "fy ~ fm2"
)

mod32 <- c(
  mod_measurement,
  "fx ~~ fy",
  "fx ~ fm1",
  "fy ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod33 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod34 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fy ~ fx",
  "fy ~ fm1"
)

mod35 <- c(
  mod_measurement,
  "fx ~~ fy",
  "fx ~ fm2",
  "fy ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fy"
)

mod36 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fx ~ fm2",
  "fx ~ fm1",
  "fx ~ fy"
)

mod37 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fm1"
)

mod38 <- c(
  mod_measurement,
  "fx ~~ fm2",
  "fx ~ fy",
  "fm2 ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fm2"
)

mod39 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fx ~ fy",
  "fx ~ fm1",
  "fx ~ fm2"
)

mod40 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fm1 ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1"
)

mod41 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2"
)

mod42 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fy ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod43 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fy ~ fm1",
  "fy ~ fx"
)

mod44 <- c(
  mod_measurement,
  "fx ~~ fy",
  "fm2 ~ fm1",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod45 <- c(
  mod_measurement,
  "fx ~~ fm2",
  "fy ~ fm1",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod46 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fy ~ fm2",
  "fy ~ fx"
)

mod47 <- c(
  mod_measurement,
  "fx ~~ fy",
  "fm1 ~ fm2",
  "fx ~ fm2",
  "fx ~ fm1",
  "fy ~ fm2",
  "fy ~ fm1"
)

mod48 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fy ~ fm2",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod49 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fx"
)

mod50 <- c(
  mod_measurement,
  "fx ~~ fm2",
  "fm1 ~ fy",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fm1"
)

mod51 <- c(
  mod_measurement,
  "fx ~~ fm1",
  "fm2 ~ fy",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fm2"
)

mod52 <- c(
  mod_measurement,
  "fm1 ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod53 <- c(
  mod_measurement,
  "fm1 ~ fx",
  "fy ~ fx",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod54 <- c(
  mod_measurement,
  "fm2 ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fy ~ fm1"
)

mod55<- c(
  mod_measurement,
  "fm2 ~ fx",
  "fy ~ fx",
  "fy ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod56 <- c(
  mod_measurement,
  "fy ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fm1"
)

mod57 <- c(
  mod_measurement,
  "fy ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm1 ~ fm2"
)

mod58<- c(
  mod_measurement,
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fy ~ fm1",
  "fy ~ fx",
  "fy ~ fm2"
)

mod59 <- c(
  mod_measurement,
  "fx ~ fm1",
  "fy ~ fm1",
  "fy ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod60 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2",
  "fy ~ fx"
)

mod61 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fy ~ fm2",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod62 <- c(
  mod_measurement,
  "fy ~ fm1",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fx"
)

mod63 <- c(
  mod_measurement,
  "fy ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fx ~ fm1",
  "fx ~ fy",
  "fx ~ fm2"
)

mod64 <- c(
  mod_measurement,
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fy ~ fm2",
  "fy ~ fx",
  "fy ~ fm1"
)

mod65 <- c(
  mod_measurement,
  "fx ~ fm2",
  "fy ~ fm2",
  "fy ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fy"
)

mod66 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fx ~ fm2",
  "fx ~ fm1",
  "fy ~ fm2",
  "fy ~ fm1",
  "fy ~ fx"
)

mod67 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fy ~ fm1",
  "fx ~ fm2",
  "fx ~ fm1",
  "fx ~ fy"
)

mod68 <- c(
  mod_measurement,
  "fy ~ fm2",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fx"
)

mod69 <- c(
  mod_measurement,
  "fy ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fx ~ fm2",
  "fx ~ fy",
  "fx ~ fm1"
)

mod70 <- c(
  mod_measurement,
  "fx ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fm1"
)

mod71 <- c(
  mod_measurement,
  "fx ~ fy",
  "fm2 ~ fy",
  "fm2 ~ fx",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fm2"
)

mod72 <- c(
  mod_measurement,
  "fm1 ~ fy",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fx"
)

mod73 <- c(
  mod_measurement,
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fm2 ~ fm1",
  "fx ~ fy",
  "fx ~ fm1",
  "fx ~ fm2"
)

mod74 <- c(
  mod_measurement,
  "fm2 ~ fy",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fx"
)

mod75 <- c(
  mod_measurement,
  "fm2 ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fm2",
  "fx ~ fy",
  "fx ~ fm2",
  "fx ~ fm1"
)

system.time(
  pt_list_4_lav <- lapply(
    seq_len(75),
    \(x) {
      fit <- sem(
        model = get(paste0("mod", x)),
        data  = data_test_4_factor_3_item,
        do.fit = FALSE
      )
      parameterTable(fit)
    }
  )
)
