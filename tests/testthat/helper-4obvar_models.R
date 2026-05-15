library(testthat)
suppressMessages(library(lavaan))

# No need to fit the model.
# Only the parameter tables are needed.

mod1 <- c(
  "fm1 ~~ fx",
  "fy ~~ fm1",
  "fy ~~ fm2",
  "fx ~~ fm2",
  "fm1 ~~ fm2",
  "fy ~~ fx"
)

mod2 <- c(
  "fm1 ~ fx",
  "fy ~~ fm1",
  "fy ~~ fm2",
  "fm2 ~ fx",
  "fm1 ~~ fm2",
  "fy ~ fx"
)

mod3 <- c(
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fx ~~ fm2",
  "fy ~~ fx",
  "fy ~~ fm2"
)

mod4 <- c(
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fx ~~ fm1",
  "fy ~~ fx",
  "fy ~~ fm1"
)

mod5 <- c(
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fx ~~ fm1",
  "fx ~~ fm2",
  "fm1 ~~ fm2"
)

mod6 <- c(
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fx ~~ fm1",
  "fm2 ~~ fy"
)

mod7 <- c(
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fx ~~ fm2",
  "fm1 ~~ fy"
)

mod8 <- c(
  "fx ~~ fy",
  "fm1 ~~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod9 <- c(
  "fm1 ~~ fm2",
  "fx ~~ fy",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod10 <- c(
  "fm1 ~~ fy",
  "fx ~~ fm2",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod11 <- c(
  "fm2 ~~ fy",
  "fx ~~ fm1",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod12 <- c(
  "fx ~~ fm1",
  "fx ~~ fm2",
  "fm1 ~~ fm2",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod13 <- c(
  "fx ~~ fm1",
  "fx ~~ fy",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod14 <- c(
  "fx ~~ fm2",
  "fx ~~ fy",
  "fm2 ~~ fy",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod15 <- c(
  "fm1 ~~ fm2",
  "fm1 ~~ fy",
  "fm2 ~~ fy",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod16 <- c(
  "fx ~~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod17 <- c(
  "fx ~~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod18 <- c(
  "fx ~~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fy ~ fm1"
)

mod19 <- c(
  "fx ~~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod20 <- c(
  "fx ~~ fy",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fm1"
)

mod21 <- c(
  "fx ~~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm1 ~ fm2"
)

mod22 <- c(
  "fm1 ~~ fm2",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2",
  "fy ~ fx"
)

mod23 <- c(
  "fm1 ~~ fm2",
  "fy ~ fm1",
  "fy ~ fm2",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod24 <- c(
  "fm1 ~~ fy",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fx"
)

mod25 <- c(
  "fm1 ~~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fx ~ fm1",
  "fx ~ fy",
  "fx ~ fm2"
)

mod26 <- c(
  "fm2 ~~ fy",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fx"
)

mod27 <- c(
  "fm2 ~~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fx ~ fm2",
  "fx ~ fy",
  "fx ~ fm1"
)

mod28 <- c(
  "fm1 ~~ fm2",
  "fm1 ~ fx",
  "fm2 ~ fx",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod29 <- c(
  "fm1 ~~ fy",
  "fm1 ~ fx",
  "fy ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod30 <- c(
  "fm2 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod31 <- c(
  "fx ~~ fm2",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fy ~ fx",
  "fy ~ fm2"
)

mod32 <- c(
  "fx ~~ fy",
  "fx ~ fm1",
  "fy ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod33 <- c(
  "fm2 ~~ fy",
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod34 <- c(
  "fx ~~ fm1",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fy ~ fx",
  "fy ~ fm1"
)

mod35 <- c(
  "fx ~~ fy",
  "fx ~ fm2",
  "fy ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fy"
)

mod36 <- c(
  "fm1 ~~ fy",
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fx ~ fm2",
  "fx ~ fm1",
  "fx ~ fy"
)

mod37 <- c(
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fm1"
)

mod38 <- c(
  "fx ~~ fm2",
  "fx ~ fy",
  "fm2 ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fm2"
)

mod39 <- c(
  "fm1 ~~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fx ~ fy",
  "fx ~ fm1",
  "fx ~ fm2"
)

mod40 <- c(
  "fm2 ~~ fy",
  "fm1 ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1"
)

mod41 <- c(
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2"
)

mod42 <- c(
  "fm1 ~~ fm2",
  "fy ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod43 <- c(
  "fm2 ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fy ~ fm1",
  "fy ~ fx"
)

mod44 <- c(
  "fx ~~ fy",
  "fm2 ~ fm1",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod45 <- c(
  "fx ~~ fm2",
  "fy ~ fm1",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod46 <- c(
  "fm1 ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fy ~ fm2",
  "fy ~ fx"
)

mod47 <- c(
  "fx ~~ fy",
  "fm1 ~ fm2",
  "fx ~ fm2",
  "fx ~ fm1",
  "fy ~ fm2",
  "fy ~ fm1"
)

mod48 <- c(
  "fx ~~ fm1",
  "fy ~ fm2",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod49 <- c(
  "fm1 ~~ fm2",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fx"
)

mod50 <- c(
  "fx ~~ fm2",
  "fm1 ~ fy",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fm1"
)

mod51 <- c(
  "fx ~~ fm1",
  "fm2 ~ fy",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fm2"
)

mod52 <- c(
  "fm1 ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fy ~ fx",
  "fy ~ fm1",
  "fy ~ fm2"
)

mod53 <- c(
  "fm1 ~ fx",
  "fy ~ fx",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fy"
)

mod54 <- c(
  "fm2 ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fy ~ fx",
  "fy ~ fm2",
  "fy ~ fm1"
)

mod55<- c(
  "fm2 ~ fx",
  "fy ~ fx",
  "fy ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fy"
)

mod56 <- c(
  "fy ~ fx",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fm1"
)

mod57 <- c(
  "fy ~ fx",
  "fm2 ~ fx",
  "fm2 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fy",
  "fm1 ~ fm2"
)

mod58<- c(
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fy ~ fm1",
  "fy ~ fx",
  "fy ~ fm2"
)

mod59 <- c(
  "fx ~ fm1",
  "fy ~ fm1",
  "fy ~ fx",
  "fm2 ~ fm1",
  "fm2 ~ fx",
  "fm2 ~ fy"
)

mod60 <- c(
  "fm2 ~ fm1",
  "fx ~ fm1",
  "fx ~ fm2",
  "fy ~ fm1",
  "fy ~ fm2",
  "fy ~ fx"
)

mod61 <- c(
  "fm2 ~ fm1",
  "fy ~ fm1",
  "fy ~ fm2",
  "fx ~ fm1",
  "fx ~ fm2",
  "fx ~ fy"
)

mod62 <- c(
  "fy ~ fm1",
  "fx ~ fm1",
  "fx ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fx"
)

mod63 <- c(
  "fy ~ fm1",
  "fm2 ~ fm1",
  "fm2 ~ fy",
  "fx ~ fm1",
  "fx ~ fy",
  "fx ~ fm2"
)

mod64 <- c(
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fy ~ fm2",
  "fy ~ fx",
  "fy ~ fm1"
)

mod65 <- c(
  "fx ~ fm2",
  "fy ~ fm2",
  "fy ~ fx",
  "fm1 ~ fm2",
  "fm1 ~ fx",
  "fm1 ~ fy"
)

mod66 <- c(
  "fm1 ~ fm2",
  "fx ~ fm2",
  "fx ~ fm1",
  "fy ~ fm2",
  "fy ~ fm1",
  "fy ~ fx"
)

mod67 <- c(
  "fm1 ~ fm2",
  "fy ~ fm2",
  "fy ~ fm1",
  "fx ~ fm2",
  "fx ~ fm1",
  "fx ~ fy"
)

mod68 <- c(
  "fy ~ fm2",
  "fx ~ fm2",
  "fx ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fx"
)

mod69 <- c(
  "fy ~ fm2",
  "fm1 ~ fm2",
  "fm1 ~ fy",
  "fx ~ fm2",
  "fx ~ fy",
  "fx ~ fm1"
)

mod70 <- c(
  "fx ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm2 ~ fy",
  "fm2 ~ fx",
  "fm2 ~ fm1"
)

mod71 <- c(
  "fx ~ fy",
  "fm2 ~ fy",
  "fm2 ~ fx",
  "fm1 ~ fy",
  "fm1 ~ fx",
  "fm1 ~ fm2"
)

mod72 <- c(
  "fm1 ~ fy",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fy",
  "fm2 ~ fm1",
  "fm2 ~ fx"
)

mod73 <- c(
  "fm1 ~ fy",
  "fm2 ~ fy",
  "fm2 ~ fm1",
  "fx ~ fy",
  "fx ~ fm1",
  "fx ~ fm2"
)

mod74 <- c(
  "fm2 ~ fy",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fy",
  "fm1 ~ fm2",
  "fm1 ~ fx"
)

mod75 <- c(
  "fm2 ~ fy",
  "fm1 ~ fy",
  "fm1 ~ fm2",
  "fx ~ fy",
  "fx ~ fm2",
  "fx ~ fm1"
)

mod76 <- c(
  "fm2 ~ fm1",
  "fy ~ fm2",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod77 <- c(
  "fm2 ~ fm1",
  "fy ~~ fm2",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod78 <- c(
  "fm2 ~~ fm1",
  "fy ~~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod79 <- c(
  "fm2 ~~ fm1",
  "fy ~ fm2",
  "fm1 ~~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod80 <- c(
  "fm2 ~ fm1",
  "fy ~~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod81 <- c(
  "fm2 ~~ fm1",
  "fy ~ fm2",
  "fm1 ~ fy",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod82 <- c(
  "fm1 ~~ fm2",
  "fm2 ~ fy",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod83 <- c(
  "fm1 ~ fm2",
  "fm2 ~~ fy",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod84 <- c(
  "fm1 ~ fm2",
  "fm2 ~ fy",
  "fy ~~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod85 <- c(
  "fm1 ~~ fm2",
  "fm2 ~~ fy",
  "fy ~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod86 <- c(
  "fm1 ~~ fm2",
  "fm2 ~ fy",
  "fy ~~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod87 <- c(
  "fm1 ~ fm2",
  "fm2 ~~ fy",
  "fy ~~ fm1",
  "fm2 ~ fx",
  "fy ~ fx",
  "fm1 ~ fx"
)

mod88 <- c(
  "fm1 ~~ fm2",
  "fm2 ~ fx",
  "fx ~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod89 <- c(
  "fm1 ~ fm2",
  "fm2 ~~ fx",
  "fx ~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod90 <- c(
  "fm1 ~ fm2",
  "fm2 ~ fx",
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod91 <- c(
  "fm1 ~~ fm2",
  "fm2 ~~ fx",
  "fx ~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod92 <- c(
  "fm1 ~~ fm2",
  "fm2 ~ fx",
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod93 <- c(
  "fm1 ~ fm2",
  "fm2 ~~ fx",
  "fx ~~ fm1",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod94 <- c(
  "fm2 ~~ fm1",
  "fx ~ fm2",
  "fm1 ~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod95 <- c(
  "fm2 ~ fm1",
  "fx ~~ fm2",
  "fm1 ~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod96 <- c(
  "fm2 ~ fm1",
  "fx ~ fm2",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod97 <- c(
  "fm2 ~~ fm1",
  "fx ~~ fm2",
  "fm1 ~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod98 <- c(
  "fm2 ~~ fm1",
  "fx ~ fm2",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod99 <- c(
  "fm2 ~ fm1",
  "fx ~~ fm2",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fm1 ~ fy",
  "fm2 ~ fy"
)

mod100 <- c(
  "fy ~~ fm2",
  "fm2 ~ fx",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod101 <- c(
  "fy ~ fm2",
  "fm2 ~~ fx",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod102 <- c(
  "fy ~ fm2",
  "fm2 ~ fx",
  "fx ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod103 <- c(
  "fy ~~ fm2",
  "fm2 ~~ fx",
  "fx ~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod104 <- c(
  "fy ~~ fm2",
  "fm2 ~ fx",
  "fx ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod105 <- c(
  "fy ~ fm2",
  "fm2 ~~ fx",
  "fx ~~ fy",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod106 <- c(
  "fm2 ~~ fy",
  "fx ~ fm2",
  "fy ~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod107 <- c(
  "fm2 ~ fy",
  "fx ~~ fm2",
  "fy ~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod108 <- c(
  "fm2 ~ fy",
  "fx ~ fm2",
  "fy ~~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod109 <- c(
  "fm2 ~~ fy",
  "fx ~~ fm2",
  "fy ~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod110 <- c(
  "fm2 ~~ fy",
  "fx ~ fm2",
  "fy ~~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod111 <- c(
  "fm2 ~ fy",
  "fx ~~ fm2",
  "fy ~~ fx",
  "fx ~ fm1",
  "fm2 ~ fm1",
  "fy ~ fm1"
)

mod112 <- c(
  "fm1 ~~ fy",
  "fx ~ fm1",
  "fy ~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod113 <- c(
  "fm1 ~ fy",
  "fx ~~ fm1",
  "fy ~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod114 <- c(
  "fm1 ~ fy",
  "fx ~ fm1",
  "fy ~~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod115 <- c(
  "fm1 ~~ fy",
  "fx ~~ fm1",
  "fy ~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod116 <- c(
  "fm1 ~~ fy",
  "fx ~ fm1",
  "fy ~~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod117 <- c(
  "fm1 ~ fy",
  "fx ~~ fm1",
  "fy ~~ fx",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod118 <- c(
  "fy ~~ fm1",
  "fm1 ~ fx",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod119 <- c(
  "fy ~ fm1",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod120 <- c(
  "fy ~ fm1",
  "fm1 ~ fx",
  "fx ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod121 <- c(
  "fy ~~ fm1",
  "fm1 ~~ fx",
  "fx ~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod122 <- c(
  "fy ~~ fm1",
  "fm1 ~ fx",
  "fx ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)

mod123 <- c(
  "fy ~ fm1",
  "fm1 ~~ fx",
  "fx ~~ fy",
  "fx ~ fm2",
  "fm1 ~ fm2",
  "fy ~ fm2"
)



system.time(
  pt_list_4_obv <- lapply(
    seq_len(123),
    \(x) {
      fit <- sem(
        model = get(paste0("mod", x)),
        data  = data_test_4obvs,
        do.fit = FALSE
      )
      parameterTable(fit)
    }
  )
)
