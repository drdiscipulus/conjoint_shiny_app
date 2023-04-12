# Tab 2 is a navbar menu showing all analysis results
tabPanel(
  # Set the title of the Panel
  title = "2-Level",
  # Layout of the first element: sidebar layout
  sidebarLayout(
    # Define the input panel
    sidebarPanel(
      # Styling and positioning
      width = 2,
      style = "height: 900px; background: #F0F0F0; margin-left: 0px; margin-right: -10px; margin-top:-10px",
      h4("Define", style = "margin-top: 0rem"),
      sliderInput("attributes_2", "Number of Attributes:",
        min = 2, max = 10, value = 5
      ),
      selectInput("design_2",
        label = "Design",
        choices = list("Full", "Fractional"),
        selected = "Fractional"
      ),
      selectInput("effects_2",
        label = "Effects",
        choices = list("Main Effects" = "main_effects", "Two-Way" = "two-way"),
#        choices = list("Main Effects" = "main_effects", "Two-Way" = "two-way", "Three-Way" = "three-way"),
        selected = "main_effects"
      ),
      actionButton("generate_2", "Generate", class = "btn-primary", width = "100%", icon = icon("cog")),
      br(),
    ),
    # Define the output panel
    mainPanel(
      # Positioning and styling
      width = 10, offset = 0, style = "padding-left:5px; padding-right:5px; margin-top:-10px",
      wellPanel(
        style = "padding: 0.7rem; height: 900px; background: #F0F0F0",
        # Define top row
        reactableOutput("two_level_table") %>% withSpinner(type = 6, color = "#009260")
      )
    )
  )
)
