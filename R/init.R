####╔════════         ═══════╗####
####💠 Project init scripts 💠####
####╚════════         ═══════╝####

is_installed <- \(pkg) {
    suppressMessages({
        require(pkg, quietly = TRUE, warn.conflicts = FALSE, character.only = TRUE)
    })
}

if (!is_installed("here")) {
    install.packages("here")
    require(here, quietly = TRUE)
}

r_path <- here::here("R")

source(here::here(r_path, "logger.R"), echo = FALSE)

source(here::here(r_path, "utils.R"), echo = FALSE)

## Theme section ##
theme_scripts <- c(
    "theme.R",
    list.files(path = here::here(r_path, "theme"), pattern = "*.R") |>
        Filter(\(f) !endsWith(f, "theme.R"), x = _)
)

sapply(theme_scripts, \(f) {
    source(here::here(r_path, "theme", f), verbose = FALSE, echo = FALSE)
}) |>
    invisible()

options(bitmapType = "cairo")

if (nzchar(Sys.getenv("DISPLAY")) && capabilities("cairo")) {
    options(device = function(...) x11(type = "cairo", ...))
}
