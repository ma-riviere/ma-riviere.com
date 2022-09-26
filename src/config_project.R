####╔══════     ══════╗####
####💠 Project Config 💠####
####╚══════     ══════╝####

log.title("[CONFIG] Loading project's configs ...")

config <- config::get(file = "_config.yml")
# secret <- config::get(file = "_secret.yml")

options(
  contrasts = c("contr.sum", "contr.poly")
)