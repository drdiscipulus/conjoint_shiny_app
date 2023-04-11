# Other Helpers

## Upload function
file_upload <- function(input) {
  # Store upload path and name values
  input_file <- input
  extension <- tools::file_ext(input_file$name)
  filepath <- input_file$datapath

  # If statement with file extension condition for selection
  if (extension == "csv") {
    # Try to read file
    res <- try(
      # Read .csv file
      vroom::vroom(filepath, na = c("","NA")),
      silent = TRUE
    )
  } else if (extension == "xlsx") {
    # Try to read file
    res <- try(
      # Read .xlsx file
      openxlsx::read.xlsx(filepath, na.strings = c("","NA"))
    )
  } else {
    res <- NULL
  }

  # Return
  return(res)
}


## Select required columns and make them lower case
column_checker <- function(dat) {
  # Try to select all required columns
  res <- try(
    dat |>
      select(respondent, round, profile, dv, starts_with("att_")) |> 
      rename_with(tolower), silent = TRUE
  )

  # Return
  return(res)
}


## Number of attributes checker
attribute_checker <- function(dat) {
  res <- try(
    dat |>
      select(starts_with("att_")) |>
      ncol(),
    silent = TRUE
  )

  # Return
  return(res)
}


## Data type checker and coercion
class_checker <- function(dat) {
  res <- try(
    dat |>
      mutate_at(c("round", "profile", "dv"), as.numeric) |>
      mutate(across(starts_with("att_"), as.numeric)),
    silent = TRUE
  )

  # Return
  return(res)
}


## Round variable checker
round_checker <- function(dat) {
  # Get number of unique values
  unique_values <- unique(dat$round)

  # Check if length is two
  if (length(unique_values) == 2) {
    # Check if it is 1 and 2
    required_values <- c(1, 2)
    check <- unique_values %in% required_values

    # Check if all true, if not return FALSE
    if (all(check)) {
      res <- TRUE
    } else {
      res <- FALSE
    }
  } else {
    res <- FALSE
  }
}


# Function to get type and class info on data
class_type_overview <- function(dat) {
  
  # Get information
  var_names <- colnames(dat)
  class_info <- sapply(dat, class)  
  type_info <- sapply(dat, typeof)
  
  # Create table
  res <- tibble(Variable = var_names,
                Class = class_info,
                Type = type_info)
  
  # Return table
  return(res)
}


# Test-Retest Reliability

## Pearson's R

# This function takes a data set as an input, splits it into the initial and
# replication responses, calculates the correlation for each profile, and
# returns a correlation vector.
rel_cor <- function(dat) {
  # First round of responses
  initial_dat <- dat |>
    filter(round == 1) |>
    select(respondent, profile, dv) |>
    group_by(profile) |>
    group_split()
  # Second round of responses
  replication_dat <- dat |>
    filter(round == 2) |>
    select(respondent, profile, dv) |>
    group_by(profile) |>
    group_split()
  # Map over all profiles and compute their correlations
  cor <- map2(initial_dat, replication_dat, ~ cor(.x$dv, .y$dv))
  # Collapse list to vector
  cor <- unlist(cor)
  # Return
  return(cor)
}


## ICC(3,k)

# This function takes a data set as an input, splits it into the initial and
# replication responses, calculates the ICC(3,k) for each profile by calling an
# additional helper function, and returns a data frame with ICC(3,k) and its
# 95% confidence interval.
rel_icc <- function(dat) {
  # First round of responses
  initial_dat <- dat |>
    filter(round == 1) |>
    select(respondent, profile, dv) |>
    group_by(profile) |>
    group_split()

  # Second round of responses
  replication_dat <- dat |>
    filter(round == 2) |>
    select(respondent, profile, dv) |>
    group_by(profile) |>
    group_split()
  # Map over all profiles and compute the ICC(3,k)
  res <- map2_dfr(initial_dat, replication_dat, ~ icc_3k(.x, .y))
  # Return
  return(res)
}


# Function to compute the ICC(3,k)
icc_3k <- function(initial, replication) {
  # Get all profile names/numbers
  profile <- unique(initial$profile)
  # Create temporary data set
  tmp <- tibble(initial = initial$dv, replication = replication$dv)
  # Compute ICCs and extract ICC(3,k) and its 95% confidence interval
  icc <- ICC(tmp,
    missing = TRUE,
    alpha = .05,
    lmer = FALSE,
    check.keys = FALSE
  )$results |>
    filter(type == "ICC3k") |>
    select(ICC, "lower bound", "upper bound") |>
    rename(icc_lower = "lower bound", icc_upper = "upper bound") |>
    mutate_all(round, 2) |>
    mutate(ICC = if_else(ICC < 0, 0, ICC)) |>
    mutate(icc_lower = if_else(icc_lower < 0, 0, icc_lower)) |>
    remove_rownames()
  # Create table
  res <- cbind(profile, icc)
  # Return result
  return(res)
}


## Slope Difference Tests

# This function takes a data set as an input, splits it into initial and
# replication responses, fits two linear models with robust standard errors and
# then calls an additional function to perform a slope difference test an each
# coefficient. This additional function takes a variable name, two beta
# coefficients and standard errors as inputs to conduct perform a
# slope difference test.
slope_difference <- function(dat) {
  # First round of responses
  initial.df <- dat |>
    filter(round == 1)
  # Second round of responses
  replication.df <- dat |>
    filter(round == 2)
  # Create regression formula
  reg_form <- initial.df |>
    select(-c(respondent, round, profile, dv)) |>
    select(starts_with("att_")) |>
    colnames() |>
    paste0(collapse = " + ")
  reg_form <- formula(paste0("dv ~ ", reg_form))

  # Fit a linear regression model on both rounds of responses
  m1.model <- lm(reg_form, data = initial.df)
  m2.model <- lm(reg_form, data = replication.df)

  # Calculate and capture clustered standard errors
  m1.tidy <- model_parameters(
    m1.model,
    vcov = "vcovCL",
    vcov_args = list(type = "HC1", cluster = initial.df$respondent)
  )
  m2.tidy <- model_parameters(
    m2.model,
    vcov = "vcovCL",
    vcov_args = list(type = "HC1", cluster = replication.df$respondent)
  )
  # Drop intercept to tidy the dataframe
  m1.tidy <- filter(m1.tidy, Parameter != "(Intercept)")
  m2.tidy <- filter(m2.tidy, Parameter != "(Intercept)")

  # Transform data frame rows into a list of single row data frames
  m1.list <- m1.tidy |>
    group_by(Parameter) |>
    group_split()
  m2.list <- m2.tidy |>
    group_by(Parameter) |>
    group_split()

  # Apply the slope difference test function to the lists of single row data frames
  res <- map2_dfr(
    m1.list, m2.list,
    ~ get_difference(
      name = .x$Parameter,
      b1 = .x$Coefficient,
      se1 = .x$SE,
      b2 = .y$Coefficient,
      se2 = .y$SE
    )
  )


  # Create result table
  res_table <- tibble(
    iv = m1.tidy$Parameter,
    beta_i = round(m1.tidy$Coefficient, 2),
    se_i = round(m1.tidy$SE, 2),
    p_i = round(m1.tidy$p, 4),
    beta_r = round(m2.tidy$Coefficient, 2),
    se_r = round(m2.tidy$SE, 2),
    p_r = round(m2.tidy$p, 4),
    beta_diff = res$Beta_diff,
    joint_se = res$Joint_se,
    test_statistic = res$Test_statistic,
    stat_diff = res$Stat_diff
  )

  # Return table
  return(res_table)
}


# Function to compute the slope difference test on a single predictor
get_difference <- function(name, b1, se1, b2, se2) {
  # Compute the difference between both beta coefficients
  b <- b1 - b2
  # Compute the corresponding standard error
  se <- sqrt((se1^2) + (se2^2))
  # Multiply the standard error by two to obtain at least the 95% CI
  test <- se * 2
  # Check if the absolute beta difference is at least two SEs away from zero
  if (abs(b) >= test) {
    # If true, then both slopes are significantly different from another
    res <- "Yes"
  } else {
    # If false, both slopes are not significantly different from another
    res <- "No"
  }

  # Create table
  res <- tibble(
    Coefficient = name,
    Beta_diff = b,
    Joint_se = se,
    Test_statistic = abs(b) - (2 * se),
    Stat_diff = res
  )

  # Round all values to two digits
  res <- mutate(res, across(where(is.double), ~ round(.x, 2)))

  # Return table
  return(res)
}

# Regression

# Function to compute a pooled regression model with both rounds of data
# and uses two-way clustered standard errors - round and respondent
pooled_regression <- function(dat) {
  # Convert the grouping variables to a factor
  multi.df <- dat |>
    mutate(
      round = as_factor(round),
      respondent = as_factor(respondent)
    )

  # Create regression formula
  reg_form <- multi.df |>
    select(-c(respondent, round, profile, dv)) |>
    select(starts_with("att_")) |>
    colnames() |>
    paste0(collapse = " + ")
  reg_form <- formula(paste0("dv ~ ", reg_form))

  # Fit a linear regression model
  m3_model <- lm(reg_form, data = multi.df)

  # Obtain and show two-way clustered standard errors (by respondent and round)
  res <- coeftest(m3_model, vcov = vcovCL, cluster = ~ respondent + round)

  # Tidy result
  param <- tidy(res)

  # Change labels
  param <- param |>
    mutate(estimate = round(estimate, 2)) |>
    mutate(std.error = round(std.error, 2)) |>
    mutate(statistic = round(statistic, 2)) |>
    mutate(p.value = round(p.value, 4)) |>
    rename(Coefficient = term) |>
    rename(Beta = estimate) |>
    rename(`t-ratio` = statistic) |>
    rename(`p-value` = p.value) |>
    rename(SE = std.error)

  # Extract model fit
  fit <- glance(m3_model)

  # Model fit string
  fit_txt <- paste0(
    "Model Fit: R-Squared = ", round(fit$r.squared, 2),
    "; R-Squared (adjusted) = ", round(fit$adj.r.squared, 2),
    "; Sigma = ", round(fit$sigma, 2), "; ", fit$nobs,
    " Observations, nested in ", length(unique(multi.df$respondent)), " Respondents."
  )

  # Add fit and observations to results
  res <- list(dat = param, fit = fit_txt)

  # Return result list
  return(res)
}


# Plots

## Violin Plots

### Response Deviations

# This function takes a data set as an input, splits it into initial and
# replication responses and computes, for each profile, the difference
# between responses for each respondent.
compute_deviation <- function(dat) {
  # First round of responses
  initial_dat <- dat |>
    filter(round == 1) |>
    select(respondent, profile, dv) |>
    group_by(profile) |>
    group_split()

  # Second round of responses
  replication_dat <- dat |>
    filter(round == 2) |>
    select(respondent, profile, dv) |>
    group_by(profile) |>
    group_split()

  # Extract id
  respondent <- map(initial_dat, ~ select(.x, respondent))
  respondent <- map(respondent, ~ unlist(.x$respondent))
  respondent <- tibble(respondent = respondent[[1]])

  # Select the dv column
  initial_tmp <- map(initial_dat, ~ select(.x, dv))

  # Turn data frame into a numeric vector
  initial_tmp <- map(initial_tmp, ~ unlist(.x$dv))

  # Select the dv column
  replication_tmp <- map(replication_dat, ~ select(.x, dv))

  # Turn data frame into numeric vector
  replication_tmp <- map(replication_tmp, ~ unlist(.x$dv))

  # Subtract initial response from replication response
  dev_dat <- map2(replication_tmp, initial_tmp, ~ .x - .y)

  # Convert list to data frame
  dev_dat <- as_tibble(do.call("cbind", dev_dat))

  # loop over all columns and set names
  for (i in seq_along(unique(dat$profile))) {
    colnames(dev_dat)[i] <- paste0("profile_", i)
  }

  # Combine
  dev_dat <- cbind(respondent, dev_dat)

  # Return result
  return(dev_dat)
}


### Data Wide to Long

# This function takes a data set as an input and pivots it from wide to long,
# so that there is an ID column, a profile column, and a deviation column.
# This format is required to create a violin plot.
wide_to_long <- function(dat) {
  # Pivot the data frame from wide to long
  dat <- dat |>
    pivot_longer(!respondent, names_to = "profile", values_to = "deviation") |>
    mutate(profile = paste0("Profile ", str_extract(profile, "\\d+")))
  # Return result
  return(dat)
}


### Create Violin Plot

# This function requires a data set, the number of profiles and the
# height of the plot, and its name, as inputs and creates a violin plot.
violin_plot <- function(dat, num_profiles, plot_height, plot_name) {
  # Profile names as factor with ordered levels to preserve order
  dat$profile <- factor(dat$profile, levels = unique(dat$profile))
  # Custom text styling for axis labels
  t1 <- list(
    family = "Times New Roman",
    color = "black",
    face = "bold",
    size = 16
  )
  # Custom text styling for axis labels
  t2 <- list(
    family = "Times New Roman",
    color = "black",
    size = 20
  )
  # Create violin plot with plotly
  p <- plot_ly(dat,
    height = plot_height,
    y = ~deviation,
    color = ~profile,
    type = "violin",
    colors = viridis_pal(option = "C")(num_profiles),
    box = list(visible = T, line = list(color = "dimgrey")),
    meanline = list(visible = T, color = "black"),
    bandwith = 2
  ) |>
    layout(font = t1) |>
    layout(paper_bgcolor = "white") |>
    layout(plot_bgcolor = "transparent") |>
    layout(yaxis = list(
      title = list(text = "<b>Deviation Magnitude Distribution</b>", font = t2),
      gridcolor = "lightgrey",
      zerolinecolor = "grey"
    )) |>
    layout(xaxis = list(
      categoryarray = ~profile,
      categoryorder = "array"
    )) |>
    layout(xaxis = list(
      title = list(text = "<b>Profile Level</b>", font = t2),
      gridcolor = "#ffff", zerolinecolor = "#ffff"
    )) |>
    layout(showlegend = FALSE) |>
    config(displaylogo = FALSE, modeBarButtonsToRemove = c(
      "toggleSpikelines",
      "hoverClosestCartesian",
      "hoverCompareCartesian"
    )) |>
    config(toImageButtonOptions = list(
      format = "png",
      filename = plot_name,
      scale = 1
    ))
  # Return plot
  return(p)
}


## ICC effect plot

# This function creates an icc effect plot
icc_effect_plot <- function(dat) {
  # Create the plot
  plot <- ggplot(
    data = dat,
    aes(
      x = profile,
      y = ICC,
      ymin = icc_lower,
      ymax = icc_upper
    )
  ) +
    geom_pointrange() +
    geom_text(aes(label = ICC), nudge_x = 0.28) +
    labs(
      title = paste0("ICC Values -- Profiles 1-", length(dat$profile)),
      subtitle = "95% Confidence Interval As Vertical Line",
      x = NULL,
      y = "Intraclass Correlation Coefficients"
    ) +
    theme_minimal()

  # Return plot
  return(plot)
}

## Slope difference effect plot

# This function creates a slope difference effect plot
slope_effect_plot <- function(dat) {
  # Create the plot
  plot <- ggplot(data = dat, aes(x = iv, y = test_statistic)) +
    geom_point() +
    geom_text(aes(label = test_statistic), nudge_x = 0.25) +
    coord_flip() +
    geom_hline(yintercept = 0, size = 2) +
    labs(
      title = "Slope Difference Test Results: Statistically Significant at Zero or Higher",
      subtitle = "No Statistically Significant Difference for Test Statistic Below Zero",
      y = "Test Statistic",
      x = "Independent Variables"
    ) +
    theme_minimal()

  # Return plot
  return(plot)
}
