####╔══════     ══════╗####
####💠 Project Config 💠####
####╚══════     ══════╝####

log.title("[CONFIG] Loading project's configs ...")

config <- config::get()
secret <- config::get(file = "secret.yml")

options(
  contrasts = c("contr.sum", "contr.poly")
)