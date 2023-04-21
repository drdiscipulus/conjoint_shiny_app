# About panel that explains everything
tabPanel(
  title = "Factorial Designs",
  fluidRow(
    tags$div(
      tags$h4("Purpose"),
      tags$ul(
        tags$li("When researchers design metric conjoint experiments, they typically rely on factorial designs to determine the number of profiles required"),
        tags$li("From our own experience, we know that especially fractional factorial designs are not always easy to come by and that the Entrepreneurship literature primarily draws on the ortho-plans of Hahn and Shapiro (1966)"),
        tags$li("While more modern solutions are available for creating factorial designs, e.g., in R, using these requires some familiarity with the respective program"),
        tags$li("Therefore, to assist researchers, we bundle two R packages to generate factorial designs into an accessible user interface:"),
        tags$ul(
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/FrF2/index.html", "FrF2: Fractional Factorial Designs with 2-Level Factors", target = "_blank")),
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/DoE.base/index.html", "DoE.base: Full Factorials, Orthogonal Arrays and Base Utilities for DoE Packages", target = "_blank")),
        ),
        tags$li("Introductory resources on factorial designs:"),
        tags$ul(
          tags$li(tags$a(href = "https://wires.onlinelibrary.wiley.com/doi/abs/10.1002/wics.27", 'Gunst, R. F., & Mason, R. L. (2009). Fractional factorial design. Wiley Interdisciplinary Reviews: Computational Statistics, 1(2), 234-244.', target = "_blank")),
          tags$li(tags$a(href = "https://www.itl.nist.gov/div898/handbook/pri/section3/pri333.htm", 'NIST/SEMATECH e-Handbook of Statistical Methods', target = "_blank")),
          tags$li(tags$a(href = "https://en.wikipedia.org/wiki/Fractional_factorial_design", "Wikipedia article on fractional designs and resolutions", target = "_blank")),
        ),
      ),
      tags$h4("How to use this application"),
      tags$h5("Two-level factorial designs"),
      tags$ul(
        tags$li("Select this tab if you plan to conduct a conjoint experiment with two levels per attribute"),
        tags$li("Use the slider input to select the desired number of attributes"),
        tags$li("Select a full or fractional factorial design"),
        tags$li("Selecting main effects or two-way interactions is only relevant for fractional designs"),
        tags$ul(
          tags$li("Main Effects: Request a resolution III design"),
          tags$li("Two-Way: Request a resolution IV design"),
          tags$li("Note: "),
          tags$ol(
            tags$li("Main Effects: Sufficient if you do not manipulate a moderator variable"),
            tags$li("Two-Way: Required when manipulating a moderator variable"),
          )
        ),
        tags$li("This information is then passed on to the DoE.base and FrF2 package:"),
        tags$ul(
          tags$li("Function call for full factorial designs: fac.design(nlevels = attributes)"),
          tags$li("Function call for fractional factorial designs: FrF2(nfactors = attributes, resolution = resolution)"),
        )
      ),
      tags$h5("N-level and mixed-level factorial designs"),
      tags$ul(
        tags$li("Select this tab if you plan to conduct a conjoint experiment with more than two-levels or different levels per attribute"),
        tags$li("Enter the number of levels for each attribute, separated by a comma, e.g., 4,4,4 or 2,4,4,3"),
        tags$li("No more than 4 levels and 7 attributes are currently allowed"),
        tags$li("Select a full or fractional factorial design"),
        tags$li("Selecting main effects or two-way interactions is only relevant for fractional designs"),
        tags$li("The following procedure relies on the DoE.base package:"),
        tags$ul(
          tags$li("Function call for full factorial designs: fac.design(nlevels = attributes)"),
          tags$li("Fractional designs use the oa.design function, which searches a list of orthogonal arrays for the smallest array representing the specified number of attributes and levels"), 
          tags$li("If an orthogonal array can map more attributes than specified, an automatic column selection is used to minimize the number of profiles for the main effects model (resolution III)"),
          tags$li('The corresponding function call for main effect models: oa.design(nlevels = attributes, columns = "min3")'),
          tags$li("If a fractional two-way design is requested, an interative procedure is used (use with caution!):"),
          tags$ol(
            tags$li("Some resolution III arrays can accomodate more attributes than requested - a subset of columns could result in a resolution IV design"),
            tags$li('Identify suitable resolution III arrays: show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = FALSE)'),
            tags$li('These arrays are screened for resolution IV results: oa.design(id, nlevels = attributes, columns = "min3")'),
            tags$li('If no resolution IV result was found, resolution IV arrays are searched analogously: show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = TRUE)'),
            tags$li("However, these resolution IV arrays may be larger than necessary for the given attribute and level combination")
          )
        ),
        tags$li("The search for a suitable fractional design can take some time. Refresh the app to cancel the process"),
      ),
      tags$h4("Disclaimer:"),
      tags$ul(
        tags$li("Please always evaluate the suitability of the generated designs to make sure they fit your requirements BEFORE you start your experiment"),
        tags$li("Use the app at your own risk"),
      )
    )
  )
)
