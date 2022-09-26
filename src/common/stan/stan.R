####╔═════    ═════╗####
####💠 Stan Setup 💠####
####╚═════    ═════╝####

## See: https://blog.mc-stan.org/2022/08/03/options-for-improving-stan-sampling-speed/ 
##      & https://discourse.mc-stan.org/t/speedup-by-using-external-blas-lapack-with-cmdstan-and-cmdstanr-py/25441/41
### - Always use -march=native -mtune=native
### - Use within-chain parallelization whenever possible
### - When not using within-chain parallelization
#### * Use MKL/OpenBLAS with 2 threads (or more): only worth it if there are big matrix operations (otherwise, use the default Eigen)

configure_stan <- function(version = NULL, rebuild = FALSE, openCL = FALSE, BLAS = NULL) {
  
  if(is_installed("cmdstanr")) {
    
    ## Initialization
    
    log.main("[CONFIG] Setting up CmdStan ...")
    
    if(is.null(version)) version <- gh::gh(
      "GET /repos/stan-dev/cmdstan/releases/latest", 
      .token = global_config$github_pat %ne% Sys.getenv("GITHUB_PAT")
    )[["tag_name"]] |> substring(2)
    
    log.note("[CONFIG] Using CmdStan version: ", version)
    
    ### INFO: If env.var "CMDSTAN" exists, then its value will be automatically set as the default path to CmdStan for the R session
    
    cmdstan_root <- "D:/Dev/SDK/"
    if (Sys.info()[["sysname"]] == "Linux") cmdstan_root <- "/home/mar/Dev/SDK/"
    
    cmdstan_install_path <- file.path(cmdstan_root, ".cmdstan")
    if(!dir.exists(cmdstan_install_path)) dir.create(cmdstan_install_path, recursive = TRUE)
    
    cmdstan_version <- paste0("cmdstan-", version)
    cmdstan_path <- file.path(cmdstan_install_path, cmdstan_version)
    
    ## Rebuilding CmdStan install
    if (rebuild) {
      
      ### General params
      cpp_opts <- list(
        stan_threads = TRUE
        , STAN_CPP_OPTIMS = TRUE
        , STAN_NO_RANGE_CHECKS = TRUE # Careful with that one, better use it on a model basis
        , PRECOMPILED_HEADERS = TRUE
        , CXXFLAGS_OPTIM_TBB = "-mtune=native -march=native"
        , CXXFLAGS_OPTIM_SUNDIALS = "-mtune=native -march=native"
      )
      
      if (Sys.info()[["sysname"]] == "Windows") cpp_opts <- append(cpp_opts, list(CXXFLAGS_OPTIM = "-O3 -march=native -mtune=native"))
      
      ### BLAS params
      if (!is.null(BLAS)) {
        
        if(BLAS == "MKL") {
          MKLROOT <- "//usr/include/mkl"
          
          cpp_opts_mkl <- list(
            glue("CXXFLAGS += -DEIGEN_USE_MKL_ALL -I${MKLROOT}"),
            "LDLIBS += -lmkl_intel_lp64 -lmkl_sequential -lmkl_core" # TODO: use parallel threads instead of sequential ?
          )
          
          cpp_opts <- append(cpp_opts, cpp_opts_mkl)
        }
        
        if(BLAS == "OB") {
          cpp_opts_blas <- list(
            "CXXFLAGS += -DEIGEN_USE_BLAS -DEIGEN_USE_LAPACKE", 
            "LDLIBS += -lblas -llapack -llapacke"
          )
          
          cpp_opts <- append(cpp_opts, cpp_opts_blas)
        }
      }
      
      ### OpenCL params
      if (openCL) {
        
        cpp_opts_cl <- c(STAN_OPENCL = TRUE, OPENCL_DEVICE_ID = 0, OPENCL_PLATFORM_ID = 0)
        
        if(Sys.info()[["sysname"]] == "Linux") cpp_opts <- append(cpp_opts, cpp_opts_cl)
        
        if(Sys.info()[["sysname"]] == "Windows") {
          if(Sys.getenv("CUDA_PATH") != "") {
            
            CUDA_PATH <- file.path(Sys.getenv("CUDA_PATH"), "/lib/x64")
            
            if(dir.exists(CUDA_PATH)) {
              log.note("[CONFIG] Found existing CUDA_PATH: ", CUDA_PATH)
              cpp_opts_cl <- append(cpp_opts_cl, paste0("LDFLAGS_OPENCL=-L\"", CUDA_PATH, "\" -lOpenCL"))
              cpp_opts <- append(cpp_opts, cpp_opts_cl)
            }
            else log.warn("[CONFIG] The specified CUDA path does not exist.")
          } 
          else {
            log.warn("[CONFIG] No CUDA_PATH specified in the environment variables.")
          }
        }
      }
      
      ### Installation
      
      if (Sys.info()[["sysname"]] == "Windows") {
        cmdstanr::check_cmdstan_toolchain(fix = TRUE)
        cmdstanr::install_cmdstan(dir = cmdstan_install_path, overwrite = TRUE, cpp_options = cpp_opts, version = version, quiet = TRUE)
        
        # cmdstan_archive_name <- paste0(cmdstan_version, ".tar.gz")
        # cmdstan_archive_url <- glue::glue("https://github.com/stan-dev/cmdstan/releases/download/v{version}/{cmdstan_archive_name}")
        # download.file(cmdstan_archive_url, destfile = cmdstan_archive_name, mode = "wb")
        # untar(tarfile = cmdstan_archive_name, exdir = cmdstan_install_path)
        # cmdstanr::set_cmdstan_path(cmdstan_path) # FIXME (2.28.1): Has to be here too ???
        # cmdstanr::cmdstan_make_local(dir = cmdstan_path, cpp_options = cpp_opts, append = FALSE)
        # cmdstanr::rebuild_cmdstan(dir = cmdstan_path, quiet = TRUE)
        # if (file.exists(cmdstan_archive_name)) file.remove(cmdstan_archive_name)
      }
      else if (Sys.info()[["sysname"]] == "Linux") {
        cmdstanr::install_cmdstan(dir = cmdstan_install_path, overwrite = TRUE, cpp_options = cpp_opts, version = version, quiet = TRUE)
      }
      
    } else { ## No rebuild, only configure
      cmdstanr::set_cmdstan_path(cmdstan_path)
    }
    
    # if (Sys.info()[["sysname"]] == "Windows") {
    # CMDSTAN_TBB <- file.path(cmdstan_path, "stan/lib/stan_math/lib/tbb")
    # Sys.setenv("Path" = paste0(Sys.getenv("PATH"), CMDSTAN_TBB))
    # }
    
    Sys.setenv("OPENBLAS_NUM_THREADS" = 1)
    
    options(brms.backend = "cmdstanr")
    
    knitr::knit_engines$set(
      cmdstan = function(options) {
        output_var <- options$output.var
        if (!is.character(output_var) || length(output_var) != 1L) {
          stop(
            "The chunk option output.var must be a character string ",
            "providing a name for the returned `CmdStanModel` object."
          )
        }
        if (options$eval) {
          if (options$cache) {
            cache_path <- options$cache.path
            if (length(cache_path) == 0L || is.na(cache_path) || cache_path == "NA") 
              cache_path <- ""
            dir <- paste0(cache_path, options$label)
          } else {
            dir <- tempdir()
          }
          file <- cmdstanr::write_stan_file(options$code, dir = dir) # , force_overwrite = TRUE
          mod <- cmdstanr::cmdstan_model(
            file, 
            cpp_options = list(stan_threads = TRUE), stanc_options = list("O1") ## TODO: pass those options into the chunk options ?
          )
          assign(output_var, mod, envir = knitr::knit_global())
        }
        options$engine <- "stan"
        code <- paste(options$code, collapse = "\n")
        knitr::engine_output(options, code, '')
      }
    )
  }
}