# Set reactive values to handle input data, check status, and compute status
# dat: makes the read dataset available and editable between functions
# check and compute: are both used as triggers/blocks
rv1 <- reactiveValues(generate_2 = NULL, dat_2 = NULL)

# Checks when the generate button is pressed
observeEvent(input$generate_2, {
  # Set flag
  rv1$generate_2 <- "go"

  if (input$design_2 == "Fractional") {
    # Try to obtain result
    res <- try(get_two_level_fractional(
      attributes = input$attributes_2,
      effects = input$effects_2
    ))

    if (inherits(res, "try-error")) {
      shinyalert("Error!", "No Solution could be found", type = "error")
      rv1$dat_2 <- NULL
    } else {
      rv1$dat_2 <- res
    }
  } else if (input$design_2 == "Full") {
    # Try to obtain result
    res <- try(get_two_level_full(
      attributes = input$attributes_2
    ))

    if (inherits(res, "try-error")) {
      shinyalert("Error!", "No Solution could be found", type = "error")
      rv1$dat_2 <- NULL
    } else {
      rv1$dat_2 <- res
    }
  }
})


# render table for 2-level fractional
output$two_level_table <- renderReactable({
  # Proceed if not null
  req(rv1$generate_2, rv1$dat_2)

  # Create reactable
  reactable(rv1$dat_2,
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
