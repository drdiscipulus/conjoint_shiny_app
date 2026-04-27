#!/usr/bin/env Rscript

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

script_path <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1] %||% "dev/deviation_box_jitter_demo.R")
root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
setwd(root)

suppressPackageStartupMessages({
  library(tidyverse)
  library(plotly)
  library(htmlwidgets)
  library(viridis)
})

source("R/upload_validation.R")
source("R/ui_labels.R")
source("R/ui_components.R")
source("functions_reliability.R")

dat <- read.csv("demo_data.csv")
dat <- validate_reliability_dataset(dat)$data
deviation_dat <- wide_to_long(compute_deviation(dat))
deviation_dat$profile <- factor(deviation_dat$profile, levels = unique(deviation_dat$profile))

plot_font <- list(family = "Arial", color = "#17211d", size = 13)
axis_title_font <- list(family = "Arial", color = "#17211d", size = 15)

p <- plot_ly(
  deviation_dat,
  x = ~profile,
  y = ~deviation,
  color = ~profile,
  colors = viridis_pal(option = "C", direction = -1)(length(unique(deviation_dat$profile))),
  type = "box",
  boxpoints = "all",
  jitter = 0.42,
  pointpos = 0,
  marker = list(size = 5, opacity = 0.46, line = list(width = 0)),
  line = list(color = "#17211d", width = 1),
  fillcolor = "rgba(0, 146, 96, 0.16)",
  hovertemplate = paste(
    "<b>%{x}</b>",
    "<br>Deviation: %{y}",
    "<extra></extra>"
  )
) |>
  layout(
    font = plot_font,
    paper_bgcolor = "white",
    plot_bgcolor = "white",
    margin = list(l = 70, r = 25, t = 30, b = 80),
    showlegend = FALSE,
    yaxis = list(
      title = list(text = "Replication minus initial response", font = axis_title_font),
      gridcolor = "#d8dfdc",
      zerolinecolor = "#17211d",
      zerolinewidth = 1.5
    ),
    xaxis = list(
      title = list(text = "Profile", font = axis_title_font),
      categoryarray = levels(deviation_dat$profile),
      categoryorder = "array",
      tickangle = -35,
      gridcolor = "#ffffff",
      zerolinecolor = "#ffffff"
    )
  ) |>
  config(
    displaylogo = FALSE,
    modeBarButtonsToRemove = c(
      "toggleSpikelines",
      "hoverClosestCartesian",
      "hoverCompareCartesian"
    ),
    toImageButtonOptions = list(
      format = "png",
      filename = "deviation_box_jitter_plot",
      width = 1200,
      height = 720,
      scale = 2
    )
  )

out <- file.path("dev", "deviation_box_jitter_demo.html")
htmlwidgets::saveWidget(p, out, selfcontained = FALSE)
cat(normalizePath(out, winslash = "\\", mustWork = TRUE), "\n")
