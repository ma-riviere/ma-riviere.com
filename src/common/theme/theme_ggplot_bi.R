#----------------------#
####🔺ggplot themes ####
#----------------------#

library(ggplot2)

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
  text = ggplot2::element_text(color = primary_color_light),
  ## Panel
  panel.border = ggplot2::element_rect(colour = primary_color_light),
  ## Titles
  plot.title = ggtext::element_markdown(colour = primary_color_light),
  plot.subtitle = ggtext::element_markdown(colour = primary_color_light),
  ## Legend
  legend.title = ggplot2::element_text(colour = primary_color_light),
  ## Facets
  strip.background = ggplot2::element_rect(fill = gg_strip_color),
  strip.text = ggplot2::element_text(colour = primary_color_light),
  ## Axes
  axis.text = ggplot2::element_text(colour = primary_color_light),
  axis.title.x = ggtext::element_markdown(colour = primary_color_light),
  axis.title.y = ggtext::element_markdown(colour = primary_color_light)
)

theme_light_mar <- base_theme_mar + light_addon_mar

dark_addon_mar <- ggplot2::theme(
  text = ggplot2::element_text(color = primary_color_dark),
  ## Panel
  panel.border = ggplot2::element_rect(colour = primary_color_dark),
  ## Titles
  plot.title = ggtext::element_markdown(colour = primary_color_dark),
  plot.subtitle = ggtext::element_markdown(colour = primary_color_dark),
  ## Legend
  legend.title = ggplot2::element_text(colour = primary_color_dark),
  ## Facets
  strip.background = ggplot2::element_rect(fill = gg_strip_color),
  strip.text = ggplot2::element_text(colour = primary_color_dark),
  ## Axes
  axis.text = ggplot2::element_text(colour = primary_color_dark),
  axis.title.x = ggtext::element_markdown(colour = primary_color_dark),
  axis.title.y = ggtext::element_markdown(colour = primary_color_dark)
)

theme_dark_mar <- base_theme_mar + dark_addon_mar

ggplot2::theme_set(theme_light_mar)