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


# Custom height and width
# Try to get factorial design when button is pressed
get_two_level_size <- reactive({
  
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

  custom_width <- ncol(get_two_level_factorial()$table) * 80 + 2
  
  # Create reactable
  reactable(get_two_level_factorial()$table,
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
}) |> bindEvent(input$generate_2)


# Render correlation plot for 2-level fractional
output$two_level_cor_table <- renderPlot({
  
  # Proceed if not null
  req(get_two_level_factorial())
  
  # Create plot
  ggplot(get_two_level_factorial()$plot, aes(x = as.factor(rowname), y = as.factor(variables), fill = correlation)) +
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
  
}) |> bindEvent(input$generate_2)


# Render the ui
output$two_level <- renderUI({
  
  req(get_two_level_factorial())
  
  wellPanel(
    style = "padding: 0.7rem; background: #FFFFFF",
    # Define tabs
    tabsetPanel(
      # First tab
      tabPanel(
        # Show factorial design
        "Factorial Design",
        reactableOutput("two_level_table") %>% withSpinner(type = 6, color = "#009260")
      ),
      # Second panel
      tabPanel(
        # Show attribute correlations
        "Correlations",
        plotOutput("two_level_cor_table", height = 900) %>% withSpinner(type = 6, color = "#009260")
      )
    )
  )
}) |> bindEvent(input$generate_2)