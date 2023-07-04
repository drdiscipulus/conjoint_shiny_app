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

  custom_width <- ncol(get_n_level_factorial()$table) * 80 + 2
  
  reactable(get_n_level_factorial()$table,
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


# Render correlation plot for 2-level fractional
output$n_level_cor_table <- renderPlot({
  
  # Proceed if not null
  req(get_n_level_factorial())
  
  # Create plot
  ggplot(get_n_level_factorial()$plot, aes(x = as.factor(rowname), y = as.factor(variables), fill = correlation)) +
    geom_tile(color = "white", lwd = 1, linetype = 1) +
    geom_text(family = "Arial", size = 5, aes(label = round(correlation,1), color = after_scale(prismatic::best_contrast(fill, c("white", "black"))))) +
    scale_fill_viridis(option = "C", discrete = FALSE, direction = -1, name = "Correlation") +
    labs(x = "Attributes", y = "Attributes") +
    theme_bw() +
    theme(
      axis.title = element_text(color = "black", size = 16, family = "Arial", face = "bold"),
      axis.text = element_text(color = "black", size = 16, family = "Arial", face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.title = element_text(color = "black", size = 16, family = "Arial", face = "bold"),
      legend.text = element_text(color = "black", size = 16, family = "Arial", face = "bold")
    ) +
    theme(strip.text = element_text(family = "Arial", face = "bold", size = 16))
  
}) |> bindEvent(input$generate_n)


# Render the ui
output$n_level <- renderUI({
  
  req(get_n_level_factorial())
  
  wellPanel(
    style = "padding: 0.7rem; background: #FFFFFF",
    # Define tabs
    tabsetPanel(
      # First tab
      tabPanel(
        # Show factorial design
        "Factorial Design",
        reactableOutput("n_level_table") %>% withSpinner(type = 6, color = "#009260")
      ),
      # Second panel
      tabPanel(
        # Show attribute correlations
        "Correlations",
        plotOutput("n_level_cor_table", height = 900) %>% withSpinner(type = 6, color = "#009260")
      )
    )
  )
}) |> bindEvent(input$generate_n)