####╔═════      ═════╗####
####💠 Project Init 💠####
####╚═════      ═════╝####

is_installed <- \(pkg) suppressMessages({require(pkg, quietly = TRUE, warn.conflicts = FALSE, character.only = TRUE)})

if (!is_installed("here")) {install.packages("here"); require(here, quietly = TRUE)}

if (!startsWith(.libPaths()[1], here::here())) {
  v <- paste0("R-", version$major, ".", strsplit(version$minor, ".", fixed = TRUE)[[1]][1])
  dir <- ifelse(Sys.info()[["sysname"]] == "Windows", "x86_64-w64-mingw32", "x86_64-pc-linux-gnu")
  path <- here::here("renv", "library", v, dir)
  if(!dir.exists(path)) dir.create(path, recursive = TRUE)
  .libPaths(path)
}

com_path <- here::here("src", "common")
project_base_scripts <- c("logger.R", "utils.R", "packman.R")

tmp <- sapply(project_base_scripts, \(f) source(here::here(com_path, f), echo = FALSE))

source(here::here("src", "packages.R"), echo = FALSE)

load_packages(project_pkgs)

source(here::here(com_path, "config_global.R"), echo = FALSE)

# source(here::here(com_path, "theme.R"), echo = FALSE)

source(here::here("src", "config_project.R"), echo = FALSE)

project_scripts <- fs::dir_ls(path = here::here(com_path), type = "file", glob = "*.R") |> fs::path_file()

tmp <- sapply(
  project_scripts[which(project_scripts %ni% c("init.R", "setup.R", "config_global.R", project_base_scripts))], 
  \(f) source(here::here(com_path, f), echo = F)
)