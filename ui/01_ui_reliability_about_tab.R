# about panel that explains everything
tabPanel(
  title = "Test-Retest Reliability",
  fluidRow(
    # plain text can be added in simple quotation marks, more refined option require html tags
    tags$div(
      tags$h4("Purpose"),
      tags$ul(
        tags$li('This is a companion app to our working paper titled
                "Test-Retest Reliability in Metric Conjoint Experiments:
                A New Workflow to Evaluate Confidence in Model Results"'),
        tags$li("In this paper, we outline and show an analytical workflow to
                help researchers better probe threats to response consistency and
                to evaluate — and communicate — confidence in statistical models
                using conjoint data"),
        tags$li("This app makes our workflow accessible and easy to use with just one upload and two clicks"),
      ),
      tags$h4("How to use this application"),
      tags$ul(
        tags$li("You can upload your data as a .csv or .xlsx file. Other file formats are not accepted"),
        tags$li("The data must be in long format, contain certain columns with specific values and data classes"),
        tags$li("You will get error messages, or the app may just not work, if your data does not meet these requirements"),
        tags$li("Please follow this sequence:"),
        tags$ul(
          tags$li("Step 1: Upload a .csv or .xlsx file"),
          tags$li("Step 2: Click the check button to evaluate if your supplied data seems to be okay"),
          tags$li("Step 3: Click the workflow button to evaluate your data"),
          tags$li("Step 4: Reset the app by clicking the reset button - also deletes your uploaded data"),
          tags$li("Optional: Inspect your data after uploading or checking by clicking the inspect table button"),
          tags$li("Optional: Inspect data classes and types after uploading or checking your data by clicking the inspect type button"),
          tags$li("Optional: You can download a demo data set as a .csv or .xlsx file"),
        ),
      ),
      tags$h4("Requirements"),
      tags$ul(
        tags$li("See the included sample datasets on how your data must be prepared"),
        tags$li("Your uploaded data must be in long format"),
        tags$li('When reading a csv file, the delimiter is automatically detected, but we recommend using ","'),
        tags$li("The column names should all be in lower case and if not, they are automatically converted to lower case"),
        tags$li("If your data has missings, leave cells with missing values empty or write NA into them."),
        tags$li("Your data must include specific columns that contain specific data types:"),
        tags$ol(
          tags$li('The "respondent" column designates the respondent id and should be numeric or character'),
          tags$li('The "round" column designates the first (1) and replication (2) round - only use 1 and 2'),
          tags$li('The "profile" column designates the respective profile numbers e.g. 1 to x'),
          tags$li('The "dv" column contains the dependent variable. Only one dependent variable can be considered at a time'),
          tags$li('There must be at least two attributes and the attributes must be named consecutively with "att_1", "att_2" to "att_x"'),
          tags$li('"round", "profile", "dv", and all attributes, must be numeric'),
        ),
        tags$li("The app checks whether your data meets these requirements"),
        tags$li("While the app tries to fix some issues e.g. coercing data to numeric and enforcing lower case, it can't handle all eventualities"),
        tags$li("Should you run into issues, it is best to stick to the guidelines and inspect the provided demo data sets"),
        tags$li("As soon as the server ends your session, your data will be deleted automatically, but you can also delete it manually by using the reset button"),
      ),
      tags$h4("Abstract"),
      "Metric conjoint studies are a popular research design in the entrepreneurship
      domain. For these studies, test-retest reliabilities of𝜌 > 0.70 or higher
      are an often-cited reliability criterion. Despite their widespread use,
      however, there is little rigorous analysis of whether test-retest reliability
      in metric conjoint studies relates to model efficacy. Informed by a systematic
      literature review, we conducted two Monte Carlo simulations to evaluate the
      effect of various determinants of test-retest reliability in conjoint experiments.
      We then illustrate a workflow for entrepreneurship researchers employing
      conjoint designs to better evaluate—and communicate—confidence in conjoint model results",
      tags$br(),
      tags$br(),
      "All code and data used in this publication is available on the Open Science Framework:",
      tags$a(href = "https://osf.io/qpzhf/?view_only=61cd1571ec23440da1974756002a819e", "Link to Repository", target = "_blank"),
      tags$br(),
      tags$h4("Profile pages"),
      tags$ul(
        tags$li(tags$a(href = "https://www.eship.uni-bayreuth.de/de/team/schueler_jens/index.php", "Jens Schüler", target = "_blank")),
        tags$li(tags$a(href = "https://business.ku.edu/people/brian-anderson", "Brian S. Anderson", target = "_blank")),
        tags$li(tags$a(href = "https://bloch.umkc.edu/profiles/faculty-directory/charles-y.-murnieks.html", "Charles Y. Murnieks", target = "_blank")),
        tags$li(tags$a(href = "https://www.linkedin.com/in/alexkuesshauer/?originalSubdomain=de", "Alexander Küsshauer", target = "_blank")),        
        tags$li(tags$a(href = "https://www.eship.uni-bayreuth.de/de/team/baum_matthias/index.php", "Matthias Baum", target = "_blank")),
      )
    )
  )
)
