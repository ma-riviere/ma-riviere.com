####╔═════    ═════╗####
####💠 Stan Setup 💠####
####╚═════    ═════╝####

## See: https://blog.mc-stan.org/2022/08/03/options-for-improving-stan-sampling-speed/
##      & https://discourse.mc-stan.org/t/speedup-by-using-external-blas-lapack-with-cmdstan-and-cmdstanr-py/25441/41
### - Always use -march=native -mtune=native
### - Use within-chain parallelization whenever possible
### - When not using within-chain parallelization
#### * Use MKL/OpenBLAS with 2 threads (or more): only worth it if there are big matrix operations (otherwise, use the default Eigen)

## Not sourced automatically: source manually (after R/init.R) to (re)install or configure CmdStan.
## CmdStan installs live under the CMDSTAN_PATH env var (project .Renviron), e.g. /home/mar/dev/SDK/.cmdstan/

configure_stan <- function(
    version = NULL, # NULL = latest release (resolved by cmdstanr when rebuilding)
    rebuild = FALSE,
    openCL = FALSE,
    BLAS = NULL
) {
    if (is_installed("cmdstanr")) {
        ## Initialization

        log.main("[CONFIG] Setting up CmdStan ...")

        cmdstan_install_path <- Sys.getenv("CMDSTAN_PATH")
        if (!nzchar(cmdstan_install_path)) {
            stop("CMDSTAN_PATH is not set (see the project's .Renviron)")
        }
        if (!dir.exists(cmdstan_install_path)) {
            dir.create(cmdstan_install_path, recursive = TRUE)
        }

        ## Rebuilding CmdStan install
        if (rebuild) {
            log.note(
                "[CONFIG] Installing CmdStan version ",
                version %||% "latest",
                " at ",
                cmdstan_install_path
            )

            ### General params
            cpp_opts <- list(
                stan_threads = TRUE,
                STAN_CPP_OPTIMS = TRUE,
                STAN_NO_RANGE_CHECKS = TRUE, # Be sure your model is working before using that one
                PRECOMPILED_HEADERS = TRUE,
                # , CXXFLAGS_OPTIM = "-march=native -mtune=native"
                CXXFLAGS_OPTIM_TBB = "-mtune=native -march=native",
                CXXFLAGS_OPTIM_SUNDIALS = "-mtune=native -march=native"
            )

            ### BLAS params
            if (!is.null(BLAS)) {
                if (BLAS == "MKL") {
                    MKLROOT <- "/usr/include/mkl"

                    cpp_opts_mkl <- list(
                        glue("CXXFLAGS += -DEIGEN_USE_MKL_ALL -I${MKLROOT}"),
                        "LDLIBS += -lmkl_intel_lp64 -lmkl_sequential -lmkl_core" # TODO: use parallel threads instead of sequential ?
                    )

                    cpp_opts <- append(cpp_opts, cpp_opts_mkl)
                }

                if (BLAS == "OB") {
                    cpp_opts_blas <- list(
                        "CXXFLAGS += -DEIGEN_USE_BLAS -DEIGEN_USE_LAPACKE",
                        "LDLIBS += -lblas -llapack -llapacke"
                    )

                    cpp_opts <- append(cpp_opts, cpp_opts_blas)
                }
            }

            ### OpenCL params
            if (openCL) {
                cpp_opts <- append(
                    cpp_opts,
                    c(
                        STAN_OPENCL = TRUE,
                        OPENCL_DEVICE_ID = 0,
                        OPENCL_PLATFORM_ID = 0
                    )
                )
            }

            ### Installation

            cmdstanr::install_cmdstan(
                dir = cmdstan_install_path,
                overwrite = TRUE,
                cpp_options = cpp_opts,
                version = version,
                quiet = TRUE
            )
        } else {
            ## No rebuild, only configure: point cmdstanr at the requested (or highest installed) version
            if (is.null(version)) {
                version <- list.files(cmdstan_install_path, pattern = "^cmdstan-") |>
                    sub(pattern = "cmdstan-", replacement = "", fixed = TRUE) |>
                    Reduce(f = \(x, y) ifelse(utils::compareVersion(x, y) == 1, x, y))
            }

            log.note("[CONFIG] Using CmdStan version ", version)

            cmdstanr::set_cmdstan_path(
                file.path(cmdstan_install_path, paste0("cmdstan-", version))
            )
        }

        Sys.setenv("OPENBLAS_NUM_THREADS" = 1)

        options(brms.backend = "cmdstanr")
    }
}
