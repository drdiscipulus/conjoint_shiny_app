# About panel that explains everything
tabPanel(
  title = "Factorial Designs",
  fluidRow(
    tags$div(
      tags$h4("Purpose"),
      tags$ul(
        tags$li("Full or fractional factorial designs are critical to how many profiles can or must be shown in a conjoint study"),
        tags$li("From our own experience, we know that these designs are not always easy to come by,
                  e.g., in the Entrepreneurship field, the ortho plans of Hahn & Shapiro (1966) are frequently used"),
        tags$li("To assisst researchers, this app bundles two R packages to generate factorial designs into an accessible user interface"),
        tags$ul(
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/FrF2/index.html", "FrF2: Fractional Factorial Designs with 2-Level Factors", target = "_blank")),
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/DoE.base/index.html", "DoE.base: Full Factorials, Orthogonal Arrays and Base Utilities for DoE Packages", target = "_blank")),
        ),
        tags$li("Easy-to-understand introductions to factorial designs:"),
        tags$ul(
          tags$li(tags$a(href = "https://wires.onlinelibrary.wiley.com/doi/abs/10.1002/wics.27", 'Overview: Fractional factorial design', target = "_blank")),
          tags$li(tags$a(href = "https://www.itl.nist.gov/div898/handbook/pri/section3/pri333.htm", 'NIST/SEMATECH e-Handbook of Statistical Methods', target = "_blank")),
        ),
      ),
      tags$h4("How to use the application"),
      tags$h5("Two-level factorial designs"),
      tags$ul(
        tags$li("Pick this tab when you plan to conduct an experiment with only two-levels per attribute/factor"),
        tags$li("Set the number of attributes with the slider input"),
        tags$li("Select whether you want a full or fractional factorial design"),
        tags$li("The effects selection is only relevant when you choose a fractional design"),
        tags$ul(
          tags$li("Main Effects: Request a resolution III design"),
          tags$li("Two-Way: Request a resolution IV design"),
#          tags$li("Three-Way: Request a resolution VI design"),
          tags$li(tags$a(href = "https://en.wikipedia.org/wiki/Fractional_factorial_design", "Read more about factorial designs and resolutions", target = "_blank")),
          tags$li("Note: "),
          tags$ol(
            tags$li('Select "Main Effects" if you do not plan to manipulate a moderator variable in your experiment'),
            tags$li('Select "Two-Way" if you manipulate a moderator'),
#            tags$li('Select "Three-Way" if your experiment includes a manipulated three-way interaction .e.g., moderated moderation'),
          )
        ),
        tags$li("This information is used to call functions of the DoE.base and FrF2 package: "),
        tags$ul(
          tags$li("Full design: fac.design(nlevels = attributes)"),
          tags$li("Fractional design: FrF2(nfactors = attributes, resolution = resolution)"),
        )
      ),
      tags$h5("N-level and mixed-level designs"),
      tags$ul(
        tags$li("When your experiment has more than two-levels per attribute/factor or mixed levels"),
        tags$li("Enter the number of levels for each attribute, separated by comma, e.g., 4,4,4 or 2,4,4,3"),
        tags$li("No more than 4 levels and 7 attributes are currently allowed"),
        tags$li("Select whether you want a full or fractional factorial design"),
        tags$li("The effects selection is only relevant when you choose a fractional design - see previous explanation"),
        tags$li("This procedure relies on the DoE.base package and is more complex:"),
        tags$ul(
          tags$li("The same fac.design function is called when a full design is requested"),
          tags$li("The oa.design function searches a list of orthogonal arrays for the smallest array representing the specified number of attributes and levels"), 
          tags$li("If an array can map more attributes than needed, an automatic column selection is made so that the number of profiles for the main effects model is minimal (resolution III)"),
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
