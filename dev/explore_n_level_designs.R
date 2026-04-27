#!/usr/bin/env Rscript

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

script_path <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1] %||% "dev/explore_n_level_designs.R")
root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
setwd(root)

suppressPackageStartupMessages({
  library(tidyverse)
  library(DoE.base)
})

source("R/ui_labels.R")
source("R/interaction_coverage.R")
source("functions_factorial.R")

parse_levels <- function(value) {
  as.integer(strsplit(value, ",", fixed = TRUE)[[1]])
}

summarize_generated_design <- function(input, criterion) {
  levels <- parse_levels(input)
  full_factorial_size <- prod(levels)
  result <- try(get_n_level_fractional(input, criterion), silent = TRUE)

  if (inherits(result, "try-error")) {
    return(tibble(
      input = input,
      criterion = criterion,
      levels = paste(levels, collapse = " x "),
      full_factorial_size = full_factorial_size,
      generated_n_profiles = NA_integer_,
      reduction_achieved = NA,
      pairwise_works = NA_integer_,
      pairwise_total = choose(length(levels), 2),
      error = as.character(result)
    ))
  }

  coverage <- n_level_interaction_coverage(
    result$table,
    n_level_attribute_counts(input)
  )

  tibble(
    input = input,
    criterion = criterion,
    levels = paste(levels, collapse = " x "),
    full_factorial_size = full_factorial_size,
    generated_n_profiles = nrow(result$table),
    reduction_achieved = nrow(result$table) < full_factorial_size,
    pairwise_works = sum(coverage$status == "works"),
    pairwise_total = nrow(coverage),
    error = NA_character_
  )
}

summarize_available_arrays <- function(input) {
  levels <- parse_levels(input)
  arrays <- try(
    show.oas(
      nlevels = levels,
      regular = "all",
      GRgt3 = "all",
      Rgt3 = TRUE,
      show = 0,
      parents.only = FALSE,
      showGRs = TRUE,
      showmetrics = TRUE,
      digits = 2
    ),
    silent = TRUE
  )

  if (inherits(arrays, "try-error") || is.null(arrays) || nrow(arrays) == 0) {
    return(tibble(
      input = input,
      candidate_name = NA_character_,
      nruns = NA_integer_,
      GR = NA_real_,
      lineage = NA_character_
    ))
  }

  arrays |>
    as_tibble() |>
    arrange(nruns) |>
    transmute(
      input = input,
      candidate_name = name,
      nruns = nruns,
      GR = GR,
      lineage = lineage
    ) |>
    slice_head(n = 8)
}

inputs <- c(
  "3,3,4,4",
  "3,3,3,3",
  "2,3,4,4",
  "4,4,4,4",
  "2,2,3,3,4"
)

generated_summary <- purrr::map_dfr(inputs, function(input) {
  purrr::map_dfr(c("main_effects", "two-way"), function(criterion) {
    summarize_generated_design(input, criterion)
  })
})

array_summary <- purrr::map_dfr(inputs, summarize_available_arrays)

dir.create(file.path("dev", "n_level_examples"), showWarnings = FALSE, recursive = TRUE)
readr::write_csv(generated_summary, file.path("dev", "n_level_examples", "generated_summary.csv"))
readr::write_csv(array_summary, file.path("dev", "n_level_examples", "available_arrays.csv"))

print(generated_summary, n = Inf)
print(array_summary, n = Inf)
