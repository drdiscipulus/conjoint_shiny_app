# about panel that explains everything
tabPanel(
  title = "Info",
  fluidRow(
    # plain text can be added in simple quotation marks, more refined option require html tags
    tags$div(
      tags$h4("General information"),
      tags$ul(
        tags$li("The purpose of this R Shiny app is to assist researchers in designing conjoint studies and evaluating reliability of conjoint studies"),
        tags$ol(
          tags$li("Full or fractional factorial designs are critical to how many profiles can or must be shown in a conjoint study.
                  From our own experience, we know that these designs are not always easy to come by,
                  e.g., in the entrepreneurship field, the ortho-plans of Hahn & Shapiro (1966) are often used.
                  However, much more accessible and modern solutions are available and this app bundles two R packages into an user interface"),
          tags$li("We propse an analytical workflow to
                help researchers better probe threats to response consistency and
                to evaluate — and communicate — confidence in statistical models
                using conjoint data. This app makes our workflow accessible and easy to use"),
        ),
        tags$li("Please carefully read the instructions for using of both parts of this app"),
        tags$li("Disclaimer: The use of the app is at your own risk"),
      )
    ),
    tags$h6("R Shiny App written by: Jens Schüler")
  )
)
