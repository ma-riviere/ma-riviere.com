## Pointing towards the correct renv (Quarto won't find the packages without this)

if (!startsWith(.libPaths()[1], here::here())) {
  v <- paste0("R-", version$major, ".", strsplit(version$minor, ".", fixed = TRUE)[[1]][1])
  dir <- ifelse(Sys.info()[["sysname"]] == "Windows", "x86_64-w64-mingw32", "x86_64-pc-linux-gnu")
  path <- here::here("renv", "library", v, dir)
  if(!dir.exists(path)) dir.create(path, recursive = TRUE)
  renv::use(library = path) # .libPaths(path)
}

config <- config::get()
