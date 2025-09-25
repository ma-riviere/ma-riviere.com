####╔══════     ══════╗####
####💠 Project Config 💠####
####╚══════     ══════╝####

log.title("[CONFIG] Loading project's configs ...")

config <- config::get(file = "_config.yml")
# secret <- config::get(file = "_secret.yml")

options(
  contrasts = c("contr.sum", "contr.poly"),
  bitmapType = "cairo"
)

if (nzchar(Sys.getenv("DISPLAY")) && capabilities("cairo")) {
  options(device = function(...) x11(type = "cairo", ...))
}
