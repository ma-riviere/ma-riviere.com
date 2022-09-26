#------------------#
####🔺gt themes ####
#------------------#

library(gt)
library(gtExtras, include.only = c("gt_highlight_rows"))

get_cell_dim <- function(x) {
  dim <- NULL
  if (is.list(x) || is.vector(x)) dim <- length(x)
  if (length(dim(x) > 1)) dim <- glue::glue('{dim(x)[1]} x {dim(x)[2]}')
  return(dim)
}

summarize_nested_col <- \(x) lapply(x, \(r) glue::glue("<{class(r)[[1]]} [{get_cell_dim(r)}]>"))

format_gt <- function(gt_tbl) {
  
  gt_tbl <- gt::fmt(
    gt_tbl,
    columns = select(gt_tbl[["_data"]], where(is.list) | where(\(c) "tbl_df" %in% class(c))) |> colnames(),
    fns = \(x) summarize_nested_col(x)
  )
  
  gt_tbl <- gt::fmt(
    gt_tbl,
    columns = select(gt_tbl[["_data"]], matches("p.val|^pr|pr\\(.*\\)|^p$")) |> colnames(),
    fns = \(x) purrr::map_chr(x, \(v) ifelse(!is.na(v) && utils::type.convert(v, as.is = TRUE) |> is.numeric(), label_pval(as.numeric(v)), v))
  )
  
  gt_tbl <- gt::fmt_number(
    gt_tbl,
    columns = select(gt_tbl[["_data"]], where(\(v) is.numeric(v))) |> colnames(),
    decimals = 3, sep_mark = " ", drop_trailing_zeros = TRUE # n_sigfig = 2
  )
  
  return(gt_tbl)
}

gt_style <- function(gt_tbl) {
  gt_tbl <- (
    gt_tbl
    |> gt::tab_style(
      style = list(
        cell_text(color = secondary_color_light, weight = "bold"),
        cell_borders(sides = c("top", "bottom"), color = secondary_color_light, style = "solid", weight = px(2))
      ),
      locations = list(cells_title(), cells_column_labels())
    )
    |> gt::tab_style(
      style = list(cell_text(color = color_text)),
      locations = list(cells_stub(), cells_body(), cells_row_groups(), cells_footnotes(), cells_source_notes())
    )
    |> gt::tab_style(
      style = list(cell_text(weight = "bold")),
      locations = list(cells_row_groups())
    )
    |> gt::tab_options(container.width = pct(100), table.width = pct(100), table.background.color = "#FFFFFF00")
  )
  
  if (nrow(gt_tbl[["_data"]]) > 2)
    gt_tbl <- gt_tbl |> gtExtras::gt_highlight_rows(rows = seq(2, nrow(gt_tbl[["_data"]]), by = 2), fill = gt_strip_color, font_color = "black", font_weight = "normal", alpha = 0.6)
  
  return(gt_tbl)
}

style_table <- function(data, total_rows = NULL, nrows_print = 15) {
  nrows <- ifelse(is.null(total_rows), nrow(data), total_rows)
  
  gt::gt(data |> head(nrows_print)) |> 
    format_gt() |>
    gt_style() |> 
    bind(x, if(nrows > nrows_print) x |> tab_source_note(md(glue::glue("*[ omitted {scales::label_comma()(nrows - nrows_print)} entries ]*"))) else x)
}