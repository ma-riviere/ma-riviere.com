####╔════  ═══╗####
####💠 Theme 💠####
####╚════  ═══╝####

#---------------#
####🔺Colors ####
#---------------#

color_text <- "#888888"

bg_color_light <- "white"
primary_color_light <- "black"
secondary_color_light <- "#0d6efd"

bg_color_dark <- "#222"
primary_color_dark <- "white"
secondary_color_dark <- "#20c997"

gg_strip_color <- "#adb5bd"
gt_strip_color <- "#efefef"

options(
  ggplot2.discrete.colour = \() scale_color_viridis_d(),
  ggplot2.discrete.fill = \() scale_fill_viridis_d(),
  ggplot2.continuous.colour = \() scale_color_viridis_c(),
  ggplot2.continuous.fill = \() scale_fill_viridis_c(),
  ggplot2.binned.colour = \() scale_color_viridis_b(),
  ggplot2.binned.fill = \() scale_fill_viridis_b()
)