# About panel that explains everything
tabPanel(
  title = "Factorial Designs",
  fluidRow(
    tags$div(
      tags$h4("Factorial Designs"),
      tags$ul(
        tags$li("Factorial designs are typically used to reduce/minimize the number of decision profiles in conjoint studies"),
        tags$li("However, these designs are not always easy to come by and researchers tend to rely on old ortho-plan publications"),
        tags$li("While more modern solutions are available e.g., in R, using these requires some familiarity with the software"),
        tags$li("Therefore, we bundle two R packages into an accessible user interface:"),
        tags$ul(
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/FrF2/index.html", "FrF2: Fractional Factorial Designs with 2-Level Factors", target = "_blank")),
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/DoE.base/index.html", "DoE.base: Full Factorials, Orthogonal Arrays and Base Utilities for DoE Packages", target = "_blank")),
        ),
        tags$li("Introduction to factorial designs:"),
        tags$ul(
          tags$li(tags$a(href = "https://wires.onlinelibrary.wiley.com/doi/abs/10.1002/wics.27", 'Gunst, R. F., & Mason, R. L. (2009). Fractional factorial design. Wiley Interdisciplinary Reviews: Computational Statistics, 1(2), 234-244.', target = "_blank")),
          tags$li(tags$a(href = "https://www.itl.nist.gov/div898/handbook/pri/section3/pri333.htm", 'NIST/SEMATECH e-Handbook of Statistical Methods', target = "_blank")),
          tags$li(tags$a(href = "https://en.wikipedia.org/wiki/Fractional_factorial_design", "Wikipedia article on fractional designs and resolutions", target = "_blank")),
        ),
        tags$li("The app provides you with a generated factorial design plus its correlation structure (all main effects and two-way interactions)"),
      ),
      tags$h4("Two-level designs"),
      tags$ul(
        tags$li("Choose this tab if all attributes are manipulated into two conditions e.g. high and low"),
        tags$li("Use the slider to set the number of attributes"),
        tags$li("Choose if you want a full or fractional design"),
        tags$li("In case of a fractional design, select the model:"),
        tags$ul(
          tags$li("Resolution III: If none of the manipulated attributes are to be used as a moderator"),
          tags$li("Resolution IV: If you want to use one of the manipulate attributes as a moderator"),
          tags$li("Note: A resolution V design (not covered by this app) might be required when you want to manipulate more than one moderator (check the correlation structure)")
        ),
        tags$li("This information is passed to the DoE.base and FrF2 package:"),
        tags$ul(
          tags$li("Function call for full factorial designs: fac.design(nlevels = attributes)"),
          tags$li("Function call for fractional factorial designs: FrF2(nfactors = attributes, resolution = resolution)"),
        )
      ),
      tags$h4("N-level/mixed-level designs"),
      tags$ul(
        tags$li("Choose this tab if some or all attributes are manipulated into more than two conditions e.g. low, medium, and high"),
        tags$li("Enter the number of levels for each attribute, separated by a comma, e.g., 4,4,4 or 2,4,4,3 - no more than 4 levels and 7 attributes are supported"),
        tags$li("Choose if you want a full or fractional design"),
        tags$li("In case of a fractional design, select a resolution III or IV design"),
        tags$li("The following procedure relies on the DoE.base package:"),
        tags$ul(
          tags$li("Function call for full factorial designs: fac.design(nlevels = attributes)"),
          tags$li("Fractional designs use the oa.design function, which searches a list of orthogonal arrays for the smallest array representing the specified number of attributes and levels"), 
          tags$li("If an orthogonal array can map more attributes than specified, an automatic column selection is used to minimize the number of profiles for the main effects model (resolution III)"),
          tags$li('The corresponding function call for resolution III models: oa.design(nlevels = attributes, columns = "min3")'),
          tags$li("If one of the manipulated variables is a moderator, an interative procedure is used (use with caution!):"),
          tags$ol(
            tags$li("Some resolution III arrays can accomodate more attributes than requested - a subset of columns could result in a resolution IV design"),
            tags$li('Identify suitable resolution III arrays: show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = FALSE)'),
            tags$li('These arrays are screened for resolution IV results: oa.design(id, nlevels = attributes, columns = "min3")'),
            tags$li('If no resolution IV result was found, resolution IV arrays are searched analogously: show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = TRUE)'),
            tags$li("However, these resolution IV arrays may be larger than necessary for the given attribute and level combination"),
            tags$li("Note: The correlation table plot only supports resolutions up to IV (see corrPlot function of the DoE.base package)")
          )
        ),
        tags$li("The search can take some time - refresh the app to cancel the process"),
      ),
      tags$h5("Disclaimer: Always evaluate the suitability of the generated designs BEFORE you start your experiment"),
    )
  )
)
