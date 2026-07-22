# Adapted from https://www.kloppenborg.ca/2021/06/long-running-vignettes/

base_dir <- getwd()

setwd(paste0(base_dir, "/vignettes/"))

knitr::knit("semeqmodels.Rmd.original", output = "semeqmodels.Rmd")

setwd(base_dir)

# For articles

setwd(paste0(base_dir, "/vignettes/articles/"))

knitr::knit("demo_lav_3.Rmd.original", output = "demo_lav_3.Rmd")
knitr::knit("demo_lav_4.Rmd.original", output = "demo_lav_4.Rmd")
knitr::knit("demo_obs_3.Rmd.original", output = "demo_obs_3.Rmd")
knitr::knit("demo_obs_4.Rmd.original", output = "demo_obs_4.Rmd")

setwd(base_dir)
