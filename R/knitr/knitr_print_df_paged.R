library(rmarkdown)
library(knitr)

## Getting rvars to properly print when rendering
knit_print.data.frame <- function(x, options, ...) {
    rvar_cols <- map(x, class) |> keep(\(x) "rvar" %in% x) |> names()

    mutate(x, across(any_of(rvar_cols), \(col) map_chr(col, toString))) |>
        paged_table(options, ...) |>
        rmarkdown:::print.paged_df()
}

registerS3method("knit_print", "data.frame", knit_print.data.frame)
