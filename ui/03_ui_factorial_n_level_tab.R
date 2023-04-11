# Tab 2 is a navbar menu showing all analysis results
tabPanel(
  # Set the title of the Panel
  title = "N-Level",
  # Layout of the first element: sidebar layout
  sidebarLayout(
    # Define the input panel
    sidebarPanel(
      # Styling and positioning
      width = 2,
      style = "height: 900px; background: #F0F0F0; margin-left: 0px; margin-right: -10px; margin-top:-10px",
      h4("Define", style = "margin-top: 0rem"),
      "No more than 6 attributes and 4 levels are supported",
      textInput("attributes_n", "Attributes:", "2,2,3,3"),
      selectInput("design_n", label = "Design", choices = list("Full", "Fractional"), selected = "Fractional"),
      selectInput("effects_n",
        label = "Effects",
        choices = list("Main Effects" = "main_effects", "Two-Way" = "two-way"),
        selected = "main_effects"
      ),
      actionButton("generate_n", "Generate", class = "btn-primary", width = "100%", icon = icon("cog")),
      br(),
    ),
    # Define the output panel
    mainPanel(
      # Positioning and styling
      width = 10, offset = 0, style = "padding-left:5px; padding-right:5px; margin-top:-10px",
      wellPanel(
        style = "padding: 0.7rem; height: 900px; background: #F0F0F0",
        # Define top row
        reactableOutput("n_level_table") %>% withSpinner(type = 6, color = "#009260")
      )
    )
  )
)
