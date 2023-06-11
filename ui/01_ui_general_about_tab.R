# About panel that explains the structure of the app
tabPanel(
  title = "Info",
  fluidRow(
    tags$div(
      tags$h4("The purpose of this conjoint app is twofold:"),
      tags$ol(
        tags$li("Provide researchers with a factorial design generator"),
        tags$ul(
          tags$li("Especially fractional factorial designs are often used in conjoint studies to reduce/minimize the number of decision profiles"),
          tags$li("However, these designs are not always easy to come by and researchers tend to rely on old ortho-plan publications"),
          tags$li("For this purpose, we bundle two R packages to generate factorial designs into an accessible user interface"),
        ),
        tags$li("We bundle our proposed workflow for evaluating response consistency in conjoint studies into an easy to use app"),
        tags$ul(
          tags$li("The corresponding paper: Test-Retest Reliability in Metric Conjoint Experiments: A New Workflow to Evaluate Confidence in Model Results"),
          tags$li("In this paper, we outline and show an analytical workflow to help researchers better probe threats to response consistency and to evaluate — and communicate — confidence in statistical models using conjoint data"),
          tags$li("Link to our paper published in Entreprenuership Theory and Practice: ..."),
        ),
      ),
    ),
    tags$h6("Disclaimer: Please carefully read the instructions and use the app at your own risk"),
    tags$h6("R Shiny App written by: Jens Schüler")
  )
)
