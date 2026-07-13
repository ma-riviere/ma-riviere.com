#----------------------------------#
####🔺knitr interactive display ####
#----------------------------------#

library(htmltools)
library(reactable)

## Getting list to display nicely in rendered documents
make_list_reactable <- function(list_dat) {
    list_name <- deparse(substitute(list_dat))

    get_list_elt_dim <- function(elt) {
        list_elt <- list_dat[[elt]]
        list_elt_dim <- if (any(c("data.frame", "matrix") %in% class(list_elt))) {
            dim(list_elt)
        } else {
            length(list_elt)
        }

        return(paste0(list_elt_dim, collapse = ", "))
    }

    dat <- data.frame(names(list_dat)) |>
        set_names(list_name) |>
        mutate(
            Type = unlist(pick(list_name)) |>
                map_chr(\(x) class(list_dat[[x]]) |> paste0(collapse = ", ")),
            Dimensions = unlist(pick(list_name)) |> map_chr(get_list_elt_dim)
        )

    get_list_details <- function(dat, idx, max_print = 200, max_digits = 3) {
        Element <- dat[[idx]]
        style <- "padding: 0.5rem"

        if (any(c("data.frame", "matrix") %in% class(Element))) {
            reactable(
                data.frame(Element),
                outlined = TRUE,
                striped = TRUE,
                highlight = TRUE,
                compact = TRUE
            ) |>
                htmltools::div(style = style)
        } else if ("list" %in% class(Element)) {
            make_list_reactable(Element)
        } else if (length(Element) > max_print) {
            htmltools::div(
                htmltools::p(
                    head(Element, max_print) |>
                        round(max_digits) |>
                        paste0(collapse = ", ") |>
                        paste("...", sep = ", ")
                ),
                htmltools::p(
                    stringr::str_glue(
                        "[ omitted {length(Element) - max_print} entries ]"
                    ),
                    style = "font-style: italic"
                ),
                style = style
            )
        } else {
            htmltools::div(
                round(Element, max_digits) |> paste0(collapse = ", "),
                style = style
            )
        }
    }

    reactable(
        dat,
        defaultColDef = colDef(vAlign = "center", headerVAlign = "center"),
        details = \(idx) get_list_details(list_dat, idx),
        outlined = TRUE,
        striped = TRUE,
        highlight = TRUE,
        compact = FALSE,
        fullWidth = TRUE,
        defaultPageSize = 15
    )
}
