#' Launch the Shiny App
#'
#' This function launches the Shiny application.
#'
#' @importFrom DT renderDataTable dataTableOutput datatable formatRound
#' @importFrom shiny runApp shinyApp fluidPage fluidRow observe updateNumericInput numericInput selectInput actionButton renderText textOutput renderPrint verbatimTextOutput conditionalPanel icon eventReactive req withProgress incProgress
#' @importFrom shinydashboard box valueBox tabItem tabItems menuItem sidebarMenu dashboardSidebar dashboardHeader dashboardBody dashboardPage
#' @importFrom plotly renderPlotly plotlyOutput plot_ly add_bars add_trace layout config
#' @importFrom ggplot2 last_plot
#' @import rhandsontable
#' @import shinyBS
#' @importFrom stats binomial dbinom pbeta pbinom quasi rexp rmultinom runif
#' @importFrom tibble tibble
#' @importFrom gt cell_text cells_column_labels cols_hide cols_label fmt_number fmt_percent gt tab_header tab_options tab_style
#' @export
launch.shinyapp <- function() {
  app_dir <- system.file("shiny", "app", package = "boinet")
  if (app_dir == "") {
    stop("Could not find the Shiny application directory.
              Ensure 'myapp_folder_name' is correctly placed in inst/shiny.")
  }
  shiny::runApp(app_dir, display.mode = "normal")
}
