####╔══════     ══════╗####
####💠 Project Setup 💠####
####╚══════     ══════╝####

#-----------------------#
####🔺Global scripts ####
#-----------------------#

is_installed <- \(pkg) suppressMessages({require(pkg, quietly = TRUE, warn.conflicts = FALSE, character.only = TRUE)})

here::i_am("src/common/setup.R")

src_path <- here::here("src")
com_path <- here::here(src_path, "common")
source(here::here(com_path, "logger.R"), echo = FALSE)

log.title("[SETUP] Setting up the project ...\n")

if(is.null(renv::project())) renv::init(project = here::here(), bare = TRUE, restart = FALSE)
source(here::here(com_path, "renv_setup.R"), echo = FALSE)

if(!file.exists(here::here("_config.yml"))) {
  file.create(here::here("_config.yml"))
  cat('default:\r  data: !expr here::here("data", "my_data.csv")\r', file = here::here("_config.yml"))
}

if(is.null(renv::project()) && !file.exists(here::here("_secret.yml"))) {
  file.create(here::here("_secret.yml"))
  cat('default:\r  api_key: ""\r', file = here::here("_secret.yml"))
}

log.main("[SETUP] Loading common scripts ...")

project_base_scripts <- c("logger.R", "utils.R", "packman.R")

tmp <- sapply(project_base_scripts, \(f) source(here::here(com_path, f), echo = FALSE))

init_base_packages()

source(here::here(com_path, "config_global.R"), echo = FALSE)

global_config <- load_global_config()


#------------------------#
####🔺Project scripts ####
#------------------------#

setup_project <- function(...) {
  
  ## Packages section ##
  source(here::here(src_path, "authors.R"), echo = FALSE)
  
  init_project_packages(...)
  
  ## Theme section ##
  log.main("[SETUP] Loading theme-related scripts ...")
  
  theme_scripts <- c(
    here::here(com_path, "theme", "theme.R"),
    fs::dir_ls(path = here::here(com_path, "theme"), type = "file", glob = "*.R") |> 
      purrr::discard(\(x) fs::path_file(x) %in% c("theme.R"))
  )
  purrr::walk(theme_scripts, \(f) source(f, verbose = FALSE, echo = FALSE))
  
  ## Project config section ##
  log.main("[SETUP] Loading project-related scripts ...")
  
  project_scrips <- c(
    here::here(src_path, "config_project.R"),
    fs::dir_ls(path = src_path, type = "file", glob = "*.R") |> 
      purrr::discard(\(x) fs::path_file(x) %in% c("packages.R", "init.R", "config_project.R"))
  )
  purrr::walk(project_scrips, \(f) source(f, verbose = FALSE, echo = FALSE))
  
  ## Stan section ##
  log.main("[SETUP] Loading Stan-related scripts ...")
  
  stan_scripts <- fs::dir_ls(path = here::here(com_path, "stan"), type = "file", glob = "*.R")
  purrr::walk(stan_scripts, \(f) source(f, verbose = FALSE, echo = FALSE))
}