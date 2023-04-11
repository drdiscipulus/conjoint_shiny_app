# Set reactive values to handle input data, check status, and compute status
# dat: makes the read dataset available and editable between functions
# check and compute: are both used as triggers/blocks
rv2 <- reactiveValues(generate_n = NULL, dat_n = NULL)


# Checks when the generate button is pressed
observeEvent(input$generate_n, {
  # Set flag
  rv2$generate_n <- "go"

  # get number of attributes
  attributes <- unlist(strsplit(input$attributes_n, ","))

  # Throw error if there are more than 6 attributes
  if (length(attributes) > 6) {
    shinyalert("Error!", "No more than 6 attributes", type = "error")

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
      rv2$dat_n <- NULL
    } else {
      rv2$dat_n <- res
    }
  } else if (input$design_n == "Full") {
    # Try to obtain result
    res <- try(get_n_level_full(
      attributes = input$attributes_n
    ))

    if (inherits(res, "try-error")) {
      shinyalert("Error!", "No Solution could be found", type = "error")
      rv2$dat_n <- NULL
    } else {
      rv2$dat_n <- res
    }
  }
})


# render table for n-level fractional
output$n_level_table <- renderReactable({
  # Proceed if not null
  req(rv2$generate_n, rv2$dat_n)

  reactable(rv2$dat_n,
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
