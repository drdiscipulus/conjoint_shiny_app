# about panel that explains everything
tabPanel(
  title = "Info",
  fluidRow(
    # plain text can be added in simple quotation marks, more refined option require html tags
    tags$div(
      tags$h4("General information"),
      tags$ul(
        tags$li("The purpose of this R Shiny app is to assist researchers in designing conjoint studies and evaluating the reliability of conjoint studies"),
        tags$ol(
          tags$li("Full or fractional factorial designs are critical to how many profiles can or must be shown in a conjoint study.
                  It is not always easy to know how much profile you need for a main effects-only model or a model with a manipulated moderator and where to find a suitable factorial model,
                  e.g., in the entrepreneurship field, the ortho-plans of Hahn & Shapiro (1966) are often used.
                  However, there are more accessible and recent options available, and this app bundles these into a user interface"),
          tags$li("We propse an analytical workflow to
                help researchers better probe threats to response consistency and
                to evaluate — and communicate — confidence in statistical models
                using conjoint data. This app makes our workflow accessible and easy to use"),
        ),
        tags$li("Please read the instructions for using both parts of this app carefully before use"),
        tags$li("Disclaimer: Use the app at your own risk"),
      )
    ),
    tags$h6("R Shiny App written by: Jens Schüler")
  )
)
