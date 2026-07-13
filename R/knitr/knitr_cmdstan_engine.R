## Inspired by: https://mpopov.com/blog/2020/07/30/replacing-the-knitr-engine-for-stan/

## Note: We could haved use cmdstanr::register_knitr_engine(),
##       but it wouldn't include compiler optimizations & multi-threading by default

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
                if (length(cache_path) == 0L || is.na(cache_path) || cache_path == "NA") {
                    cache_path <- ""
                }
                dir <- paste0(cache_path, options$label)
            } else {
                dir <- tempdir()
            }
            file <- cmdstanr::write_stan_file(
                options$code,
                dir = dir,
                force_overwrite = TRUE
            )
            mod <- cmdstanr::cmdstan_model(
                stan_file = file,
                cpp_options = list(
                    stan_threads = TRUE,
                    STAN_CPP_OPTIMS = TRUE,
                    STAN_NO_RANGE_CHECKS = TRUE, # The model was already tested
                    PRECOMPILED_HEADERS = TRUE,
                    # , CXXFLAGS_OPTIM = "-march=native -mtune=native"
                    CXXFLAGS_OPTIM_TBB = "-mtune=native -march=native",
                    CXXFLAGS_OPTIM_SUNDIALS = "-mtune=native -march=native"
                ),
                stanc_options = list("O1"),
                force_recompile = TRUE
            )
            assign(output_var, mod, envir = knitr::knit_global())
        }
        options$engine <- "stan"
        code <- paste(options$code, collapse = "\n")
        knitr::engine_output(options, code, '')
    }
)
