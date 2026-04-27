#!/usr/bin/env Rscript

# Exploratory alias diagnostics for the Conjoint Companion factorial-design tabs.
# This script intentionally lives outside the production Shiny app. It probes
# FrF2/DoE.base behavior and writes compact CSV examples for later UI work.

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

script_path <- sub(
  "^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1] %||% "dev/explore_alias_structure.R"
)
root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
setwd(root)

suppressPackageStartupMessages({
  library(FrF2)
  library(DoE.base)
  library(tidyverse)
})

source("functions_factorial.R")
source("custom_corr_plot.R")
source("R/ui_labels.R")

output_dir <- file.path("dev", "alias_examples")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)


# ---- Current app design-generation wrappers ---------------------------------

generate_two_level_fractional <- function(n_attributes, resolution) {
  FrF2::FrF2(
    nfactors = n_attributes,
    resolution = resolution,
    factor.names = paste0("att_", seq_len(n_attributes)),
    randomize = FALSE,
    alias.info = 3
  )
}


# ---- Effect naming helpers ---------------------------------------------------

effect_order <- function(effect) {
  stringr::str_count(effect, fixed(":")) + 1L
}

prettify_effect_label <- function(effect) {
  parts <- unlist(strsplit(effect, ":", fixed = TRUE))
  paste(prettify_attribute_label(parts), collapse = ":")
}

effect_terms <- function(factor_names, max_order = 3) {
  max_order <- min(max_order, length(factor_names))
  unlist(
    lapply(seq_len(max_order), function(order) {
      combn(factor_names, order, paste, collapse = ":", simplify = TRUE)
    }),
    use.names = FALSE
  )
}


# ---- Model-matrix alias diagnostics -----------------------------------------

coded_two_level_design <- function(design) {
  if (!"design" %in% class(design)) {
    design <- DoE.base::data2design(design)
  }

  factor_names <- names(DoE.base::factor.names(design))
  dat <- as.data.frame(design)[, factor_names, drop = FALSE]

  # Normalize any two-level coding to -1/+1 so interaction columns can be
  # computed as products. This handles FrF2 (-1/+1), full factorials (1/2), and
  # any app-side 0/1 table if a helper is reused later.
  dat[] <- lapply(dat, function(x) {
    values <- as.numeric(as.character(x))
    unique_values <- sort(unique(values))
    if (length(unique_values) != 2) {
      stop("Alias diagnostics require two-level factors.", call. = FALSE)
    }
    if (identical(unique_values, c(-1, 1))) {
      values
    } else {
      ifelse(values == unique_values[[1]], -1, 1)
    }
  })

  dat
}

effect_model_matrix <- function(design, max_order = 3) {
  dat <- coded_two_level_design(design)
  factors <- names(dat)
  effects <- effect_terms(factors, max_order = max_order)

  columns <- lapply(effects, function(effect) {
    parts <- unlist(strsplit(effect, ":", fixed = TRUE))
    Reduce(`*`, dat[, parts, drop = FALSE])
  })

  matrix <- as.data.frame(columns, check.names = FALSE)
  names(matrix) <- effects
  matrix
}

alias_lookup <- function(design, max_order = 3, tolerance = 1e-8) {
  mm <- effect_model_matrix(design, max_order = max_order)
  effects <- names(mm)
  correlations <- suppressWarnings(stats::cor(mm))

  tibble(effect = effects) |>
    mutate(
      effect_order = effect_order(effect),
      aliased_with = map(effect, function(effect_name) {
        effect_corr <- correlations[effect_name, ]
        aliases <- names(effect_corr)[
          names(effect_corr) != effect_name &
            !is.na(effect_corr) &
            abs(abs(effect_corr) - 1) < tolerance
        ]
        aliases
      })
    )
}

classify_alias_status <- function(effect_order_value, aliased_orders) {
  if (length(aliased_orders) == 0) {
    return("clear")
  }

  if (effect_order_value == 1 && any(aliased_orders <= 2)) {
    return("aliased")
  }

  if (effect_order_value == 2 && any(aliased_orders <= 2)) {
    return("aliased")
  }

  if (effect_order_value == 2 && all(aliased_orders >= 3)) {
    return("conditionally_clear")
  }

  if (effect_order_value == 3 && any(aliased_orders <= 3)) {
    return("aliased")
  }

  "conditionally_clear"
}

interpret_alias_row <- function(effect_order_value, status) {
  case_when(
    effect_order_value == 1 && status == "clear" ~
      "main effect is clear from two-way interactions in the checked effect space",
    effect_order_value == 1 && status == "aliased" ~
      "main effect may include a two-way interaction; interpret only if interactions are negligible",
    effect_order_value == 2 && status == "clear" ~
      "estimable as a two-way interaction",
    effect_order_value == 2 && status == "conditionally_clear" ~
      "clear from main effects and other two-way interactions; assumes listed higher-order terms are negligible",
    effect_order_value == 2 && status == "aliased" ~
      "do not interpret separately from the listed aliased effect(s)",
    effect_order_value == 3 && status == "clear" ~
      "estimable as a three-way interaction within the checked effect space",
    effect_order_value == 3 && status == "aliased" ~
      "three-way interaction is confounded with listed effect(s)",
    TRUE ~ "interpretation depends on assumptions about higher-order interactions"
  )
}

# Suggested app-facing helper. The output columns are intentionally close to a
# possible future reactable.
summarize_alias_structure <- function(design, max_order = 3) {
  aliases <- alias_lookup(design, max_order = max_order)

  aliases |>
    rowwise() |>
    mutate(
      aliased_orders = list(effect_order(aliased_with)),
      status = classify_alias_status(effect_order, aliased_orders),
      aliased_with = if (length(aliased_with) == 0) {
        NA_character_
      } else {
        paste(vapply(aliased_with, prettify_effect_label, character(1)), collapse = "; ")
      },
      effect = prettify_effect_label(effect),
      interpretation = interpret_alias_row(effect_order, status)
    ) |>
    ungroup() |>
    select(effect, effect_order, status, aliased_with, interpretation)
}

list_aliased_main_effects <- function(design) {
  summarize_alias_structure(design) |>
    filter(effect_order == 1, status != "clear")
}

list_aliased_2fis <- function(design) {
  summarize_alias_structure(design) |>
    filter(effect_order == 2, status == "aliased")
}

list_clear_2fis <- function(design) {
  summarize_alias_structure(design) |>
    filter(effect_order == 2, status %in% c("clear", "conditionally_clear"))
}

list_aliased_3fis <- function(design) {
  summarize_alias_structure(design) |>
    filter(effect_order == 3, status == "aliased")
}


# ---- Resolution feasibility --------------------------------------------------

resolution_message <- function(resolution) {
  switch(
    as.character(resolution),
    "3" = "This design is suitable for estimating main effects under the assumption that two-way interactions between manipulated attributes are negligible. Two-way interactions should not be interpreted because main effects may be aliased with two-way interactions.",
    "4" = "Main effects are clear from two-way interactions. Some two-way interactions may be aliased with other two-way interactions. Check the alias table before interpreting interaction effects.",
    "5" = "Main effects and two-way interactions are clear from each other and two-way interactions are not aliased with other two-way interactions. Interpretation still assumes that higher-order interactions are negligible.",
    "6" = "Some three-way interaction diagnostics may be possible, but feasibility depends on the number of attributes and runs. Report clearly which higher-order interactions are estimable.",
    "No prototype message defined for this resolution."
  )
}

design_resolution_feasibility <- function(n_attributes, resolution) {
  result <- try(
    generate_two_level_fractional(n_attributes, resolution),
    silent = TRUE
  )

  if (inherits(result, "try-error")) {
    return(tibble(
      n_attributes = n_attributes,
      requested_resolution = resolution,
      generation_succeeded = FALSE,
      meets_requested_resolution = FALSE,
      typical_n_profiles = NA_integer_,
      actual_resolution = NA_real_,
      function_package_used = "FrF2::FrF2",
      main_effects_clear = NA,
      two_way_interactions_clear = NA,
      three_way_interactions_potentially_interpretable = NA,
      note = conditionMessage(attr(result, "condition"))
    ))
  }

  actual_resolution <- if (nrow(result) == 2^n_attributes) {
    Inf
  } else {
    DoE.base::GR(result)$GR
  }
  meets_requested_resolution <- is.infinite(actual_resolution) || actual_resolution >= resolution
  alias_summary <- summarize_alias_structure(result, max_order = 3)

  tibble(
    n_attributes = n_attributes,
    requested_resolution = resolution,
    generation_succeeded = TRUE,
    meets_requested_resolution = meets_requested_resolution,
    typical_n_profiles = nrow(result),
    actual_resolution = actual_resolution,
    function_package_used = "FrF2::FrF2",
    main_effects_clear = !any(alias_summary$effect_order == 1 & alias_summary$status == "aliased"),
    two_way_interactions_clear = !any(alias_summary$effect_order == 2 & alias_summary$status == "aliased"),
    three_way_interactions_potentially_interpretable = is.infinite(actual_resolution) || actual_resolution >= 6,
    note = resolution_message(resolution)
  )
}


# ---- Selected theoretically important interactions --------------------------

selected_interaction_probe <- function() {
  important_model <- stats::as.formula(
    "~att_1+att_2+att_3+att_4+att_5+att_6+att_1:att_2+att_1:att_3"
  )

  first_try <- try(
    FrF2::FrF2(
      nfactors = 6,
      factor.names = paste0("att_", 1:6),
      estimable = important_model,
      clear = TRUE,
      randomize = FALSE
    ),
    silent = TRUE
  )

  second_try <- try(
    FrF2::FrF2(
      nruns = 32,
      nfactors = 6,
      factor.names = paste0("att_", 1:6),
      estimable = important_model,
      clear = TRUE,
      randomize = FALSE
    ),
    silent = TRUE
  )

  tibble(
    request = c(
      "automatic run-size search for att_1:att_2 and att_1:att_3 clear",
      "explicit 32-run search for att_1:att_2 and att_1:att_3 clear"
    ),
    success = c(!inherits(first_try, "try-error"), !inherits(second_try, "try-error")),
    n_profiles = c(
      if (inherits(first_try, "try-error")) NA_integer_ else nrow(first_try),
      if (inherits(second_try, "try-error")) NA_integer_ else nrow(second_try)
    ),
    message = c(
      if (inherits(first_try, "try-error")) conditionMessage(attr(first_try, "condition")) else "success",
      if (inherits(second_try, "try-error")) conditionMessage(attr(second_try, "condition")) else "success"
    )
  )
}


# ---- Generate example outputs ------------------------------------------------

feasibility <- crossing(
  n_attributes = 4:10,
  requested_resolution = 3:6
) |>
  pmap_dfr(function(n_attributes, requested_resolution) {
    design_resolution_feasibility(n_attributes, requested_resolution)
  })

readr::write_csv(feasibility, file.path(output_dir, "resolution_feasibility.csv"))

for (n_attributes in 4:10) {
  for (resolution in 3:6) {
    design <- try(generate_two_level_fractional(n_attributes, resolution), silent = TRUE)
    if (inherits(design, "try-error")) {
      next
    }

    alias_summary <- summarize_alias_structure(design, max_order = 3)
    file_name <- sprintf(
      "alias_summary_%02d_attributes_resolution_%s.csv",
      n_attributes,
      resolution
    )
    readr::write_csv(alias_summary, file.path(output_dir, file_name))
  }
}

selected_probe <- selected_interaction_probe()
readr::write_csv(selected_probe, file.path(output_dir, "selected_interaction_probe.csv"))

cat("Wrote alias exploration outputs to", normalizePath(output_dir), "\n")
cat("FrF2 version:", as.character(packageVersion("FrF2")), "\n")
cat("DoE.base version:", as.character(packageVersion("DoE.base")), "\n")
