####╔════════         ═══════╗####
####💠 Init minimal scripts 💠####
####╚════════         ═══════╝####

is_installed <- \(pkg) suppressMessages({require(pkg, quietly = TRUE, warn.conflicts = FALSE, character.only = TRUE)})

if (!is_installed("here")) {install.packages("here"); require(here, quietly = TRUE)}

src_path <- here::here("src")
com_path <- here::here(src_path, "common")

source(here::here(com_path, "renv_setup.R"), echo = FALSE)

source(here::here(com_path, "logger.R"), echo = FALSE)

source(here::here(com_path, "utils.R"), echo = FALSE)

## Theme section ##
theme_scripts <- c(
  "theme.R",
  list.files(path = here::here(com_path, "theme"), pattern = "*.R") |> Filter(\(f) !endsWith(f, "theme.R"), x = _)
)
sapply(theme_scripts, \(f) source(here::here(com_path, "theme", f), verbose = FALSE, echo = FALSE)) -> void