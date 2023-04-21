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
          tags$li("When researchers design metric conjoint experiments, they typically rely on factorial designs to determine the number of profiles required. 
                  From our own experience, we know that especially fractional factorial designs are not always easy to come by and that the Entrepreneurship literature primarily draws on the ortho-plans of Hahn and Shapiro (1966). Therefore, to assist researchers, we bundle two R packages to generate factorial designs into an accessible user interface"),
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
