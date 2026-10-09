# --- load libraries ---
library(sysfonts)
library(showtext)
library(ggplot2)
library(plotly)

# --- how to use ---
# load the theme script once in the setup chunk 
# source(here("scripts", "02-custom_themes.R")) 
# 
# --- Static plots ---
# add theme and color scale at the end 
#  e.g. ggplot() + ... + scale_color_group1() + theme_static()
# 
# --- Interactive plots ---
# pipe the plot into the theme as the last step 
# e.g. interactive_plot |> theme_interactive()
# 
# ---- Things plotly theme will not be able to do ---- 
#  - point and line colors, need to be set in the intitial graph and in 
#    list with the group colors can be specified according to value 
#  - bold text: wrap it in <b></b>, e.g. title = "<b>My axis title</b>"
#  - the font is loaded from Google Fonts, so it needs internet;
#    without internet plotly falls back to a standard sans-serif font
#  - plotly needs color codes 

# note: think this is a very nice website to play around with color combinations
# https://projects.susielu.com/viz-palette 



# ---- shared style values -----
# these values are employed within the custom themes so can be adjusted
# and tweaked outside of the functions

# 1. --- Text ---
group_font <- "Quicksand" # font family
group_b_size <- 13 # base text size
group_prim_text <- "#3f1d00" # main text color, applied to titles
group_sec_text <- "#553018" # secondary text color
group_px <- list(
  title = 25,
  subtitle = 15
)

# load the google font using different weights
font_add_google(
  name = group_font,
  family = group_font,
  regular.wt = 500,
  bold.wt = 700
)
showtext_auto()

# 2. --- Background and grid ---
group_bg_col <- "#F5F0E8" # plot background
group_grid_col <- "grey90" # gridlines

# 3. --- Data colors ---
group_colors <- c(
  "Lower disadvantage" = "#B19545",
  "Typical" = "#667A4C",
  "Higher disadvantage" = "#B66A4F"
)

group_neutral_col <- "#8F9694" # default color for data points not highlighted


# ---- theme for static plots ----
# Can be used for static base plots
theme_static <- 
  function(base_size = group_b_size, base_family = group_font) {
    theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # ---- Text ----
      text = element_text(color = group_prim_text),
      plot.title = element_text(
        face = "bold",
        size = rel(1.3),
        color = group_prim_text,
        margin = margin(b = 4)
      ),
      plot.subtitle = element_text(
        face = "plain",
        color = group_sec_text,
        margin = margin(b = 10)
      ),
      plot.caption = element_text(
        size = rel(0.8),
        color = group_sec_text
      ),
      axis.title = element_text(
        face = "bold",
        color = group_prim_text
      ),
      axis.text = element_text(color = group_sec_text),

      # ---- Background and Grid ----
      plot.background = element_rect(
        fill = group_bg_col,
        color = NA
      ),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),

      # ---- Legend ----
      legend.position = "top",
      legend.title = element_text(
        size = rel(0.9),
        face = "bold",
        color = group_prim_text
      ),
      legend.text = element_text(
        size = rel(0.85),
        color = group_sec_text
      ),

      # ---- Spacing ----
      plot.title.position = "plot",
      plot.margin = margin(15, 15, 10, 15)
    )
}

# applying the group color palette
# --- custom color palette can be set at the top ---
scale_color_group1 <- function(...) {
  scale_color_manual(values = group_colors, ...)
}

# --- custom color palette for fill colors ---
scale_fill_group1 <- function(...) {
  scale_color_manual(values = group_colors, ...)
}

# ---- theme for interactive plots ----
# same aesthetics as theme_static but applicable to plotly plots 
# use it as last step: plotly_plot |> theme_interactive()
theme_interactive <- 
  function(p, base_size = group_b_size, base_family = group_font) {
    # size of all the labels match the subtitle 
    size <- group_px$subtitle 
    
  
    p <- p |>
      layout(
        # ---- Text ----
        font = list(family = base_family,
                    size = size,
                    color = group_prim_text),
        # ---- Background and Grid ----
        paper_bgcolor = group_bg_col, 
        plot_bgcolor = group_bg_col,
        xaxis = list(showgrid = FALSE,
                     zeroline = FALSE,
                     tickfont = list(size = size * 0.8,
                                     color = group_sec_text)), 
        yaxis = list(showgrid = FALSE,
                     zeroline = FALSE,
                     tickfont = list(size = size * 0.8,
                                     color = group_sec_text)),
        # ---- legend ----
        legend = list(
          title = list(font = list(size = size * 0.9,
                                   color = group_prim_text)),
          font = list(size = size * 0.85,
                      color = group_sec_text)
        )
      )
    # showtext doesn't work in plotly 
    font_url <- paste0("https://fonts.googleapis.com/css2?family=", base_family,
                       ":wght@500;700&display=swap")
    htmlwidgets::prependContent(p, htmltools::tags$link(rel = "stylesheet", href = font_url))
  }
