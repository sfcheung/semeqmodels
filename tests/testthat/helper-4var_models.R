library(testthat)
suppressMessages(library(lavaan))

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

mod76 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fy ~ fm2",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod77 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fy ~~ fm2",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod78 <- c(
  mod_measurement,
  "fm2 ~~ fm1",
  "fy ~~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod79 <- c(
  mod_measurement,
  "fm2 ~~ fm1",
  "fy ~ fm2",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod80 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fy ~~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod81 <- c(
  mod_measurement,
  "fm2 ~~ fm1",
  "fy ~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod82 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm2 ~ fy",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod83 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~~ fy",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod84 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~ fy",
  "fy ~~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod85 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm2 ~~ fy",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod86 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm2 ~ fy",
  "fy ~~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod87 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~~ fy",
  "fy ~~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod88 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm2 ~ fx",
  "fx ~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod89 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~~ fx",
  "fx ~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod90 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~ fx",
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod91 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm2 ~~ fx",
  "fx ~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod92 <- c(
  mod_measurement,
  "fm1 ~~ fm2",
  "fm2 ~ fx",
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod93 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~~ fx",
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod94 <- c(
  mod_measurement,
  "fm2 ~~ fm1",
  "fx ~ fm2",
  "fm1 ~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod95 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fx ~~ fm2",
  "fm1 ~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod96 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fx ~ fm2",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod97 <- c(
  mod_measurement,
  "fm2 ~~ fm1",
  "fx ~~ fm2",
  "fm1 ~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod98 <- c(
  mod_measurement,
  "fm2 ~~ fm1",
  "fx ~ fm2",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod99 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fx ~~ fm2",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod100 <- c(
  mod_measurement,
  "fy ~~ fm2",
  "fm2 ~ fx",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod101 <- c(
  mod_measurement,
  "fy ~ fm2",
  "fm2 ~~ fx",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod102 <- c(
  mod_measurement,
  "fy ~ fm2",
  "fm2 ~ fx",
  "fx ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod103 <- c(
  mod_measurement,
  "fy ~~ fm2",
  "fm2 ~~ fx",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod104 <- c(
  mod_measurement,
  "fy ~~ fm2",
  "fm2 ~ fx",
  "fx ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod105 <- c(
  mod_measurement,
  "fy ~ fm2",
  "fm2 ~~ fx",
  "fx ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod106 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fx ~ fm2",
  "fy ~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod107 <- c(
  mod_measurement,
  "fm2 ~ fy",
  "fx ~~ fm2",
  "fy ~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod108 <- c(
  mod_measurement,
  "fm2 ~ fy",
  "fx ~ fm2",
  "fy ~~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod109 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fx ~~ fm2",
  "fy ~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod110 <- c(
  mod_measurement,
  "fm2 ~~ fy",
  "fx ~ fm2",
  "fy ~~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod111 <- c(
  mod_measurement,
  "fm2 ~ fy",
  "fx ~~ fm2",
  "fy ~~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod112 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fx ~ fm1",
  "fy ~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod113 <- c(
  mod_measurement,
  "fm1 ~ fy",
  "fx ~~ fm1",
  "fy ~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod114 <- c(
  mod_measurement,
  "fm1 ~ fy",
  "fx ~ fm1",
  "fy ~~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod115 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fx ~~ fm1",
  "fy ~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod116 <- c(
  mod_measurement,
  "fm1 ~~ fy",
  "fx ~ fm1",
  "fy ~~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod117 <- c(
  mod_measurement,
  "fm1 ~ fy",
  "fx ~~ fm1",
  "fy ~~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod118 <- c(
  mod_measurement,
  "fy ~~ fm1",
  "fm1 ~ fx",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod119 <- c(
  mod_measurement,
  "fy ~ fm1",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod120 <- c(
  mod_measurement,
  "fy ~ fm1",
  "fm1 ~ fx",
  "fx ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod121 <- c(
  mod_measurement,
  "fy ~~ fm1",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod122 <- c(
  mod_measurement,
  "fy ~~ fm1",
  "fm1 ~ fx",
  "fx ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod123 <- c(
  mod_measurement,
  "fy ~ fm1",
  "fm1 ~~ fx",
  "fx ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod124 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fy ~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod125 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~ fy",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod126 <- c(
  mod_measurement,
  "fm1 ~ fm2",
  "fm2 ~ fx",
  "fx ~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod127 <- c(
  mod_measurement,
  "fm2 ~ fm1",
  "fx ~ fm2",
  "fm1 ~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod128 <- c(
  mod_measurement,
  "fy ~ fm2",
  "fm2 ~ fx",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod129 <- c(
  mod_measurement,
  "fm2 ~ fy",
  "fx ~ fm2",
  "fy ~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod130 <- c(
  mod_measurement,
  "fm1 ~ fy",
  "fx ~ fm1",
  "fy ~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod131 <- c(
  mod_measurement,
  "fy ~ fm1",
  "fm1 ~ fx",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

system.time(
  pt_list_4_lav <- lapply(
    seq_len(131),
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

