library(gt)
library(gtExtras, include.only = c("gt_highlight_rows"))

header_color <- ifelse(exists("header_color"), header_color, "#0d6efd")
color_text <- ifelse(exists("color_text"), color_text, "#888888")
strip_color <- ifelse(exists("strip_color"), strip_color, "#D4D4D4")

#--------------------#
#### Table themes ####
#--------------------#

format_pvalue <- function(p) glue::glue("{scales::pvalue(p)} {gtools::stars.pval(p) |> str_remove_all(fixed('.'))}")

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
    fns = \(x) purrr::map_chr(x, \(v) ifelse(!is.na(v) && utils::type.convert(v, as.is = TRUE) |> is.numeric(), format_pvalue(as.numeric(v)), v))
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
         cell_text(color = header_color, weight = "bold"),
         cell_borders(sides = c("top", "bottom"), color = header_color, style = "solid", weight = px(2))
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
    gt_tbl <- gt_tbl |> gtExtras::gt_highlight_rows(rows = seq(2, nrow(gt_tbl[["_data"]]), by = 2), fill = strip_color, font_weight = "normal", alpha = 0.2)
  
  return(gt_tbl)
}

style_table <- function(data, total_rows = NULL, nrows_print = 15) {
  nrows <- ifelse(is.null(total_rows), nrow(data), total_rows)
  
  gt::gt(data |> head(nrows_print)) |> 
    format_gt() |>
    gt_style() |> 
    bind(x, if(nrows > nrows_print) x |> tab_source_note(md(glue::glue("*[ omitted {scales::label_comma()(nrows - nrows_print)} entries ]*"))) else x)
}



#--------------------------#
#### Custom knit_prints ####
#--------------------------#

knit_print.grouped_df <- function(x, options, ...) {
  if ("grouped_df" %in% class(x)) x <- ungroup(x)
  
  cl <- intersect(class(x), c("data.table", "data.frame"))[1]
  nrows <- ifelse(!is.null(options$total_rows), as.numeric(options$total_rows), dim(x)[1])
  
  cat("\n<details>\n")
  cat("<summary>\n")
  cat(glue::glue("\n*{cl} [{scales::label_comma()(nrows)} x {dim(x)[2]}]*\n"))
  cat("</summary>\n<br>\n")
  print(style_table(x, nrows))
  cat("</details>\n\n")
}
registerS3method("knit_print", "grouped_df", knit_print.grouped_df)

knit_print.data.frame <- function(x, options, ...) {
  cl <- intersect(class(x), c("data.table", "data.frame"))[1]
  nrows <- ifelse(!is.null(options$total_rows), as.numeric(options$total_rows), dim(x)[1])
  
  cat("\n<details>\n")
  cat("<summary>\n")
  cat(glue::glue("\n*{cl} [{scales::label_comma()(nrows)} x {dim(x)[2]}]*\n"))
  cat("</summary>\n<br>\n")
  print(style_table(x, nrows))
  cat("</details>\n\n")
}
registerS3method("knit_print", "data.frame", knit_print.data.frame)
