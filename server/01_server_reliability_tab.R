# Set reactive values to handle input data, check status, and compute status
# dat: makes the read dataset available and editable between functions
# check and compute: are both used as triggers/blocks
rv <- reactiveValues(dat = NULL, check = NULL, compute = NULL, reset = FALSE)


# Download csv demo data set
output$download_csv <- downloadHandler(
  filename = function() {
    # Set file name
    paste0("demo_data.csv")
  },
  content = function(file) {
    # Read file from disk and write it to user
    write.csv(read.csv("demo_data.csv"), row.names = FALSE, file)
  }
)


# Download xlsx demo data set
output$download_xlsx <- downloadHandler(
  filename = function() {
    # Set file name
    paste0("demo_data.xlsx")
  },
  content = function(file) {
    # Read file from disk and write it to user
    openxlsx::write.xlsx(openxlsx::read.xlsx("demo_data.xlsx"), file)
  }
)


# Upload a .csv or .xlsx file
# This function tries to read a supplied .csv or .xlsx file
# Throws a warning or error if something is wrong with the file
observeEvent(input$upload_data, {
  # Set check button to null when new data is uploaded
  rv$check <- NULL
  # Set compute button to null when new data is uploaded
  rv$compute <- NULL
  # Set data to null when new data is uploaded
  rv$dat <- NULL

  # If an uploaded file exists
  if (!is.null(input$upload_data)) {
    rv$dat <- file_upload(input$upload_data)
  }
})


# Create a modal popup dialog when the table info button is pressed
observeEvent(input$show_table, {
  # Show a message if no data has been uploaded but the table button is pressed
  if (is.null(input$upload_data)) {
    shinyalert("Error!", "Please upload a file first", type = "error")

    # If the show table button is pressed, test if path of input file exists
  } else if (!file.exists(input$upload_data$datapath)) {
    shinyalert("Error!", "Please upload a file first", type = "error")
    # Test if data exists
  } else if (is.null(rv$dat)) {
    shinyalert("Error!", "The upload cannot be displayed as a table", type = "error")
    # If data exists
  } else {
    # Define the modal
    showModal(modalDialog(
      title = "Data Set", size = "xl",
      "You can use the empty boxes to search columns for values",
      # Render that data as a reactable
      renderReactable(reactable(rv$dat,
        highlight = TRUE,
        striped = TRUE,
        bordered = TRUE,
        compact = TRUE,
        defaultPageSize = 10,
        filterable = TRUE,
        # Table theming
        theme = reactableTheme(
          highlightColor = "#bdbdbd",
          stripedColor = "#E0E0E0",
          backgroundColor = "#F0F0F0"
        )
      ))
    ))
  }
})


# Create a modal popup dialog when the class info button is pressed
observeEvent(input$show_class, {
  # Show a message if no data has been uploaded but the class button is pressed
  if (is.null(input$upload_data)) {
    shinyalert("Error!", "Please upload a file first", type = "error")

    # If the class button is pressed, test if path of input file exists
  } else if (!file.exists(input$upload_data$datapath)) {
    shinyalert("Error!", "Please upload a file first", type = "error")
    # If no data exists
  } else if (is.null(rv$dat)) {
    shinyalert("Error!", "The upload cannot be displayed", type = "error")
    # If data exists
  } else {
    # Define modal
    showModal(modalDialog(
      title = "Data Classes and Types", size = "xl",
      # Render that data as a reactable
      renderReactable(reactable(class_type_overview(rv$dat),
        highlight = TRUE,
        striped = TRUE,
        bordered = TRUE,
        compact = TRUE,
        defaultPageSize = 10,
        # Table theming
        theme = reactableTheme(
          highlightColor = "#bdbdbd",
          stripedColor = "#E0E0E0",
          backgroundColor = "#F0F0F0"
        )
      ))
    ))
  }
})


# This functions evaluates the uploaded data
# Just a few checks to verify that the data meets requirements
# However, this is very basic and no safeguard against every possible mishap
observeEvent(input$check_data, {
  # Show a message if no data has been uploaded but the check button is pressed
  if (is.null(input$upload_data)) {
    shinyalert("Error!", "Please upload a file first", type = "error")

    # If the check button is pressed, test if path of input file exists
  } else if (!file.exists(input$upload_data$datapath)) {
    shinyalert("Error!", "Please upload a file first", type = "error")
  } else if (is.null(rv$dat)) {
    shinyalert("Error!", "No file could be read", type = "error")
  }

  # Set rv$dat to null if there was an error or warning while reading the file
  if (inherits(rv$dat, "try-error")) {
    shinyalert("Error!", "No file could be read", type = "error")
    rv$dat <- NULL
  }

  # Only proceed if dat is not null
  req(rv$dat)

  # Try to select all required columns
  res <- column_checker(rv$dat)

  # Check if it includes an error or not
  if (inherits(res, "try-error")) {
    shinyalert("Error!", "Required variables are missing", type = "error")
    rv$dat <- NULL
  } else {
    rv$dat <- res
  }
  #  Only proceed if dat is not null
  req(rv$dat)

  # Get number of attributes
  att_num <- attribute_checker(rv$dat)

  # Check if it includes an error or not
  if (inherits(res, "try-error")) {
    shinyalert("Error!", "Number of attributes can't be determined", type = "error")
    rv$dat <- NULL
  }

  # Only proceed if dat is not null
  req(rv$dat)

  # Check if there are two or more attributes
  if (att_num < 2) {
    shinyalert("Error!", "Less than two attributes", type = "error")
    rv$dat <- NULL
  }

  # Only proceed if dat is not null
  req(rv$dat)

  # Try to coerce data to numeric where required
  res <- class_checker(rv$dat)

  # Check if it includes an error or not
  if (inherits(res, "try-error")) {
    shinyalert("Error!", "Not all required variables are numeric or can't be coerced into numeric", type = "error")
    rv$dat <- NULL
  } else {
    rv$dat <- res
  }

  # Only proceed if dat is not null
  req(rv$dat)

  # Check if round only contains 1 and 2
  round_test <- try(round_checker(rv$dat), silent = TRUE)

  # Check if it includes an error or not
  if (inherits(round_test, "try-error")) {
    shinyalert("Error!", 'Variable "round" cannot be checked', type = "error")
    rv$dat <- NULL
  } else if (isFALSE(round_test)) {
    shinyalert("Error!", 'Variable "round" is not correctly specified', type = "error")
    rv$dat <- NULL
  }

  # Only proceed if dat is not null
  req(rv$dat)

  # In case of partial replications, drop non-replicated profiles
  initial_dat <- rv$dat |>
    filter(round == 1)

  # Filter for round 2
  replication_dat <- rv$dat |>
    filter(round == 2)

  # # Get all unique round 1 profiles
  initial_profiles <- unique(initial_dat$profile)

  # Get all unique round 2 profiles
  replication_profiles <- unique(replication_dat$profile)

  # Check if both profile vectors are not identical
  if (!identical(initial_profiles, replication_profiles)) {
    # If they are not identical, remove profiles from first round data
    rv$dat <- rv$dat |>
      filter(profile %in% replication_profiles)

    # The data should be fine now, thus set status to okay
    rv$check <- "okay"
    # Notify user that things are probably okay and that profiles were dropped
    shinyalert("Success!", "The data seems to be okay but non-replicated profiles were removed", type = "success")
    #
    # If the profiles are identical/full replication...
  } else {
    # Set check status to okay
    rv$check <- "okay"

    # Notify the user that things are probably okay
    shinyalert("Success!", "The data seems to be okay", type = "success")
  }
})


# Observe if the compute button is pressed
observeEvent(input$compute, {
  # Check if the check went well
  if (is.null(rv$check)) {
    # Show a message if no data has been uploaded but the check button is pressed
    if (is.null(input$upload_data)) {
      shinyalert("Error!", "Please upload a file first", type = "error")

      # If the check button is pressed, test if path of input file exists
    } else if (!file.exists(input$upload_data$datapath)) {
      shinyalert("Error!", "Please upload a file first", type = "error")
    } else if (is.null(rv$dat)) {
      shinyalert("Error!", "No file could be read", type = "error")
    } else {
      shinyalert("Error!", "You haven't checked your data or it failed the check", type = "error")
    }
  } else {
    rv$compute <- "go"
  }
})


# Function to get the iccs per profile as a table
icc_table <- reactive({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Call icc function
    res <- rel_icc(rv$dat)

    # Return icc table
    return(res)
  }
}) |> bindEvent(input$compute)


# Create a table with test-retest reliabilities per profile
rel_table <- reactive({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Call correlation function
    cor_res <- rel_cor(rv$dat)

    # Get results from icc_table
    icc_res <- icc_table()

    # Create a data frame with correlation data
    cor_res <- tibble(profile = unique(rv$dat$profile), r = round(cor_res, 2))

    # Join correation and icc data
    res <- left_join(cor_res, icc_res, by = "profile")

    # Return reliability table
    return(res)
  }
}) |> bindEvent(input$compute)


# Create a string with mean reliabilities to be shown under the reliability table
rel_string <- reactive({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Get the reliability table and compute column means
    cor_mean <- round(mean(rel_table()$r), 2)
    icc_mean <- round(mean(rel_table()$ICC), 2)

    # Set up the mean string
    res_text <- paste0("The mean test-retest reliability is: r = ", cor_mean, "; ICC(3,k) = ", icc_mean)

    # Return the mean string
    return(res_text)
  }
}) |> bindEvent(input$compute)


# Create footer note for reliability table
output$reliability_note <- renderText({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Set up the mean string
    res_text <- paste0("Note: Profiles = Respective profile number;
                       r = Pearson's r;
                       ICC(3k) = Intraclass correlation coefficient 3k;
                       ICC(3k) lb = 95% CI lower bound of the ICC(3k);
                       ICC(3k) ub = 95% CI upper bound of the ICC(3k).")

    # Return the mean string
    return(res_text)
  }
}) |> bindEvent(input$compute)


# Render the reliability table with reactable
output$reliability_table <- renderReactable({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    
    # Create reactable
    reactable(rel_table(),
      highlight = TRUE,
      striped = TRUE,
      bordered = TRUE,
      compact = TRUE,
      # Table theming
      theme = reactableTheme(
        highlightColor = "#bdbdbd",
        stripedColor = "#E0E0E0",
        backgroundColor = "#F0F0F0",
        borderColor = "#bdbdbd"
      ),
      # Edit columns
      columns = list(
        profile = colDef(name = "Profiles", maxWidth = 80, align = "center"),
        r = colDef(minWidth = 60),
        ICC = colDef(name = "ICC(3k)", maxWidth = 80),
        icc_upper = colDef(name = "ICC(3k) ub", maxWidth = 110),
        icc_lower = colDef(name = "ICC(3k) lb", maxWidth = 110)
      ),
      style = list(maxWidth = 442)
    )
  }
}) |> bindEvent(input$compute)


# Render the mean reliabilities string as text output
output$reliability_mean <- renderText({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Output string as text
    rel_string()
  }
}) |> bindEvent(input$compute)


# Call the function to compute slope difference tests
slope_difference_res <- reactive({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Get slope differences
    res <- slope_difference(rv$dat)
  }
}) |> bindEvent(input$compute)


# Render slope difference table as a reactable
output$slope_diff_table <- renderReactable({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    
    # Setup the reactable
    reactable(slope_difference_res(),
      highlight = TRUE,
      striped = TRUE,
      bordered = TRUE,
      compact = TRUE,
      # table theming
      theme = reactableTheme(
        highlightColor = "#bdbdbd",
        stripedColor = "#E0E0E0",
        backgroundColor = "#F0F0F0",
        borderColor = "#bdbdbd"
      ),
      # Change some columns
      columns = list(
        iv = colDef(name = "IV", maxWidth = 50),
        beta_i = colDef(name = "Beta 1", maxWidth = 65),
        se_i = colDef(name = "SE 1", maxWidth = 65),
        p_i = colDef(name = "p-val 1", maxWidth = 70),
        beta_r = colDef(name = "Beta 2", maxWidth = 65),
        se_r = colDef(name = "SE 2", maxWidth = 65),
        p_r = colDef(name = "p-val 2", maxWidth = 70),
        beta_diff = colDef(name = "Beta Diff", maxWidth = 80),
        joint_se = colDef(name = "Joint SE", maxWidth = 80),
        test_statistic = colDef(name = "Test Statistic", maxWidth = 120),
        stat_diff = colDef(name = "Difference", maxWidth = 95)
      ),
      style = list(maxWidth = 827)
    )
  }
}) |> bindEvent(input$compute)


# Create footer note for reliability table
output$slope_note <- renderText({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Set up the mean string
    res_text <- paste0("Note: 1 designates the first round of responses and 2 the replication round;
                       IV = Independent variables, these are the attributes;
                       Beta = Unstandardized regression coefficient;
                       SE = Standard error;
                       p-val = Exact p-value rounded to the 4th decimal;
                       Beta Diff = Beta difference between round 1 and 2;
                       Joint SE = Standard error of the difference;
                       Test Statistic = Corresponding test statistic;
                       Difference = Whether the beta difference is significant (Yes) or not (No).")

    # Return the mean string
    return(res_text)
  }
}) |> bindEvent(input$compute)


# Call function to compute a pooled regression model
pooled_reg_data <- reactive({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Compute pooled regression model
    res <- pooled_regression(rv$dat)
  }
}) |> bindEvent(input$compute)


# Render the pooled regression table as a reactable
output$pooled_reg_table <- renderReactable({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    
    custom_width <- ncol(pooled_reg_data()$dat) * 100 + 2
    
    # Set up the reactable
    reactable(pooled_reg_data()$dat,
      highlight = TRUE,
      striped = TRUE,
      bordered = TRUE,
      compact = TRUE,
      # table theming
      theme = reactableTheme(
        highlightColor = "#bdbdbd",
        stripedColor = "#E0E0E0",
        backgroundColor = "#F0F0F0",
        borderColor = "#bdbdbd"
      ),
      defaultColDef = colDef(
        align = "center",
        maxWidth = 100,
      ),
      style = list(maxWidth = custom_width)
    )
  }
}) |> bindEvent(input$compute)


# Render the model fit of the pooled regression model as a text output
output$regression_fit <- renderText({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Output model fit as text
    pooled_reg_data()$fit
  }
}) |> bindEvent(input$compute)


# Create footer note for reliability table
output$regression_note <- renderText({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Set up the mean string
    res_text <- paste0("Note: Coefficient = Variable names/the attributes;
                       Beta = Unstandardized regression coefficient;
                       SE = Two-way cluster robust standard errors;
                       t-ratio = Corresponding test statistic;
                       p-val = Exact p-value rounded to the 4th decimal.")

    # Return the mean string
    return(res_text)
  }
}) |> bindEvent(input$compute)


# Create a violin plot with plotly and render and output it
output$violin <- renderPlotly({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Compute response deviations between round 1 and 2
    df_dev <- compute_deviation(dat = rv$dat)

    # Pivot the deviation data from wide to long
    df_dev <- wide_to_long(dat = df_dev)

    # Create the violin plot
    violin_plot(
      dat = df_dev,
      num_profiles = length(unique(rv$dat$profile)),
      plot_name = "violin_plot"
    )
  }
}) |> bindEvent(input$compute)


# Create an icc summary plot and render it as a plotly plot
output$icc_plot <- renderPlotly({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Get icc table from function
    icc_res <- icc_table()

    # Create icc effect plot with that data
    icc_res <- icc_effect_plot(icc_res)

    # Convert ggplot plot to plotly
    ggplotly(icc_res) |>
      layout(showlegend = FALSE) |>
      config(displaylogo = FALSE, modeBarButtonsToRemove = c(
        "toggleSpikelines",
        "hoverClosestCartesian",
        "hoverCompareCartesian"
      )) %>%
      config(toImageButtonOptions = list(
        format = "png",
        filename = "icc_summary_plot",
        scale = 1
      ))
  }
}) |> bindEvent(input$compute)


# Create a slope difference plot and render it as a potly plot
output$slope_plot <- renderPlotly({
  # Check data availability and status
  req(rv$dat, rv$check, rv$compute)

  # If compute is go
  if (rv$compute == "go") {
    # Get slope difference table from function
    slope_res <- slope_difference_res()

    # Create slope difference plot with that data
    slope_res <- slope_effect_plot(slope_res)

    # Convert ggplot plot to plotly
    ggplotly(slope_res) |>
      layout(showlegend = FALSE) |>
      config(displaylogo = FALSE, modeBarButtonsToRemove = c(
        "toggleSpikelines",
        "hoverClosestCartesian",
        "hoverCompareCartesian"
      )) %>%
      config(toImageButtonOptions = list(
        format = "png",
        filename = "icc_summary_plot",
        scale = 1
      ))
  }
}) |> bindEvent(input$compute)


# Reset status and delete uploaded data
observeEvent(input$reset, {
  # If the button is pressed but no input exists
  if (is.null(input$upload_data)) {
    shinyalert("Error!", "No data has been uploaded yet", type = "error")

    # If the button is pressed, input is true but path does not exist
  } else if (!file.exists(input$upload_data$datapath)) {
    shinyalert("Error!", "No data has been uploaded yet", type = "error")

    # If data exists, ask user if it should be deleted
  } else {
    shinyalert(
      title = "Reset App",
      text = "Reset states and delete uploaded data?",
      type = "warning",
      closeOnEsc = TRUE,
      showConfirmButton = TRUE,
      showCancelButton = TRUE,
      confirmButtonText = "Delete",
      confirmButtonCol = "#df382c",
      cancelButtonText = "Cancel",
      callbackR = function(x) {
        rv$reset <- x
      }
    )
  }
})


# Delete uploaded data and reset states
observe({
  # If deletion alert is true
  if (isTRUE(rv$reset)) {
    # Check if input path exists, delete it if this is the case
    if (file.exists(input$upload_data$datapath)) {
      file.remove(input$upload_data$datapath)
    }

    # Reset upload button
    shinyjs::reset("upload_data")
    # Reset states
    rv$dat <- NULL
    rv$check <- NULL
    rv$compute <- NULL
    rv$reset <- FALSE
  }
})


# Render top row ui
output$top_row <- renderUI({
  
  wellPanel(
    style = "padding: 0.7rem; background: #FFFFFF",
    # Define tabs
    tabsetPanel(
      # First tab
      tabPanel(
        # Show reliabilities
        "Reliabilities",
        reactableOutput("reliability_table") %>% withSpinner(type = 6, color = "#009260"),
        textOutput("reliability_mean"),
        textOutput("reliability_note")
      ),
      # Second panel
      tabPanel(
        # Show slope difference tests
        "Slope Difference",
        reactableOutput("slope_diff_table") %>% withSpinner(type = 6, color = "#009260"),
        textOutput("slope_note")
      ),
      # Third panel
      tabPanel(
        # Show pooled regression results
        "Pooled Regression",
        reactableOutput("pooled_reg_table") %>% withSpinner(type = 6, color = "#009260"),
        textOutput("regression_fit"),
        textOutput("regression_note")
      )
    )
  )
})  |> bindEvent(input$compute)


# Render bottom row
output$bottom_row <- renderUI({
  
  wellPanel(
    style = "padding: 0.7rem; background: #FFFFFF",
    tabsetPanel(
      # First tab
      tabPanel(
        # Show violin plot
        "Violin Plot",
        plotlyOutput("violin") %>% withSpinner(type = 6, color = "#009260")
      ),
      # Second panel
      tabPanel(
        # Show icc summary plot
        "ICC Summary Plot",
        plotlyOutput("icc_plot") %>% withSpinner(type = 6, color = "#009260"),
      ),
      # Third panel
      tabPanel(
        # Show slope difference plot
        "Slope Difference Plot",
        plotlyOutput("slope_plot") %>% withSpinner(type = 6, color = "#009260"),
      )
    )
  )
})  |> bindEvent(input$compute)