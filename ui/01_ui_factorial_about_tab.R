# about panel that explains everything
tabPanel(
  title = "Factorial Designs",
  fluidRow(
    # plain text can be added in simple quotation marks, more refined option require html tags
    tags$div(
      tags$h4("Purpose"),
      tags$ul(
        tags$li("Full or fractional factorial designs are critical to how many profiles can or must be shown in a conjoint study"),
        tags$li("From our own experience, we know that these designs are not always easy to come by,
                  e.g., in the entrepreneurship field, the ortho-plans of Hahn & Shapiro (1966) are often used"),
        tags$li("Thus, this app bundles two R packages to generate factorial designs into an accessible user interface"),
        tags$ul(
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/FrF2/index.html", "FrF2: Fractional Factorial Designs with 2-Level Factors", target = "_blank")),
          tags$li(tags$a(href = "https://cran.r-project.org/web/packages/DoE.base/index.html", "DoE.base: Full Factorials, Orthogonal Arrays and Base Utilities for DoE Packages", target = "_blank")),
        ),
      ),
      tags$h4("How to use it"),
      tags$h5("Two-Level factorial designs"),
      tags$ul(
        tags$li("Pick this tab when you plan to conduct an experiment with only two-levels per attribute/factor"),
        tags$li("Set the number of attributes with the slider input"),
        tags$li("Select whether you want a full or fractional factorial design"),
        tags$li("The effects selection is only relevant when you choose a fractional design"),
        tags$ul(
          tags$li("Main Effects: Requests a resolution III design"),
          tags$li("Two-Way: Requestes a resolution IV design"),
          tags$li("Three-Way: Requests a resolution VI design"),
          tags$li(tags$a(href = "https://en.wikipedia.org/wiki/Fractional_factorial_design", "Read more about factorial designs and resolutions", target = "_blank")),
          tags$li("Note: "),
          tags$ol(
            tags$li('Select "Main Effects" if you do not plan to manipulate a moderator variable in your experiment'),
            tags$li('Select "Two-Way" if you manipulate one or more moderators'),
            tags$li('Select "Three-Way" if your experiment includes a manipulated three-way interaction .e.g., moderated moderation'),
          )
        ),
        tags$li("This information is used to call functions of the DoE.base and FrF2 package: "),
        tags$ul(
          tags$li("Full design: fac.design(nlevels = attributes)"),
          tags$li("Fractional design: FrF2(nfactors = attributes, resolution = resolution)"),
        )
      ),
      tags$h5("N-Level and mixed-level designs"),
      tags$ul(
        tags$li("When your experiment has more than two-levels per attribute/factor or mixed levels"),
        tags$li("Enter the number of levels for each attribute, separated by comma, e.g., 4,4,4 or 2,4,4,3"),
        tags$li("No more than 4 levels and 6 attributes are currently allowed"),
        tags$li("Select whether you want a full or fractional factorial design"),
        tags$li("The effects selection is only relevant when you choose a fractional design - see previous explanation"),
        tags$li("This procedure relies on the DoE.base package and is more complex:"),
        tags$ul(
          tags$li("The same fac.design function is called when a full design is requested"),
          tags$li('If a fractional main effects only design is requested: oa.design(nlevels = attributes, columns = "min3")'),
          tags$li("If a fractional two-way design is requested, an interative procedure is used (use with caution!):"),
          tags$ol(
            tags$li('Identify suitable resolution III designs: show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = FALSE)'),
            tags$li("Some resolution III arrays can accomodate more attributes than requested - a subset of columns could result in a resolution IV design"),
            tags$li('These candidates are screened for resolution IV results: oa.design(id, nlevels = attributes, columns = "min3")'),
            tags$li('If no resolution IV option was found, resolution IV arrays are searched analogously: show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = TRUE)'),
          )
        )
      ),
      tags$h4("Disclaimer:"),
      tags$ul(
        tags$li("Please always evaluate the suitability of the generated designs to make sure they fit your requirements BEFORE you start your experiment"),
        tags$li("The use of the app is at your own risk"),
      )
    )
  )
)
