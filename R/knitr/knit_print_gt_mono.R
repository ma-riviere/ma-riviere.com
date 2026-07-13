#-----------------------#
####🔺gt knit_prints ####
#-----------------------#

library(knitr)
library(gt)

knit_print.grouped_df <- function(x, options, ...) {
    if ("grouped_df" %in% class(x)) {
        x <- ungroup(x)
    }

    cl <- intersect(class(x), c("data.table", "data.frame"))[1]
    nrows <- ifelse(
        !is.null(options$total_rows),
        as.numeric(options$total_rows),
        dim(x)[1]
    )
    is_open <- ifelse(
        !is.null(options[["details-open"]]),
        as.logical(options[["details-open"]]),
        FALSE
    )

    cat(str_glue("\n<details{ifelse(is_open, ' open', '')}>\n"))
    cat("<summary>\n")
    cat(str_glue("\n*{cl} [{scales::label_comma()(nrows)} x {dim(x)[2]}]*\n"))
    cat("</summary>\n<br>\n")
    print(gt::as_raw_html(style_table(x, nrows)))
    cat("</details>\n\n")
}

registerS3method("knit_print", "grouped_df", knit_print.grouped_df)

knit_print.data.frame <- function(x, options, ...) {
    cl <- intersect(class(x), c("data.table", "data.frame"))[1]
    nrows <- ifelse(
        !is.null(options$total_rows),
        as.numeric(options$total_rows),
        dim(x)[1]
    )
    is_open <- ifelse(
        !is.null(options[["details-open"]]),
        as.logical(options[["details-open"]]),
        FALSE
    )

    cat(str_glue("\n<details{ifelse(is_open, ' open', '')}>\n"))
    cat("<summary>\n")
    cat(str_glue("\n*{cl} [{scales::label_comma()(nrows)} x {dim(x)[2]}]*\n"))
    cat("</summary>\n<br>\n")
    print(gt::as_raw_html(style_table(x, nrows)))
    cat("</details>\n\n")
}

registerS3method("knit_print", "data.frame", knit_print.data.frame)
