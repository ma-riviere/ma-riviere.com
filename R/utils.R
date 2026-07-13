####╔═══    ══╗####
####💠 Utils 💠####
####╚═══    ══╝####

log.title("[UTILS] Loading Utils ...")

is_valid_url <- function(string) {
    pattern <- "(https?|ftp)://[^ /$.?#].[^\\s]*"
    return(grepl(pattern, string))
}

load_packages <- function(packages) {
    return(invisible(suppressPackageStartupMessages(
        lapply(packages, \(package) {
            require(
                get_pkg_name(package),
                character.only = TRUE,
                quietly = TRUE,
                warn.conflicts = FALSE
            )
        })
    )))
}

# Source an R script (local path or URL). With envir_name = NA the sourced objects are moved to
# the global env; with a name, they are kept in a named env. `include.only` keeps only those objects.
source2 <- function(path, envir_name = NULL, include.only = NULL) {
    if (is.null(envir_name)) {
        envir_name <- basename(path) |> tools::file_path_sans_ext()
    }
    if (is_valid_url(path)) {
        path <- url(path)
    }

    target_env <- new.env()
    source(path, local = target_env)

    if (!is.null(include.only)) {
        objects_to_remove <- setdiff(
            ls(target_env),
            intersect(ls(target_env), include.only)
        )
        rm(list = objects_to_remove, envir = target_env)
    }

    if (is.na(envir_name)) {
        for (obj in ls(target_env)) {
            assign(obj, get(obj, envir = target_env), envir = globalenv())
        }
        rm(target_env)
    } else {
        assign(envir_name, target_env, envir = globalenv())
    }
}
