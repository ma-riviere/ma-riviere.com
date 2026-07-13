#---------------------------#
####🔺knitr custom hooks ####
#---------------------------#

library(knitr)

## Adding the `time_it` code chunk option
knitr::knit_hooks$set(
    time_it = local({
        assign("TIMES", list(), .GlobalEnv)
        start <- NULL
        function(before, options) {
            if (before) {
                start <<- Sys.time()
            } else {
                TIMES[[options$label]] <<- difftime(Sys.time(), start)
            }
        }
    })
)
