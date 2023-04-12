# Try to get factorial design when button is pressed
get_two_level_factorial <- reactive({
  
  if (input$design_2 == "Fractional") {
    # Try to obtain result
    res <- try(get_two_level_fractional(
      attributes = input$attributes_2,
      effects = input$effects_2
    ))
    
    if (inherits(res, "try-error")) {
      shinyalert("Error!", "No Solution could be found", type = "error")
      res <- NULL
    } else {
      res
    }
  } else if (input$design_2 == "Full") {
    # Try to obtain result
    res <- try(get_two_level_full(
      attributes = input$attributes_2
    ))
    
    if (inherits(res, "try-error")) {
      shinyalert("Error!", "No Solution could be found", type = "error")
      res <- NULL
    } else {
      res
    }
  }
  
}) |> bindEvent(input$generate_2)


# Render table for 2-level fractional
output$two_level_table <- renderReactable({
  
  # Proceed if not null
  req(get_two_level_factorial())

  # Create reactable
  reactable(get_two_level_factorial(),
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
}) |> bindEvent(input$generate_2)


# Render the ui
output$two_level <- renderUI({
  
  req(get_two_level_factorial())
  
  wellPanel(
    style = "padding: 0.7rem; background: #F0F0F0",
    # Define top row
    reactableOutput("two_level_table") %>% withSpinner(type = 6, color = "#009260")
  )
}) |> bindEvent(input$generate_2)