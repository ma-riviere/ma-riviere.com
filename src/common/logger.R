####╔════   ════╗####
####💠 Logging 💠####
####╚════   ════╝####

# See: https://github.com/r-lib/crayon

log.title <- function(...) {
  msg <- paste0(...)
  if(is_installed("crayon")) msg <- crayon::magenta$bold(msg)
  return(cat("\n", msg, "\n"))
}

log.main <- function(...) {
  msg <- paste0(...)
  if(is_installed("crayon")) msg <- crayon::blue(msg)
  return(cat("\n", msg, "\n"))
}

log.note <- function(...) {
  msg <- paste0(...)
  if(is_installed("crayon")) msg <- crayon::silver$italic(msg)
  return(cat("\n", msg, "\n"))
}

log.warn <- function(...) {
  msg <- paste0("[WARN]", ...)
  if(is_installed("crayon")) msg <- crayon::yellow(msg)
  return(cat("\n", msg, "\n"))
}

log.error <- function(...) {
  msg <- paste0("[ERROR]", ...)
  if(is_installed("crayon")) msg <- crayon::red$bold(msg)
  return(cat("\n", msg, "\n"))
}