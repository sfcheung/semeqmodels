# Adapted from https://www.kloppenborg.ca/2021/06/long-running-vignettes/

base_dir <- getwd()

setwd(paste0(base_dir, "/vignettes/"))

knitr::knit("semeqmodels.Rmd.original", output = "semeqmodels.Rmd", envir = new.env())
pkgdown::build_articles(".."); pkgdown::preview_site("../..")

setwd(base_dir)

# For articles

setwd(paste0(base_dir, "/vignettes/articles/"))

pkgdown::build_articles("../.."); pkgdown::preview_site("../..")

setwd(base_dir)
