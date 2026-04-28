# Conjoint Companion Shiny Source

This repository contains the R Shiny source code behind the companion web app for the paper.
It is meant as an educational source overview for readers who want to see how the
publication workflow is implemented and what happens in the background.

- Live web app: https://shiny.drdiscipulus.de/conjoint_app/
- Desktop/offline companion app: https://github.com/drdiscipulus/conjoint_desktop_app
- Paper: https://doi.org/10.1177/10422587231184071

The repository is not intended as an active-development project or as a release
channel. The Shiny source is provided for code inspection, review, and learning.
Packaged downloads belong to the desktop companion app.

## What The App Does

The app supports two publication-related workflows:

1. Generate full and fractional factorial designs for conjoint experiments.
2. Run the test-retest reliability workflow described in the accompanying paper:
   *Test-Retest Reliability in Metric Conjoint Experiments: A New Workflow to
   Evaluate Confidence in Model Results*.

The statistical workflow is treated as a protected baseline. Maintenance should
avoid changing formulas, output definitions, or interpretation logic unless a
specific bug is identified and covered by regression tests.

## How The App Is Built

- `app.R` is the entry point. It loads packages, sources helper files, defines
  the Shiny navbar, and starts the app.
- `ui/` contains the tab layouts and explanatory screens shown in the browser.
- `server/` contains the tab-specific server logic for factorial design
  generation and test-retest reliability analysis.
- `R/` contains focused helpers for upload validation, temporary session files,
  result exports, labels, UI components, alias diagnostics, and interaction
  coverage checks.
- `functions_factorial.R`, `functions_reliability.R`, and `custom_corr_plot.R`
  contain the older workflow-specific statistical and plotting helpers that the
  app still sources directly.
- `tests/` contains regression and helper tests, including fixtures generated
  from the bundled demo data.
- `demo_data.csv` and `demo_data.xlsx` are public sample files for trying the
  reliability workflow.

This is intentionally a plain Shiny app rather than an R package. The structure
keeps the publication companion easy to inspect and close to the deployed web
app.

## Local Setup

Install the required R packages before running the app:

```r
install.packages(c(
  "shiny", "shinyjs", "shinycssloaders", "bslib",
  "tidyverse", "reactable", "FrF2", "DoE.base", "broom", "psych",
  "sandwich", "lmtest", "parameters", "plotly", "viridis", "vroom",
  "openxlsx", "prismatic", "testthat"
))
```

This repository documents dependencies but does not pin them with `renv`.

## Run Locally

```sh
Rscript scripts/run_app.R
```

## Check The Source

```sh
Rscript scripts/check_app.R
```

The check script reports missing full-app packages and runs the available
regression/security tests when their dependencies are installed.

Optional browser-level smoke check:

```sh
Rscript scripts/ui_smoke_test.R
```

This script skips cleanly if the optional `shinytest2` package is not installed.

## Input Format

Reliability uploads must be `.csv` or `.xlsx` files with exactly one table. The
required columns are:

- `respondent`
- `round`
- `profile`
- `dv`
- at least two attribute columns named with the prefix `att_`

The `round`, `profile`, `dv`, and `att_` columns must be numeric or cleanly
coercible to numeric. The `round` column must contain exactly rounds `1` and
`2`.

Current upload limits:

- maximum file size: 5 MB
- maximum rows: 25,000
- maximum columns: 250

## Outputs

After a successful reliability analysis, the app can export:

- an XLSX workbook with reliability, slope-difference, and pooled-regression
  tables in three sheets: `Reliability table`, `Slope Difference`, and
  `Pooled Regression`,
- a ZIP archive with the same three result tables as separate CSV files.

Plots can be downloaded from the Plotly toolbar in the app.

## Privacy And Data Handling

Uploaded data and generated result files are processed in a session-specific
temporary directory. The app registers cleanup at session end and removes
session-generated files on reset. User-provided filenames are used only for
display/format checks, not for internal paths.

## Maintenance

This repository is maintained occasionally and conservatively. The statistical
workflow should remain stable unless a specific bug is identified and covered by
tests.

## Citation

If you use the app, source code, or workflow in research or teaching, please
cite the article:

Schueler, J., Anderson, B. S., Murnieks, C. Y., Baum, M., & Kuesshauer, A.
(2024). Test-Retest Reliability in Metric Conjoint Experiments: A New Workflow
to Evaluate Confidence in Model Results. *Entrepreneurship Theory and Practice,
48*(2), 742-757. https://doi.org/10.1177/10422587231184071

Machine-readable citation metadata are available in `CITATION.cff`.

## License

This project is licensed under the GNU General Public License v3.0 only. See
`LICENSE`.

R Shiny app written by Jens Schueler.
