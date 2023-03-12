####╔═══════      ═══════╗####
####💠 Project Packages 💠####
####╚═══════      ═══════╝####

project_repos <- c(
  # EasyStats = "https://easystats.r-universe.dev",
  # Stan = "https://mc-stan.org/r-packages/",
  CRAN = "https://cloud.r-project.org/"
)

base_pkgs <- c("renv", "here", "config", "rlang", "fs", "knitr", "rmarkdown", "crayon", "usethis", "glue", "magrittr", "todor", "pipebind")

project_pkgs <- c(
  ### Pre-requisites
  
  ### Data wrangling
  "readr",
  "tibble",
  "stringr",
  "purrr",
  "tidyr",
  "dplyr",
  "lubridate",
  "Rdatatable/data.table",
  "dtplyr",
  "dbplyr",
  "arrow",
  "furrr",
  "DBI",
  "RSQLite",
  "duckdb",
  "fuzzyjoin",
  "sf",
  "broom",
  "datawizard",
  "nplyr",
  
  ### Model fitting
  "stan-dev/cmdstanr",
  "brms",
  
  ### Model analysis
  "posterior",
  "tidybayes",
  
  ### Visualizations
  "ggplot2",
  "ggtext",
  "patchwork",
  "bayesplot",
  "ggridges",
  "ricardo-bion/ggradar",

  ### Publishing
  "gt",
  "jthomasmock/gtExtras",
  "sessioninfo",
  "quarto",
  "downlit",
  "xml2",
  
  ### Misc
  "styler", 
  "miniUI", 
  "gtools"
)