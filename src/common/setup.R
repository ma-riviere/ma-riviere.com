####╔══════     ══════╗####
####💠 Project Setup 💠####
####╚══════     ══════╝####

#-----------------------#
####🔺Global scripts ####
#-----------------------#

is_installed <- \(pkg) suppressMessages({require(pkg, quietly = TRUE, warn.conflicts = FALSE, character.only = TRUE)})

here::i_am("src/common/setup.R")

com_path <- here::here("src", "common")
source(here::here(com_path, "logger.R"), echo = FALSE)

log.title("[SETUP] Setting up the project ...\n")

if(is.null(renv::project())) renv::init(project = here::here(), bare = TRUE, restart = FALSE)

if (!startsWith(.libPaths()[1], here::here())) {
  v <- paste0("R-", version$major, ".", strsplit(version$minor, ".", fixed = TRUE)[[1]][1])
  dir <- ifelse(Sys.info()[["sysname"]] == "Windows", "x86_64-w64-mingw32", "x86_64-pc-linux-gnu")
  path <- here::here("renv", "library", v, dir)
  if(!dir.exists(path)) dir.create(path, recursive = TRUE)
  renv::use(library = path) # .libPaths(path)
}

if(!file.exists(here::here("config.yml"))) {
  file.create(here::here("config.yml"))
  cat('default:\r  data: !expr here::here("data", "my_data.csv")\r', file = here::here("config.yml"))
}

if(!file.exists(here::here("secret.yml"))) {
  file.create(here::here("secret.yml"))
  cat('default:\r  api_key: ""\r', file = here::here("secret.yml"))
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
  
  source(here::here("src", "authors.R"), echo = FALSE)

  init_project_packages(...)
  
  source(here::here("src", "common", "theme.R"), echo = FALSE)

  source(here::here("src", "config_project.R"), echo = FALSE)
  
  log.main("[SETUP] Loading project-specific scripts ...")
  
  project_scrips <- fs::dir_ls(path = here::here("src"), type = "file", glob = "*.R") |> fs::path_file()  # Loading data.R & co

  tmp <- sapply(
    project_scrips[which(project_scrips %ni% c("packages.R", "init.R", "config_project.R"))],
    \(f) source(here::here("src", f), verbose = FALSE, echo = FALSE)
  )
  
  source(here::here("src", "common", "stan.R"), echo = FALSE)
  
  rm(tmp)
}