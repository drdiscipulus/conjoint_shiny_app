#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load packages
library(shiny) # Shiny package
library(shinyjs) # Used for reset functionality
library(shinycssloaders) # Used loading animations
library(shinyalert) # Used to create popup alerts
library(bslib) # Used for theming
library(tidyverse) # Used for data wrangling and manipulation
library(reactable) # Interactive tables
library(FrF2) # Create two-level fractional factorial designs
library(DoE.base) # Create n-level full and fractional factorial designs
library(broom) # Used to create tidy data frames with model results
library(psych) # Used to calculate ICC values
library(sandwich) # For calculating robust standard errors
library(lmtest) # For calculating robust standard errors
library(parameters) # To obtain robust standard errors
library(plotly) # To create violin plots
library(viridis) # Provides additional color schemes
library(vroom) # Reading and writing .csv files
library(openxlsx)# Read and write .xlsx files
source("functions_factorial.R") # Source functions
source("functions_reliability.R") # Source functions


# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Include shinjs
    useShinyjs(),
    
    ###################### Styling ###############################################
    
    # Customize bootstrap united theme
    theme = bs_theme(
        version = 5, primary = "#009260", secondary = "#7F8990", base_font = "Arial",
        code_font = font_google("Roboto Mono"), `enable-gradients` = FALSE,
        `enable-transitions` = FALSE, `enable-shadows` = TRUE, bootswatch = "united"
    ),
    
    # Remove margin from navbar title
    tags$style(HTML(".navbar-nav > li > a, .navbar-brand{margin-right:auto}")),
    # Set bottom margin of navbar to 20px
    tags$style(HTML(".navbar, .navbar:not(.fixed-bottom):not(.navbar-fixed-bottom):not(.navbar-fixed-bottom){margin-bottom: 15px;}")),
    # Set left padding of input column to zero to make it flush
    tags$style(HTML(".col-sm-2, element {padding-left: 0px; padding-right: 15px;}")),
    # Set right padding of main panel columns to zero to make it flush
    tags$style(HTML(".col-sm-10, element {padding-right: 0px;}")),
    # Customize the themeing of the active tabpanels
    tags$style(HTML(".nav-tabs > li.active > a {background-color: #009260; color: #fff; border-color: #B6B6B6}")),
    # Fit modals to content
    tags$style(type = 'text/css', '.modal-dialog { width: fit-content !important; }'),
    # Change slider color
    tags$style(HTML(".irs--single .irs--shiny .irs-from, .irs--shiny .irs-to, .irs--shiny .irs-single {color: #fff;text-shadow: none; padding: 1px 3px; background-color: #009260;border-radius: 3px;font-size: 11px;line-height: 1.333;}")),
    tags$style(HTML(".irs--shiny .irs-bar {background: #009260;}")),
    tags$style(HTML(".irs--shiny .irs-bar {top: 25px;height: 8px;border-top: 1px solid #009260;	border-bottom: 1px solid #009260;background: #009260;}")),

    
    ###################### Layout ################################################
    
    # Base layout: navbar page
    navbarPage(
        # Set title and add banner at top right
        title = div(
            "Conjoint Studies",
            img(
                src = "index.png",
                height = "40px",
                style = "position: absolute; right: 10px; top:7.5px;"
            )
        ),
        # Set browser title
        windowTitle = "Conjoint Studies",
        
        ###################### Tabs ################################################
        
        # Menu entry with drop down selection
        navbarMenu(
            # Menu title
            "About",
            # General about
            source(file.path("ui/01_ui_general_about_tab.R"), local = TRUE)$value,
            # About factorial designs
            source(file.path("ui/01_ui_factorial_about_tab.R"), local = TRUE)$value,
            # About test-retest reliability
            source(file.path("ui/01_ui_reliability_about_tab.R"), local = TRUE)$value,
        ),
        
        # Factorial tab with drop downs
        navbarMenu(
            # Menu title
            "Factorial Designs",
            # 2-level designs
            source(file.path("ui/02_ui_factorial_two_level_tab.R"), local = TRUE)$value,
            # n-level designs
            source(file.path("ui/03_ui_factorial_n_level_tab.R"), local = TRUE)$value,
        ),
        
        # Test-retest reliability tab
        source(file.path("ui/02_ui_reliability_tab.R"), local = TRUE)$value,
    )
)


# Define server logic
server <- function(input, output, session) {
    
    # Load all factorial design server logic
     source(file.path("server/01_server_factorial_two_level_tab.R"), local = TRUE)$value
     source(file.path("server/02_server_factorial_n_level_tab.R"), local = TRUE)$value
    
    # Load test-retest reliability server logic
    source(file.path("server/01_server_reliability_tab.R"), local = TRUE)$value
}


# Run the application
shinyApp(ui = ui, server = server)
