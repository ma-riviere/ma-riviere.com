#---------------------#
#### GGplot themes ####
#---------------------#

library(ggplot2)
library(knitr)

color_light <- ifelse(exists("color_light"), color_light, "black")
color_dark <- ifelse(exists("color_dark"), color_dark, "white")
strip_color <- ifelse(exists("strip_color"), strip_color, "#D4D4D4")

base_theme_mar <- ggplot2::theme_minimal() +
  ggplot2::theme(
    plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
    ## Panel
    panel.background = ggplot2::element_rect(fill = "transparent", colour = NA),
    panel.border = ggplot2::element_rect(fill = "transparent"),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    ## Titles
    plot.title = ggtext::element_markdown(size = 18, face = "bold"),
    plot.subtitle = ggtext::element_markdown(size = 15, face = "italic"),
    ## Legend
    legend.title = ggplot2::element_text(size = 16, face = "bold"),
    legend.text = ggplot2::element_text(size = 15),
    legend.background = ggplot2::element_rect(fill = "transparent", colour = NA),
    legend.key = ggplot2::element_rect(fill = "transparent", colour = NA),
    ## Facets
    strip.text = ggplot2::element_text(size = 15, face = "bold"),
    ## Axes
    axis.title.x = ggtext::element_markdown(size = 15, face = "bold", hjust = 0.5),
    axis.title.y = ggtext::element_markdown(size = 15, face = "bold", hjust = 0.5),
    axis.text.x = ggplot2::element_text(size = 13),
    axis.text.y = ggplot2::element_text(size = 13),
  )

light_addon_mar <- ggplot2::theme(
  text = ggplot2::element_text(color = color_light),
  ## Panel
  panel.border = ggplot2::element_rect(colour = color_light),
  ## Titles
  plot.title = ggtext::element_markdown(colour = color_light),
  plot.subtitle = ggtext::element_markdown(colour = color_light),
  ## Legend
  legend.title = ggplot2::element_text(colour = color_light),
  ## Facets
  strip.background = ggplot2::element_rect(fill = strip_color),
  strip.text = ggplot2::element_text(colour = color_light),
  ## Axes
  axis.text = ggplot2::element_text(colour = color_light),
  axis.title.x = ggtext::element_markdown(colour = color_light),
  axis.title.y = ggtext::element_markdown(colour = color_light)
)

theme_light_mar <- base_theme_mar + light_addon_mar

dark_addon_mar <- ggplot2::theme(
  text = ggplot2::element_text(color = color_dark),
  ## Panel
  panel.border = ggplot2::element_rect(colour = color_dark),
  ## Titles
  plot.title = ggtext::element_markdown(colour = color_dark),
  plot.subtitle = ggtext::element_markdown(colour = color_dark),
  ## Legend
  legend.title = ggplot2::element_text(colour = color_dark),
  ## Facets
  strip.background = ggplot2::element_rect(fill = strip_color),
  strip.text = ggplot2::element_text(colour = color_dark),
  ## Axes
  axis.text = ggplot2::element_text(colour = color_dark),
  axis.title.x = ggtext::element_markdown(colour = color_dark),
  axis.title.y = ggtext::element_markdown(colour = color_dark)
)

theme_dark_mar <- base_theme_mar + dark_addon_mar

ggplot2::theme_set(theme_light_mar)


#--------------------------#
#### Custom knit_prints ####
#--------------------------#

## Inspired by: https://debruine.github.io/quarto_demo/dark_mode.html
knit_print.ggplot <- function(x, options, ...) {
  if(any(stringr::str_detect(class(x), "patchwork"))) {
    plot_dark <- x & dark_addon_mar
    plot_light <- x & light_addon_mar
  } else {
    plot_dark <- x + dark_addon_mar
    plot_light <- x + light_addon_mar
  }
  
  cat('\n<div class="light-mode">\n')
  print(plot_light)
  cat('</div>\n')
  cat('<div class="dark-mode">\n')
  print(plot_dark)
  cat('</div>\n\n')
}
registerS3method("knit_print", "ggplot", knit_print.ggplot)