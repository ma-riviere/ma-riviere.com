####╔═══════      ═══════╗####
####💠 Project Packages 💠####
####╚═══════      ═══════╝####

project_repos <- c(
  # EasyStats = "https://easystats.r-universe.dev",
  # Stan = "https://mc-stan.org/r-packages/",
  CRAN = "https://cloud.r-project.org/"
)

base_pkgs <- c("renv", "here", "config", "rlang", "fs", "knitr", "rmarkdown", "glue", "magrittr", "cli", "pipebind")

project_pkgs <- c(
  ### Pre-requisites
  
  ### Data ingestion
  "readr",
  "archive",
  "arrow",
  
  ### Data wrangling
  "tibble",
  "stringr",
  "purrr",
  "tidyr",
  "dplyr",
  "lubridate",
  "Rdatatable/data.table",
  "Tidyverse/dbplyr",
  "duckdb",
  "fuzzyjoin",
  "sf",
  "datawizard",
  "nplyr",
  
  ### Model fitting
  "stan-dev/cmdstanr",
  "brms",
  
  ### Model analysis
  "posterior",
  "tidybayes",
  "broom",
  
  ### Visualizations
  "ggplot2",
  "ggtext",
  "patchwork",
  "bayesplot",
  "ggblend",
  "plotly",
  "leaflet",

  ### Publishing
  "gt",
  "sessioninfo",
  "quarto",
  "downlit",
  "xml2",
  
  ### Misc
  "gtools"
)