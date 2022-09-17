####╔═══════     ═══════╗####
####💠 Package Manager 💠####
####╚═══════     ═══════╝####

source(here::here("src", "packages.R"), echo = F)

options(
  repos = project_repos,
  pkgType = ifelse(Sys.info()[["sysname"]] == "Windows", "both", "source"),
  Ncpus = max(1, parallel::detectCores(logical = TRUE) - 1),
  verbose = FALSE
)

Sys.setenv(MAKEFLAGS = paste0("-j", getOption("Ncpus")))

suite_pkgs_names <- c("tidyverse", "tidymodels", "easystats")

#----------------------#
####🔺Main function ####
#----------------------#

init_project_packages <- function(install = FALSE, update = FALSE, clean = FALSE) {
  
  if (clean) {
    log.main("[PACKAGES] Cleaning illegal project packages ...")
    renv::clean(prompt = FALSE)
  }
  
  if (install || update) {
    
    # log.title("[PACKAGES] Updating submodules ...")
    # update_submodules()
    
    log.title("[PACKAGES] Configuring GITHUB access ...")
    configure_git()
    
    # INSTALL -> compare to list of packages and install non-installed ones
    if (install) {
      log.title("[PACKAGES] Installing project packages ...")
      install_packages(project_pkgs)
    }
    
    # UPDATE -> update intalled packages to latest version
    if (update) {
      log.title("[PACKAGES] Updating project packages ...")
      update_packages(project_pkgs)
    }
    
    log.main("[PACKAGES] Loading project packages into global environment ...\n")
    # pkgs <- names(jsonlite::fromJSON(here::here("renv.lock"))$Packages)
    load_packages(project_pkgs)
    
    log.main("[PACKAGES] Indexing project packages ...\n")
    if(file.exists(here::here("DESCRIPTION"))) file.remove(here::here("DESCRIPTION"))
    
    usethis::use_description(
      fields = list(
        `Authors@R` = project_authors,
        Title = "_",
        Version = "1.0.0",
        Description = "_",
        Language =  "en"
      ),
      roxygen = FALSE,
      check_name = FALSE
    )
    usethis::use_mit_license(sapply(project_authors, \(s) paste(s$given, s$family)))
    
    add_packages_to_description(c(base_pkgs, project_pkgs))
    
    ## Updating renv.lock
    renv::snapshot(type = "explicit", prompt = FALSE)
    
  } else {
    log.title("[PACKAGES] Restoring project packages ...")
    renv::restore(prompt = FALSE, repos = project_repos)
    load_packages(project_pkgs)
  }
  
  log.title("[PACKAGES] Configuring project's packages ...")
  configure_packages()
}

init_base_packages <- function() {
  log.title("[PACKAGES] Installing base packages ...\n")

  install_packages(base_pkgs)
  load_packages(base_pkgs)
}

#-------------------------#
####🔺Helper functions ####
#-------------------------#

get_pkg_name <- function(pkg) {
  pkg_name <- pkg
  if (grepl("/", pkg_name, fixed = TRUE)) {
    pkg_path <- strsplit(pkg_name, "/", fixed = TRUE)[[1]]
    pkg_name <- pkg_path[length(pkg_path)]
  }
  if (grepl("@", pkg_name, fixed = TRUE)) {
    pkg_path <- strsplit(pkg_name, "@", fixed = TRUE)[[1]]
    pkg_name <- pkg_path[1]
  }
  return(pkg_name)
}

get_pkg_version <- function(pkg) {
  if (grepl("@", pkg, fixed = TRUE)) {
    pkg_path <- strsplit(pkg, split = "@", fixed = TRUE)[[1]]
    return(pkg_path[length(pkg_path)])
  }
  return(NA_character_)
}

get_renv_installed_pkgs <- function() {
  return(list.dirs(renv::paths$library(), full.names = F, recursive = F))
}

has_min_required_version <- function(pkg) {
  required_pkg_version <- get_pkg_version(pkg)
  ## Will return NA if the package has no declared version in the packages list, or if the version is not a correct version "number"
  if (!is.na(numeric_version(required_pkg_version, strict = FALSE))) {
    ## Will return -1 if current version is < required version
    if (utils::compareVersion(utils::packageVersion(get_pkg_name(pkg)), required_pkg_version) == -1) {
      return(FALSE)
    }
  }
  return(TRUE)
}

install_packages <- function(pkgs) {
  suppressPackageStartupMessages({
    for (pkg in pkgs) {
      pkg_name <- get_pkg_name(pkg)
      if (!is_installed(pkg_name)) install_package(pkg)
      else if (!has_min_required_version(pkg)) install_package(pkg)
    }
  })
}

install_package <- function(pkg) {
  tryCatch({
    renv::install(packages = pkg, prompt = FALSE, build_vignettes = FALSE)
  }, error = function(e) {
    log.warn("[PACKAGES] Error installing package `", pkg, "` from source. Attempting binary install ...\n")
    renv::install(packages = pkg, prompt = FALSE, build_vignettes = FALSE, type = "binary")
  })
}

update_packages <- function(pkgs) {
  suppressPackageStartupMessages({
    # pkgs_names <- lapply(project_pkgs, FUN = get_pkg_name) |> unlist()
    renv::update(packages = NULL, prompt = FALSE) # packages = pkgs_names --> only update pkgs from list
  })
}

load_packages <- function(pkgs) {
  suppressPackageStartupMessages({
    for (pkg in pkgs) {
      pkg_name <- get_pkg_name(pkg)
      if (is_installed(pkg_name)) require(pkg_name, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
    }
  })
}

add_packages_to_description <- function(pkgs) {
  for (pkg in pkgs) {
    pkg_name <- get_pkg_name(pkg)
    if (grepl("/", pkg_name, fixed = TRUE)) 
      usethis::use_dev_package(package = pkg_name, remote = pkg, type = "Imports")
    else if (pkg_name %in% suite_pkgs_names)
      usethis::use_package(pkg_name, type = "Depends", min_version = TRUE)
    else
      usethis::use_package(pkg_name, type = "Imports", min_version = TRUE)
  }
}