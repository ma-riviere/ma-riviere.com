####╔═════      ═════╗####
####💠 Project Init 💠####
####╚═════      ═════╝####

is_installed <- \(pkg) suppressMessages({require(pkg, quietly = TRUE, warn.conflicts = FALSE, character.only = TRUE)})

if (!is_installed("here")) {install.packages("here"); require(here, quietly = TRUE)}

src_path <- here::here("src")
com_path <- here::here(src_path, "common")

source(here::here(com_path, "renv_setup.R"), echo = FALSE)

project_base_scripts <- c("logger.R", "utils.R", "packman.R")

void <- sapply(project_base_scripts, \(f) source(here::here(com_path, f), echo = FALSE))
rm(void)

## Packages section ##
source(here::here(src_path, "packages.R"), echo = FALSE)
load_packages(project_pkgs)

source(here::here(com_path, "config_global.R"), echo = FALSE)

## Theme section ##
theme_scripts <- c(
  here::here(com_path, "theme", "theme.R"),
  fs::dir_ls(path = here::here(com_path, "theme"), type = "file", glob = "*.R") |> 
    purrr::discard(\(x) fs::path_file(x) %in% c("theme.R"))
)
purrr::walk(theme_scripts, \(f) source(f, verbose = FALSE, echo = FALSE))

## Project config section ##
project_scrips <- c(
  here::here(src_path, "config_project.R"),
  fs::dir_ls(path = src_path, type = "file", glob = "*.R") |> 
    purrr::discard(\(x) fs::path_file(x) %in% c("packages.R", "init.R", "config_project.R"))
)
purrr::walk(project_scrips, \(f) source(f, verbose = FALSE, echo = FALSE))