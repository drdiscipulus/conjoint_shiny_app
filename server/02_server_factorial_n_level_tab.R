# Try to get factorial design when button is pressed
get_n_level_factorial <- reactive({
  
  # get number of attributes
  attributes <- unlist(strsplit(input$attributes_n, ","))
  
  # Throw error if there are more than 6 attributes
  if (length(attributes) > 7) {
    shinyalert("Error!", "No more than 7 attributes", type = "error")
    
    # No more than 4 levels allowed
  } else if (max(attributes) > 4) {
    shinyalert("Error!", "No more than 4 levels", type = "error")
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
      backgroundColor = "#F0F0F0"
    ),
    defaultColDef = colDef(
      align = "center",
      maxWidth = 80,
    )
  )
  # Create reactable
}) |> bindEvent(input$generate_n)
