# about panel that explains everything
tabPanel(
  title = "Info",
  fluidRow(
    # plain text can be added in simple quotation marks, more refined option require html tags
    tags$div(
      tags$h4("General information"),
      tags$ul(
        tags$li("The purpose of this R Shiny application is to assist researchers in designing conjoint studies and evaluating the reliability of conjoint studies"),
        tags$ol(
          tags$li("Full or fractional factorial designs are critical to how many profiles can or must be shown in a conjoint study.
                  It is not always easy to know how many profiles you for a specific model, and where to find an appropriate factorial design.,
                  e.g., the Hahn & Shapiro (1966) ortho plans are frequently cited in the Entrepreneurship field.
                  However, there are more accessible and recent options available, and this application bundles some of these"),
          tags$li("We propse an analytical workflow to
                help researchers better probe threats to response consistency and
                to evaluate — and communicate — confidence in statistical models
                using conjoint data. This application makes our workflow accessible and easy to use"),
        ),
        tags$li("Please carefully read the instructions for using both parts of this application before use"),
        tags$li("Disclaimer: Use the app at your own risk"),
      )
    ),
    tags$h6("R Shiny App written by: Jens Schüler")
  )
)
