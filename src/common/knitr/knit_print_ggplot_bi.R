#---------------------------#
####🔺ggplot knit_prints ####
#---------------------------#

library(knitr)
library(ggplot2)

## Inspired by: https://debruine.github.io/quarto_demo/dark_mode.html
knit_print.ggplot <- function(x, options, ...) {
  if(any(grepl("patchwork", class(x)))) {
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