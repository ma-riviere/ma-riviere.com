####╔══════    ══════╗####
####💠Global Configs💠####
####╚══════    ══════╝####

log.title("[CONFIG] Loading Global Configs ...")

options(
  scipen = 999L, 
  digits = 4L,
  mc.cores = max(1L, parallel::detectCores(logical = TRUE)),
  na.action = "na.omit",
  seed = 256
)

set.seed(getOption("seed"))

#--------------------------#
####🔺Knitr & RMarkdown ####
#--------------------------#

knitr::opts_chunk$set(
  warning = FALSE,
  message = FALSE,
  fig.align = "center",
  fig.retina = 2,
  dpi = 300,
  dev = 'svg',
  dev.args = list(bg = "transparent")
)

#----------------#
####🔺Masking ####
#----------------#

get <- base::get

#------------------------#
####🔺Package options ####
#------------------------#

load_global_config <- function() {
  global_config <- tryCatch(
    config::get(file = "global_config.yml"), 
    error = \(e) return(NULL)
  )
  
  if(!is.null(global_config)) log.note("[CONFIG] Global config file found.")
  else log.warn("[CONFIG] No global config file found.")
  
  return(global_config)
}

configure_git <- function() {
  if(Sys.getenv("GITHUB_PAT") != "") {
    log.note("[CONFIG] GITHUB Access Token found: ", Sys.getenv("GITHUB_PAT"))
  }
  else if (!is.null(global_config$github_pat) && global_config$github_pat != "") {
    log.note("[CONFIG] GITHUB Access Token found: ", global_config$github_pat)
    Sys.setenv(GITHUB_PAT = global_config$github_pat)
  }
  else log.warn("[CONFIG] GITHUB Access Token NOT found - package loading might fail due to Github API's download cap.")
}

configure_packages <- function() {
  
  if (is_installed("rstan")) rstan::rstan_options(auto_write = TRUE)
  
  if (is_installed("loo")) options(loo.cores = getOption("mc.cores"))
  
  if (is_installed("data.table")) data.table::setDTthreads(getOption("mc.cores"))
  
  if (is_installed("furrr")) {
    future::plan(multisession, workers = getOption("mc.cores"))
    furrr::furrr_options(seed = getOption("seed"))
  }
  
  if (is_installed("glmmTMB")) options(glmmTMB.cores = max(1L, parallel::detectCores(logical = FALSE)))
  
  if (is_installed("afex")) {
    # afex::set_sum_contrasts()
    afex::afex_options(
      type = 3,
      method_mixed = "KR",
      include_aov = TRUE,
      factorize = FALSE,
      check_contrasts = FALSE,
      es_aov = "pes", # ges
      correction_aov = "HF"
      # emmeans_model  = "univariate"
    )
  }
  
  if (is_installed("emmeans")) {
    emmeans::emm_options(
      lmer.df = "kenward-roger",
      opt.digits = 4,
      back.bias.adj = FALSE 
      # don't forget to use bias.adjust = T for mixed models and models with response transforms (e.g. `log(Y) ~ .`)
    )
  }
  
  if (is_installed("lme4") && is_installed("optimx")) {
    my.lmer.control.params <<- lme4::lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "nlminb", starttests = FALSE, kkt = FALSE))
    my.glmer.control.params <<- lme4::glmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "nlminb", starttests = FALSE, kkt = FALSE))
  }
}