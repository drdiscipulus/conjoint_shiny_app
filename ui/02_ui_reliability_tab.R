# Tab 2 is a navbar menu showing all analysis results
tabPanel(
  # Set the title of the Panel
  title = "Test-Retest Reliability",
  # Layout of the first element: sidebar layout
  sidebarLayout(
    # Define the input panel
    sidebarPanel(
      # Styling and positioning
      width = 2,
      style = "background: #F0F0F0; margin-left: 0px; margin-right: -10px; margin-top:-10px",
      h5("1. Upload", style = "margin-top: 0rem"),
      # Upload .csv file handling
      fileInput("upload_data", ".csv or .xlsx",
        accept = c(
          "text/csv",
          "text/comma-separated-values,text/plain",
          ".csv", ".xlsx"
        ), width = "100%", multiple = FALSE
      ),
      hr(),
      # Check data handling
      h5("2. Check", style = "margin-top: 0rem"),
      actionButton("check_data", "", class = "btn-primary", width = "100%", icon = icon("search")),
      br(),
      hr(),
      # Start analysis handling
      h5("3. Workflow", style = "margin-top: 0rem"),
      actionButton("compute", "", class = "btn-primary", width = "100%", icon = icon("play")),
      br(),
      hr(),
      h5("4. Reset", style = "margin-top: 0rem"),
      actionButton("reset", "", class = "btn-danger", width = "100%", icon = icon("trash")),
      br(),
      hr(),
      h5("Inspect", style = "margin-top: 0rem"),
      actionButton("show_table", "Table", class = "btn-info", width = "100%", icon = icon("list-alt")),
      br(),
      br(),
      actionButton("show_class", "Types", class = "btn-info", width = "100%", icon = icon("tags")),
      br(),
      hr(),
      # Download demo data
      h5("Demo Data", style = "margin-top: 0rem"),
      downloadButton("download_csv", ".csv"),
      br(),
      br(),
      downloadButton("download_xlsx", ".xlsx", ),
      br(),
    ),
    # Define the output panel
    mainPanel(
      # Positioning and styling
      width = 10,
      # Define top row
      fluidRow(
        # Styling
        style = "margin-right:-5px",
        # Define as single column
        column(
          # Styling
          width = 12, offset = 0, style = "padding-left:5px; padding-right:5px; margin-top:-10px",
          uiOutput("top_row")
        )
      ),
      # Empty line between top and bottom row
      br(),
      # Define bottom row
      fluidRow(
        # Styling
        style = "margin-right:-5px; margin-top:-15px",
        # Define as single column
        column(
          # Styling
          width = 12, offset = 0, style = "padding-left:5px; padding-right:5px;",
          uiOutput("bottom_row")
        )
      )
    )
  )
)
