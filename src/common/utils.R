####╔═══    ══╗####
####💠 Utils 💠####
####╚═══    ══╝####

log.title("[UTILS] Loading Utils ...")

#--------------#
####🔺Pipes ####
#--------------#

"%ni%" <- Negate("%in%")

"%s+%" <- \(lhs, rhs) paste0(lhs, rhs)

"%ne%" <- \(lhs, rhs) if(is.null(lhs) || rlang::is_empty(lhs) || lhs == "") return(rhs) else return(lhs)


#---------------#
####🔺Images ####
#---------------#

save_png <- function(plot, filename = NULL, subfolder = NULL, device = "png", dpi = 600, width = 8, height = 8, display = TRUE) {
  if(is.null(filename)) filename <- as.list(match.call()[-1])$plot
  
  file_path <- here("fig", paste0(filename, ".", device))
  if(!is.null(subfolder)) {
    if(!dir.exists(here::here("fig", subfolder))) dir.create(here::here("fig", subfolder))
    file_path <- here("fig", subfolder, paste0(filename, ".", device))
  }
  
  ggsave(filename = file_path, plot = plot, device = device, scale = 1, dpi = dpi, width = width, height = height)
  if(display) return(plot)
}

#-------------------#
####🔺Text utils ####
#-------------------#

label_pval <- function(p) {
  ifelse(p <= alpha, str_c(scales::label_pvalue()(p), gtools::stars.pval(p) |> str_replace(fixed("."), ""), sep = " "), scales::label_pvalue()(p) |> str_remove(">") |> str_trim())
}

get_response_name <- function(var) {
  if(exists(paste0(var, "_name"))) return(eval(parse(text = get_var_name(!!paste0(var, "_name")))))
  else return(var)
}

get_model_family <- function(mod) {
  family <- insight::get_family(mod)$family |> stringr::str_to_sentence()
  link <- insight::get_family(mod)$link
  
  model_tag <- glue::glue("{family} ('{link}')")
  
  cov_struct <- stringr::str_match(insight::get_call(mod)$formula |> toString(), "\\s(\\w{2,3})\\(.*\\)")[[2]]
  if (!is.null(cov_struct) && !is.na(cov_struct) && cov_struct != "") model_tag <- glue::glue("{model_tag} + {toupper(cov_struct)}")
  
  return(model_tag)
}

get_model_tag <- function(mod) {
  resp <- insight::find_response(mod)
  return(glue::glue("{resp} - {get_model_family(mod)}"))
}

print_model_call <- function(mod) {
  cat("```{{r}}\n")
  print(insight::get_call(mod))
  cat("```\n")
}

### From: https://michaelbarrowman.co.uk/post/getting-a-variable-name-in-a-pipeline/
get_var_name <- function(x) {
  lhs <- get_lhs()
  if(is.null(lhs)) lhs <- rlang::ensym(x)
  return(rlang::as_name(lhs))
}

get_lhs <- function() {
  calls <- sys.calls()
  
  #pull out the function or operator (e.g. the `%>%`)
  call_firsts <- lapply(calls, `[[`, 1) 
  
  #check which ones are equal to the pipe
  pipe_calls <- vapply(call_firsts,identical, logical(1), quote(`%>%`))
  
  #if we have no pipes, then get_lhs() was called incorrectly
  if(all(!pipe_calls)){
    NULL
  } else {
    #Get the most recent pipe, lowest on the 
    pipe_calls <- which(pipe_calls)
    pipe_calls <- pipe_calls[length(pipe_calls)]
    
    #Get the second element of the pipe call
    this_call <- calls[[c(pipe_calls, 2)]]
    
    #We need to dig down into the call to find the original
    while(is.call(this_call) && identical(this_call[[1]], quote(`%>%`))){
      this_call <- this_call[[2]]
    }
    this_call
    
  }
}

get_current_file_name <- function(ext = TRUE) {
  file <- fs::path_file(rstudioapi::getActiveDocumentContext()$path)
  if (ext) return(file)
  else return(fs::path_ext_remove(file))
}


#--------------------#
####🔺Stats utils ####
#--------------------#

poly_encoding <- function(fctr) {
  contrasts(fctr) <- contr.poly
  return(
    car::Recode(fctr, glue::glue_collapse(glue::glue("'{levels(fctr)}' = {as.vector(contrasts(fctr)[,1])}"), sep = "; ") |> as_string()) |> 
      as.character() |> 
      as.numeric()
  )
}

label_encoding <- function(var) {
  vals <- unique(var)
  car::Recode(var, glue::glue_collapse(glue::glue("'{vals}' = {as.vector(seq.int(1, length(vals)))}"), sep = "; ") |> as_string()) |> 
    as.character() |> 
    as.numeric()
}


#-------------#
####🔺Misc ####
#-------------#

update_submodules <- function() {
  if(Sys.info()[["sysname"]] == "Linux") {
    system(glue::glue("chmod +x {here::here('update_submodules.sh')}"), intern = TRUE)
    system("#!/bin/sh", intern = TRUE)
    system(here::here("update_submodules.sh"), intern = TRUE)
  }
  else if(Sys.info()[["sysname"]] == "Windows") system(here::here("update_submodules.bat"), intern = TRUE)
}


### From: https://gist.github.com/alexpghayes/9118cda66375e593343fe28c8d13fdb5
# Upload a data frame to google drive, make it shareable, and copy the shareable link into the clipboard
# See: https://googledrive.tidyverse.org/

# if direct = TRUE, the link can be used immediately to read in the file
# if direct = FALSE, the link takes users to a nice preview of the file instead
get_shareable_link_to_data <- function(data, path, direct = TRUE) {
  readr::write_csv(data, path)
  df <- googledrive::drive_upload(path, path)
  df <- googledrive::drive_share(df, role = "reader", type = "anyone")
  
  if (direct)
    link <- paste0("https://drive.google.com/uc?export=download&id=", df$id)
  else
    link <- googledrive::drive_link(df)
  
  clipr::write_clip(link)
  fs::file_delete(path)
  cat(link)
  invisible(link)
}


## Get element by name from list:
rmatch <- function(x, name) {
  pos <- match(name, names(x))
  if (!is.na(pos)) return(x[[pos]])
  for (el in x) {
    if (class(el) == "list") {
      out <- Recall(el, name)
      if (!is.null(out)) return(out)
    }
  }
}


## Convert matrix to math latex notation
matrix2latex <- function(mat) {
  printmrow <- \(x) cat(paste0(x, collapse = " & "), "\\\\\n")
  cat("$$\n", "\\begin{bmatrix}", "\n", sep = "")
  body <- apply(mat, 1, printmrow)
  cat("\\end{bmatrix}", "\n$$", sep = "")
}