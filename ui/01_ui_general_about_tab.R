# Overview tab for the app purpose, scope, and data handling
tabPanel(
  title = "Overview",
  fluidRow(
    tags$div(
      class = "about-copy",
      tags$h3("Conjoint Companion"),
      tags$p(
        "This app accompanies the workflow introduced in ",
        tags$a(
          href = "https://journals.sagepub.com/doi/10.1177/10422587231184071",
          "Test-Retest Reliability in Metric Conjoint Experiments: A New Workflow to Evaluate Confidence in Model Results",
          target = "_blank"
        ),
        ". It helps researchers prepare conjoint designs and evaluate response consistency in metric conjoint experiments."
      ),
      tags$h4("What You Can Do"),
      tags$ul(
        tags$li("Generate full and fractional factorial designs for conjoint studies."),
        tags$li("Inspect two-way interaction estimability for two-level fractional designs."),
        tags$li("Inspect pairwise coverage and balance for N-level and mixed-level designs."),
        tags$li("Upload conjoint response data and run the test-retest reliability workflow from the paper."),
        tags$li("Review reliability tables, regression diagnostics, and plots."),
        tags$li("Download sample data and analysis results.")
      ),
      tags$h4("How To Use The App"),
      tags$ol(
        tags$li("Use the factorial design tabs if you still need to construct a conjoint design."),
        tags$li("Use the test-retest reliability tab when you have data from an initial and replication round."),
        tags$li("Start with the bundled demo data if you want to inspect the required structure first."),
        tags$li("Validate your uploaded data before running the analysis.")
      ),
      tags$h4("Data Handling"),
      tags$p(
        "Uploads are processed only for the current session. The app accepts CSV and one-sheet XLSX files, applies a 5 MB upload limit, and rejects reliability datasets with more than 25,000 rows. Generated result files are stored in a session-specific temporary folder and removed when the session ends."
      ),
      tags$h4("Privacy"),
      tags$p(
        "Uploaded files and generated outputs are processed in a session-specific temporary folder. They are removed when the session ends, and reset clears the current session files manually. The app does not intentionally store uploaded datasets or track user behavior."
      ),
      tags$h4("Paper, Data, And Authors"),
      tags$ul(
        tags$li("Paper: ", tags$a(href = "https://journals.sagepub.com/doi/10.1177/10422587231184071", "Entrepreneurship Theory and Practice article", target = "_blank")),
        tags$li("Open Science Framework: ", tags$a(href = "https://osf.io/qpzhf/?view_only=61cd1571ec23440da1974756002a819e", "publication code and data", target = "_blank")),
        tags$li("Jens Schüler: ", tags$a(href = "https://www.eship.uni-bayreuth.de/de/team/schueler_jens/index.php", "profile page", target = "_blank")),
        tags$li("Brian S. Anderson: ", tags$a(href = "https://business.ku.edu/people/brian-anderson", "profile page", target = "_blank")),
        tags$li("Charles Y. Murnieks: ", tags$a(href = "https://bloch.umkc.edu/profiles/faculty-directory/charles-y.-murnieks.html", "profile page", target = "_blank")),
        tags$li("Matthias Baum: ", tags$a(href = "https://www.eship.uni-bayreuth.de/de/team/baum_matthias/index.php", "profile page", target = "_blank")),
        tags$li("Alexander Küsshauer: ", tags$a(href = "https://www.linkedin.com/in/alexkuesshauer/?originalSubdomain=de", "profile page", target = "_blank"))
      ),
      tags$p(
        "Please review your results carefully. This app supports the workflow described in the paper, but it does not replace substantive judgment about your conjoint design, measurement strategy, or model specification."
      ),
      tags$p("R Shiny app written by Jens Schüler.")
    )
  )
)
