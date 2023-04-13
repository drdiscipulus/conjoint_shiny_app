# Try to get factorial design when button is pressed
get_n_level_factorial <- reactive({
  # Get separators
  separator <- unlist(str_match_all(input$attributes_n, "[:punct:]"))

  # Get number of attributes
  attributes <- unlist(strsplit(input$attributes_n, ","))

  # If attributes are numeric
  attributes_numeric <- unlist(str_match_all(attributes, "[:digit:]"))

  # Throw an error if separators are not all commas
  if (length(separator) != sum(str_count(separator, ","))) {
    shinyalert("Error!", "Commas must be used as separators", type = "error")
    res <- NULL
    # Throw error if not all attributes are numeric
  } else if (length(attributes) != length(attributes_numeric)) {
    shinyalert("Error!", "Not all attributes are numeric", type = "error")
    res <- NULL
    # Throw errors if there are less than 2 or more than 7 attributes
  } else if (length(attributes) < 2) {
    shinyalert("Error!", "No less than 2 attributes", type = "error")
    res <- NULL
  } else if (length(attributes) > 7) {
    shinyalert("Error!", "No more than 7 attributes", type = "error")
    res <- NULL
    # No more than 4 levels and less than 2 levels allowed
  } else if (max(attributes) > 4) {
    shinyalert("Error!", "No more than 4 levels", type = "error")
    res <- NULL
  } else if (min(attributes) < 2) {
    shinyalert("Error!", "No less than 2 levels", type = "error")
    res <- NULL
  } else if (input$design_n == "Fractional") {
    # Try to obtain result
    res <- try(get_n_level_fractional(
      attributes = input$attributes_n,
      effects = input$effects_n
    ))

    if (inherits(res, "try-error")) {
      shinyalert("Error!", "No Solution could be found", type = "error")
      res <- NULL
    } else {
      res
    }
  } else if (input$design_n == "Full") {
    # Try to obtain result
    res <- try(get_n_level_full(
      attributes = input$attributes_n
    ))

    if (inherits(res, "try-error")) {
      shinyalert("Error!", "No Solution could be found", type = "error")
      res <- NULL
    } else {
      res
    }
  }
}) |> bindEvent(input$generate_n)


# render table for n-level fractional
output$n_level_table <- renderReactable({
  # Proceed if not null
  req(get_n_level_factorial())

  custom_width <- ncol(get_n_level_factorial()) * 80 + 2
  
  reactable(get_n_level_factorial(),
    highlight = TRUE,
    striped = TRUE,
    bordered = TRUE,
    compact = TRUE,
    defaultPageSize = 16,
    # Table theming
    theme = reactableTheme(
      highlightColor = "#bdbdbd",
      stripedColor = "#E0E0E0",
      backgroundColor = "#F0F0F0",
      borderColor = "#bdbdbd"
    ),
    defaultColDef = colDef(
      align = "center",
      maxWidth = 80,
    ),
    style = list(maxWidth = custom_width)
  )
}) |> bindEvent(input$generate_n)


# Render the ui
output$n_level <- renderUI({
  
  req(get_n_level_factorial())
  
  wellPanel(
    style = "padding: 0.7rem; background: #F0F0F0",
    # Define top row
    reactableOutput("n_level_table") %>% withSpinner(type = 6, color = "#009260")
  )
}) |> bindEvent(input$generate_n)