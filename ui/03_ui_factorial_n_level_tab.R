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
      style = "background: #F0F0F0; margin-left: 0px; margin-right: -10px; margin-top:-10px",
      h4("Define", style = "margin-top: 0rem"),
      "No more than 7 attributes and 4 levels are supported",
      textInput("attributes_n", "Attributes:", "3,3,3"),
      selectInput("design_n", label = "Design", choices = list("Full", "Fractional"), selected = "Fractional"),
      selectInput("effects_n",
        label = "Resolution",
        choices = list("III" = "main_effects", "IV" = "two-way"),
        selected = "main_effects"
      ),
      actionButton("generate_n", "Generate", class = "btn-primary", width = "100%", icon = icon("cog")),
      br(),
    ),
    # Define the output panel
    mainPanel(
      # Positioning and styling
      width = 10, offset = 0, style = "padding-left:5px; padding-right:0px; margin-top:-10px",
      uiOutput("n_level")
      )
    )
  )
