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
  req(get_two_level_factorial()$table)

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
output$two_level_plot <- renderPlot({
  # Proceed if not null
  req(get_two_level_factorial()$table)

  # Get correlation data
  dat <- get_cor_table(data = get_two_level_factorial()$design)

  # Check if data exists
  if (is.null(dat)) {
    
    # Create a text plot
    tmp <- tibble(x = c(1,2,3), y = c(1,2,3))
    
    ggplot(tmp, aes(x = x, y = y)) +
      xlim(1,3) +
      ylim(1,3) +
      annotate("text", x = 2, y = 2.9, size = 8, family = "Arial", label = "No correlation plot can be created for the specified design:\na) The design has a resolution of V or larger\nb) No design exists") +
      theme_void()

    # If there is data, create a heat map
  } else {
    ggplot(dat, aes(x = as.factor(rowname), y = as.factor(variables), fill = correlation)) +
      geom_tile(color = "white", lwd = 1, linetype = 1) +
      geom_text(family = "Arial", size = 5, aes(label = round(correlation, 1), color = after_scale(prismatic::best_contrast(fill, c("white", "black"))))) +
      scale_fill_viridis(option = "C", discrete = FALSE, direction = -1, name = "Correlation") +
      labs(x = "Attributes", y = "Attributes") +
      theme_bw() +
      theme(
        axis.title = element_text(color = "black", size = 18, family = "Arial", face = "bold"),
        axis.text = element_text(color = "black", size = 16, family = "Arial", face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.title = element_text(color = "black", size = 16, family = "Arial", face = "bold"),
        legend.text = element_text(color = "black", size = 16, family = "Arial", face = "bold")
      ) +
      theme(strip.text = element_text(family = "Arial", face = "bold", size = 16))
  }
}) |> bindEvent(input$generate_2)


# Render text
output$two_level_line_1 <- renderText({
  req(get_two_level_factorial()$table)
  "The second number behind each attribute denotes the levels - only relevant for attributes with more than two levels"
}) |> bindEvent(input$generate_2)


output$two_level_line_2 <- renderText({
  req(get_two_level_factorial()$table)
  "If the plot is not wide enough, resize your browser window and click the generate button again"
}) |> bindEvent(input$generate_2)


# Render the ui
output$two_level <- renderUI({
  req(get_two_level_factorial()$table)

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
        textOutput("two_level_line_1"),
        textOutput("two_level_line_2"),
        plotOutput("two_level_plot", height = 900) %>% withSpinner(type = 6, color = "#009260")
      )
    )
  )
}) |> bindEvent(input$generate_2)
