
# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "BOIN-ET Design Family"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("info-circle")),
      menuItem("BOIN-ET", tabName = "boinet", icon = icon("chart-line")),
      menuItem("TITE-BOIN-ET", tabName = "titeboinet", icon = icon("clock")),
      menuItem("gBOIN-ET", tabName = "gboinet", icon = icon("chart-bar")),
      menuItem("TITE-gBOIN-ET", tabName = "titegboinet", icon = icon("chart-area"))
    )
  ),

  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .error-message {
          color: red;
          font-weight: bold;
          margin: 10px 0;
        }
        .help-icon {
          color: #3c8dbc;
          margin-left: 5px;
          cursor: help;
          font-size: 14px;
        }
        .param-section {
          background-color: #ffffff;
          border: 1px solid #ddd;
          border-radius: 6px;
          margin-bottom: 15px;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .param-section-header {
          background-color: #f8f9fa;
          padding: 12px 15px;
          border-bottom: 1px solid #ddd;
          border-radius: 6px 6px 0 0;
          cursor: pointer;
          transition: background-color 0.2s;
          font-weight: 600;
          color: #495057;
        }
        .param-section-header:hover {
          background-color: #e9ecef;
        }
        .param-section-content {
          padding: 15px;
          display: none;
        }
        .param-section.expanded .param-section-content {
          display: block;
        }
        .param-section-header .fa-chevron-down {
          float: right;
          transition: transform 0.3s;
        }
        .param-section.expanded .param-section-header .fa-chevron-down {
          transform: rotate(180deg);
        }
        .form-group {
          margin-bottom: 15px;
        }
        .control-label {
          font-weight: 500;
          color: #333;
          margin-bottom: 5px;
        }
        .two-column {
          display: flex;
          gap: 15px;
        }
        .two-column > div {
          flex: 1;
        }
        .three-column {
          display: flex;
          gap: 10px;
        }
        .three-column > div {
          flex: 1;
        }
        .section-description {
          color: #666;
          font-size: 12px;
          font-style: italic;
          margin-bottom: 10px;
        }
        @media (max-width: 768px) {
          .two-column, .three-column {
            flex-direction: column;
          }
        }
      "))
    ),

    # Add JavaScript for collapsible sections
    tags$script(HTML("
      $(document).ready(function() {
        // Make first section expanded by default
        $('.param-section').first().addClass('expanded');

        // Handle section toggle
        $(document).on('click', '.param-section-header', function() {
          $(this).parent('.param-section').toggleClass('expanded');
        });
      });
    ")),

    tabItems(
      # Overview Tab
      tabItem(
        tabName = "overview",
        h2("BOIN-ET Design Family Overview"),
        fluidRow(
          box(
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            title = "About BOIN-ET",
            p("The BOIN-ET (Bayesian Optimal Interval - Efficacy and Toxicity) design family consists of model-assisted
              oncology phase I/II trial designs that aim to establish optimal biological doses accounting for both
              efficacy and toxicity in dose-finding studies."),
            br(),
            h4("Available Designs:"),
            tags$ul(
              tags$li(strong("BOIN-ET:"), " Basic design for binary efficacy and toxicity outcomes"),
              tags$li(strong("TITE-BOIN-ET:"), " Time-to-event design based on cumulative and pending data"),
              tags$li(strong("gBOIN-ET:"), " Generalized design for ordinal graded efficacy and toxicity outcomes"),
              tags$li(strong("TITE-gBOIN-ET:"), " Combination of time-to-event and ordinal graded outcomes")
            ),
            br(),
            p("Navigate through the tabs on the left to access each design's simulation interface.")
          )
        ),
        fluidRow(
          valueBox(
            value = "4",
            subtitle = "Design Methods",
            icon = icon("cubes"),
            color = "blue"
          ),
          valueBox(
            value = "Phase I/II",
            subtitle = "Trial Phase",
            icon = icon("flask"),
            color = "green"
          ),
          valueBox(
            value = "Dose-Finding",
            subtitle = "Primary Goal",
            icon = icon("bullseye"),
            color = "yellow"
          )
        )
      ),

      # BOIN-ET Tab
      tabItem(
        tabName = "boinet",
        h2("BOIN-ET Design Simulation"),

        fluidRow(
          box(
            width = 6,
            title = "Simulation Parameters",
            status = "primary",
            solidHeader = TRUE,

            # Basic Trial Design Section
            div(class = "param-section expanded",
              div(class = "param-section-header",
                "Basic Trial Design",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure the fundamental trial structure and patient enrollment parameters."),
                div(class = "two-column",
                  div(
                    numericInput("boin_ndose",
                      label = div("Number of Doses",
                        bsButton("help_ndose", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 6, min = 2, max = 10),
                    bsPopover("help_ndose", "Number of Doses",
                             "Total number of dose levels to investigate in the trial (typically 3-6 doses)",
                             placement = "top", trigger = "hover"),

                    numericInput("boin_startdose",
                      label = div("Starting Dose",
                        bsButton("help_startdose", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 1, min = 1, max = 10),
                    bsPopover("help_startdose", "Starting Dose",
                             "Starting dose level (1 = lowest dose, recommended for safety)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_cohortsize",
                      label = div("Cohort Size",
                        bsButton("help_cohortsize", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 3, min = 1, max = 10),
                    bsPopover("help_cohortsize", "Cohort Size",
                             "Number of patients per cohort (commonly 3 or 6 patients)",
                             placement = "top", trigger = "hover"),

                    numericInput("boin_ncohort",
                      label = div("Number of Cohorts",
                        bsButton("help_ncohort", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 12, min = 1, max = 50),
                    bsPopover("help_ncohort", "Number of Cohorts",
                             "Maximum number of cohorts (total patients = cohort size × number of cohorts)",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Target Toxicity and Efficacy Probability Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Target Toxicity and Efficacy Probability",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set the acceptable toxicity and desired efficacy probabilities."),
                div(class = "two-column",
                  div(
                    h5("Toxicity Parameters"),
                    numericInput("boin_phi",
                      label = div("Target Toxicity",
                        bsButton("help_phi", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.3, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("help_phi", "Target Toxicity (φ)",
                             "Target toxicity probability - maximum acceptable toxicity rate (e.g., 0.3 = 30%)",
                             placement = "top", trigger = "hover"),

                    numericInput("boin_phi1",
                      label = div("Lower Toxicity",
                        bsButton("help_phi1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.03, min = 0.001, max = 0.5, step = 0.01),
                    bsPopover("help_phi1", "Lower Toxicity Boundary (φ1)",
                             "Lower toxicity boundary - doses with toxicity ≤ this are considered under-dosed",
                             placement = "top", trigger = "hover"),

                    numericInput("boin_phi2",
                      label = div("Upper Toxicity",
                        bsButton("help_phi2", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.42, min = 0.1, max = 0.99, step = 0.01),
                    bsPopover("help_phi2", "Upper Toxicity Boundary (φ2)",
                             "Upper toxicity boundary - doses with toxicity ≥ this trigger de-escalation",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    h5("Efficacy Parameters"),
                    numericInput("boin_delta",
                      label = div("Target Efficacy",
                        bsButton("help_delta", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.6, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("help_delta", "Target Efficacy (δ)",
                             "Target efficacy probability - desired minimum efficacy rate (e.g., 0.6 = 60%)",
                             placement = "top", trigger = "hover"),

                    numericInput("boin_delta1",
                      label = div("Min Efficacy",
                        bsButton("help_delta1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.36, min = 0.01, max = 0.99, step = 0.01),
                    bsPopover("help_delta1", "Minimum Efficacy (δ1)",
                             "Minimum efficacy threshold - doses with efficacy < this considered sub-therapeutic",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Assessment Window & Accrual Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Assessment Window & Accrual",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Define the time windows for outcome assessment and patient enrollment rate."),
                div(class = "three-column",
                  div(
                    numericInput("boin_tauT",
                      label = div("Tox Assessment",
                        bsButton("help_tauT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 30, min = 1, max = 365),
                    bsPopover("help_tauT", "Toxicity Assessment Window",
                             "Days to assess toxicity outcomes (all toxicity evaluations must be completed within this period)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_tauE",
                      label = div("Eff Assessment",
                        bsButton("help_tauE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 45, min = 1, max = 365),
                    bsPopover("help_tauE", "Efficacy Assessment Window",
                             "Days to assess efficacy outcomes (all efficacy evaluations must be completed within this period)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_accrual",
                      label = div("Accrual Rate",
                        bsButton("help_accrual", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 10, min = 1, max = 100),
                    bsPopover("help_accrual", "Accrual Rate",
                             "Average days between patient enrollments (lower values = faster accrual)",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Data Generation Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Data Generation",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure statistical models for generating time-to-event data and correlations."),
                div(class = "three-column",
                  div(
                    selectInput("boin_geneventtime",
                      label = div("Event Time Distribution",
                        bsButton("help_eventtime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Weibull" = "weibull", "Uniform" = "uniform"),
                      selected = "weibull"),
                    bsPopover("help_eventtime", "Event Time Distribution",
                             "Distribution for generating time-to-event outcomes (Weibull more realistic, Uniform simpler)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    selectInput("boin_genenrolltime",
                      label = div("Enrollment Distribution",
                        bsButton("help_enrolltime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Uniform" = "uniform", "Exponential" = "exponential"),
                      selected = "uniform"),
                    bsPopover("help_enrolltime", "Enrollment Distribution",
                             "Distribution for patient enrollment times (Uniform = steady accrual, Exponential = variable accrual)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_tecorr",
                      label = div("Tox-Eff Correlation",
                        bsButton("help_tecorr", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.2, min = -1, max = 1, step = 0.1),
                    bsPopover("help_tecorr", "Toxicity-Efficacy Correlation",
                             "Correlation between toxicity and efficacy (-1 to 1, where 0.2 = weak positive correlation)",
                             placement = "top", trigger = "hover")
                  )
                ),
                div(class = "two-column",
                  div(
                    numericInput("boin_alphaT1",
                      label = div("Late Tox Prob",
                        bsButton("boin_help_alphaT1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("boin_help_alphaT1", "Late Toxicity Probability",
                             "Probability that toxicity occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_alphaE1",
                      label = div("Late Eff Prob",
                        bsButton("boin_help_alphaE1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("boin_help_alphaE1", "Late Efficacy Probability",
                             "Probability that efficacy occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Study Stopping Rules Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Study Stopping Rules",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set criteria for early study termination based on safety and futility."),
                div(class = "three-column",
                  div(
                    numericInput("boin_stoppingnpts",
                      label = div("Max Patients/Dose",
                        bsButton("help_stoppingnpts", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 36, min = 1, max = 500),
                    bsPopover("help_stoppingnpts", "Maximum Patients per Dose",
                             "Maximum number of patients per dose for early study termination",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_stoppingprobT",
                      label = div("Stop Prob for Tox",
                        bsButton("help_stopprobT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.95, min = 0.5, max = 1, step = 0.01),
                    bsPopover("help_stopprobT", "Stop Probability for Toxicity",
                             "Early termination threshold for toxicity (if P(toxicity > target) > this value, stop study)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_stoppingprobE",
                      label = div("Stop Prob for Eff",
                        bsButton("help_stopprobE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.99, min = 0.5, max = 1, step = 0.01),
                    bsPopover("help_stopprobE", "Stop Probability for Efficacy",
                             "Early termination threshold for efficacy (if P(efficacy < minimum) > this value, stop study)",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # OBD Selection Method Section
            div(class = "param-section",
              div(class = "param-section-header",
                "OBD Selection Method",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Choose methods for estimating efficacy and selecting the optimal biological dose."),
                div(class = "two-column",
                  div(
                    selectInput("boin_estpt",
                      label = div("Efficacy Estimation",
                        bsButton("help_estpt", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Observed Probabilities" = "obs.prob",
                                 "Fractional Polynomial" = "fp.logistic",
                                 "Multiple Isotonic" = "multi.iso"),
                      selected = "obs.prob"),
                    bsPopover("help_estpt", "Efficacy Estimation Method",
                             "Method for estimating efficacy probabilities",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    selectInput("boin_obd",
                      label = div("OBD Selection",
                        bsButton("help_obd", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Max Efficacy" = "max.effprob",
                                 "Utility Weighted" = "utility.weighted",
                                 "Utility Truncated Linear" = "utility.truncated.linear",
                                 "Utility Scoring" = "utility.scoring"),
                      selected = "max.effprob"),
                    bsPopover("help_obd", "OBD Selection Method",
                             "Method for optimal biological dose selection",
                             placement = "top", trigger = "hover")
                  )
                ),

                # Conditional panels for utility methods
                conditionalPanel(
                  condition = "input.boin_obd == 'utility.weighted'",
                  div(class = "two-column",
                    div(
                      numericInput("boin_w1",
                        label = div("Weight w1",
                          bsButton("help_w1", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.33, min = 0, max = 2, step = 0.01),
                      bsPopover("help_w1", "Utility Weight w1",
                               "Weight for toxicity-efficacy trade-off in utility.weighted method",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("boin_w2",
                        label = div("Weight w2",
                          bsButton("help_w2", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 1.09, min = 0, max = 5, step = 0.01),
                      bsPopover("help_w2", "Utility Weight w2",
                               "Penalty weight for toxic doses in utility.weighted method",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.boin_obd == 'utility.truncated.linear'",
                  div(class = "two-column",
                    div(
                      numericInput("boin_plowast",
                        label = div("Lower Tox Threshold",
                          bsButton("boin_help_plowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.03, min = 0, max = 1, step = 0.01),
                      bsPopover("boin_help_plowast", "Lower Toxicity Threshold",
                               "Lower toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("boin_puppast",
                        label = div("Upper Tox Threshold",
                          bsButton("boin_help_puppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.42, min = 0, max = 1, step = 0.01),
                      bsPopover("boin_help_puppast", "Upper Toxicity Threshold",
                               "Upper toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("boin_qlowast",
                        label = div("Lower Eff Threshold",
                          bsButton("boin_help_qlowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.18, min = 0, max = 1, step = 0.01),
                      bsPopover("boin_help_qlowast", "Lower Efficacy Threshold",
                               "Lower efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("boin_quppast",
                        label = div("Upper Eff Threshold",
                          bsButton("boin_help_quppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.6, min = 0, max = 1, step = 0.01),
                      bsPopover("boin_help_quppast", "Upper Efficacy Threshold",
                               "Upper efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.boin_obd == 'utility.scoring'",
                  div(class = "two-column",
                    div(
                      numericInput("boin_psi00",
                        label = div("Score (T=no, E=no)",
                          bsButton("boin_help_psi00", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 40, min = 0, max = 100),
                      bsPopover("boin_help_psi00", "Utility Score",
                               "Score for no toxicity, no efficacy",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("boin_psi11",
                        label = div("Score (T=yes, E=yes)",
                          bsButton("boin_help_psi11", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 60, min = 0, max = 100),
                      bsPopover("boin_help_psi11", "Utility Score",
                               "Score for toxicity present, efficacy present",
                               placement = "top", trigger = "hover")
                    )
                  )
                )
              )
            ),

            # Simulation Settings Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Simulation Settings",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure the Monte Carlo simulation parameters."),
                div(class = "two-column",
                  div(
                    numericInput("boin_nsim",
                      label = div("Number of Simulations",
                        bsButton("help_nsim", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 1000, min = 10, max = 10000),
                    bsPopover("help_nsim", "Number of Simulations",
                             "Number of simulated trials (higher values provide more stable results but take longer to run)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("boin_seed",
                      label = div("Random Seed",
                        bsButton("help_seed", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 100, min = 1, max = 10000),
                    bsPopover("help_seed", "Random Seed",
                             "Random seed for reproducible results (same seed will produce same results)",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            br(),
            actionButton("run_boinet", "Run BOIN-ET Simulation",
                        class = "btn-primary",
                        style = "width: 100%; height: 45px; font-size: 16px;"),
            br(), br(),
            div(id = "boin_error_div", textOutput("boin_error"), class = "error-message")
          ),

          box(
            width = 6,
            title = "True Probability Specification",
            status = "info",
            solidHeader = TRUE,
            h5("Toxicity Probabilities"),
            p(em("Specify the true toxicity probability for each dose level:")),
            rHandsontableOutput("boin_tox_table"),
            br(),
            h5("Efficacy Probabilities"),
            p(em("Specify the true efficacy probability for each dose level:")),
            rHandsontableOutput("boin_eff_table")
          )
        ),

        fluidRow(
          box(
            width = 12,
            title = "Simulation Results",
            status = "success",
            solidHeader = TRUE,
            tabsetPanel(
              tabPanel("Operating Characteristics", plotlyOutput("boin_combined_plot", height = "450px")),
              tabPanel("Summary Table", DT::dataTableOutput("boin_summary_table")),
              tabPanel("Overview", verbatimTextOutput("boin_oc_summary"))
            )
          )
        )
      ),

      # TITE-BOIN-ET Tab
      tabItem(
        tabName = "titeboinet",
        h2("TITE-BOIN-ET Design Simulation"),

        fluidRow(
          box(
            width = 6,
            title = "Simulation Parameters",
            status = "primary",
            solidHeader = TRUE,

            # Basic Trial Design Section
            div(class = "param-section expanded",
              div(class = "param-section-header",
                "Basic Trial Design",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure the fundamental trial structure and patient enrollment parameters."),
                div(class = "two-column",
                  div(
                    numericInput("tite_ndose",
                      label = div("Number of Doses",
                        bsButton("tite_help_ndose", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 6, min = 2, max = 10),
                    bsPopover("tite_help_ndose", "Number of Doses",
                             "Total number of dose levels to investigate in the trial (typically 3-6 doses)",
                             placement = "top", trigger = "hover"),

                    numericInput("tite_startdose",
                      label = div("Starting Dose",
                        bsButton("tite_help_startdose", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 1, min = 1, max = 10),
                    bsPopover("tite_help_startdose", "Starting Dose",
                             "Starting dose level (1 = lowest dose, recommended for safety)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_cohortsize",
                      label = div("Cohort Size",
                        bsButton("tite_help_cohortsize", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 3, min = 1, max = 10),
                    bsPopover("tite_help_cohortsize", "Cohort Size",
                             "Number of patients per cohort (commonly 3 or 6 patients)",
                             placement = "top", trigger = "hover"),

                    numericInput("tite_ncohort",
                      label = div("Number of Cohorts",
                        bsButton("tite_help_ncohort", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 12, min = 1, max = 50),
                    bsPopover("tite_help_ncohort", "Number of Cohorts",
                             "Maximum number of cohorts (total patients = cohort size × number of cohorts)",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Target Toxicity and Efficacy Probability Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Target Toxicity and Efficacy Probability",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set the acceptable toxicity and desired efficacy probabilities."),
                div(class = "two-column",
                  div(
                    h5("Toxicity Parameters"),
                    numericInput("tite_phi",
                      label = div("Target Toxicity",
                        bsButton("tite_help_phi", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.3, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("tite_help_phi", "Target Toxicity (φ)",
                             "Target toxicity probability - maximum acceptable toxicity rate (e.g., 0.3 = 30%)",
                             placement = "top", trigger = "hover"),

                    numericInput("tite_phi1",
                      label = div("Lower Toxicity",
                        bsButton("tite_help_phi1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.03, min = 0.001, max = 0.5, step = 0.01),
                    bsPopover("tite_help_phi1", "Lower Toxicity Boundary (φ1)",
                             "Lower toxicity boundary - doses with toxicity ≤ this are considered under-dosed",
                             placement = "top", trigger = "hover"),

                    numericInput("tite_phi2",
                      label = div("Upper Toxicity",
                        bsButton("tite_help_phi2", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.42, min = 0.1, max = 0.99, step = 0.01),
                    bsPopover("tite_help_phi2", "Upper Toxicity Boundary (φ2)",
                             "Upper toxicity boundary - doses with toxicity ≥ this trigger de-escalation",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    h5("Efficacy Parameters"),
                    numericInput("tite_delta",
                      label = div("Target Efficacy",
                        bsButton("tite_help_delta", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.6, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("tite_help_delta", "Target Efficacy (δ)",
                             "Target efficacy probability - desired minimum efficacy rate (e.g., 0.6 = 60%)",
                             placement = "top", trigger = "hover"),

                    numericInput("tite_delta1",
                      label = div("Min Efficacy",
                        bsButton("tite_help_delta1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.36, min = 0.01, max = 0.99, step = 0.01),
                    bsPopover("tite_help_delta1", "Minimum Efficacy (δ1)",
                             "Minimum efficacy threshold - doses with efficacy < this considered sub-therapeutic",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Assessment Window & Accrual Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Assessment Window & Accrual",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Define the time windows for outcome assessment and patient enrollment rate."),
                div(class = "three-column",
                  div(
                    numericInput("tite_tauT",
                      label = div("Tox Assessment",
                        bsButton("tite_help_tauT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 30, min = 1, max = 365),
                    bsPopover("tite_help_tauT", "Toxicity Assessment Window",
                             "Days to assess toxicity outcomes (TITE design uses partial data from pending patients)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_tauE",
                      label = div("Eff Assessment",
                        bsButton("tite_help_tauE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 45, min = 1, max = 365),
                    bsPopover("tite_help_tauE", "Efficacy Assessment Window",
                             "Days to assess efficacy outcomes (TITE design allows continuous enrollment)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_accrual",
                      label = div("Accrual Rate",
                        bsButton("tite_help_accrual", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 10, min = 1, max = 100),
                    bsPopover("tite_help_accrual", "Accrual Rate",
                             "Average days between patient enrollments (critical for TITE design efficiency)",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Data Generation Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Data Generation",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure statistical models for generating time-to-event data and correlations."),
                div(class = "three-column",
                  div(
                    selectInput("tite_geneventtime",
                      label = div("Event Time Distribution",
                        bsButton("tite_help_eventtime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Weibull" = "weibull", "Uniform" = "uniform"),
                      selected = "weibull"),
                    bsPopover("tite_help_eventtime", "Event Time Distribution",
                             "Distribution for generating time-to-event outcomes",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    selectInput("tite_genenrolltime",
                      label = div("Enrollment Distribution",
                        bsButton("tite_help_enrolltime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Uniform" = "uniform", "Exponential" = "exponential"),
                      selected = "uniform"),
                    bsPopover("tite_help_enrolltime", "Enrollment Distribution",
                             "Distribution for patient enrollment times",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_tecorr",
                      label = div("Tox-Eff Correlation",
                        bsButton("tite_help_tecorr", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.2, min = -1, max = 1, step = 0.1),
                    bsPopover("tite_help_tecorr", "Toxicity-Efficacy Correlation",
                             "Correlation between toxicity and efficacy",
                             placement = "top", trigger = "hover")
                  )
                ),
                div(class = "two-column",
                  div(
                    numericInput("tite_alphaT1",
                      label = div("Late Tox Prob",
                        bsButton("tite_help_alphaT1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("tite_help_alphaT1", "Late Toxicity Probability",
                             "Probability that toxicity occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_alphaE1",
                      label = div("Late Eff Prob",
                        bsButton("tite_help_alphaE1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("tite_help_alphaE1", "Late Efficacy Probability",
                             "Probability that efficacy occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Study Stopping Rules Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Study Stopping Rules",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set criteria for early study termination based on safety and futility."),
                div(class = "three-column",
                  div(
                    numericInput("tite_stoppingnpts",
                      label = div("Max Patients/Dose",
                        bsButton("tite_help_stoppingnpts", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 36, min = 1, max = 500),
                    bsPopover("tite_help_stoppingnpts", "Maximum Patients per Dose",
                             "Maximum number of patients per dose for early study termination",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_stoppingprobT",
                      label = div("Stop Prob for Tox",
                        bsButton("tite_help_stopprobT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.95, min = 0.5, max = 1, step = 0.01),
                    bsPopover("tite_help_stopprobT", "Stop Probability for Toxicity",
                             "Early termination threshold for toxicity",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_stoppingprobE",
                      label = div("Stop Prob for Eff",
                        bsButton("tite_help_stopprobE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.99, min = 0.5, max = 1, step = 0.01),
                    bsPopover("tite_help_stopprobE", "Stop Probability for Efficacy",
                             "Early termination threshold for efficacy",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # OBD Selection Method Section
            div(class = "param-section",
              div(class = "param-section-header",
                "OBD Selection Method",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Choose methods for estimating efficacy and selecting the optimal biological dose."),
                div(class = "two-column",
                  div(
                    selectInput("tite_estpt",
                      label = div("Efficacy Estimation",
                        bsButton("tite_help_estpt", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Observed Probabilities" = "obs.prob",
                                 "Fractional Polynomial" = "fp.logistic",
                                 "Multiple Isotonic" = "multi.iso"),
                      selected = "obs.prob"),
                    bsPopover("tite_help_estpt", "Efficacy Estimation Method",
                             "Method for estimating efficacy probabilities",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    selectInput("tite_obd",
                      label = div("OBD Selection",
                        bsButton("tite_help_obd", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Max Efficacy" = "max.effprob",
                                 "Utility Weighted" = "utility.weighted",
                                 "Utility Truncated Linear" = "utility.truncated.linear",
                                 "Utility Scoring" = "utility.scoring"),
                      selected = "max.effprob"),
                    bsPopover("tite_help_obd", "OBD Selection Method",
                             "Method for optimal biological dose selection",
                             placement = "top", trigger = "hover")
                  )
                ),

                # Conditional panels for utility methods
                conditionalPanel(
                  condition = "input.tite_obd == 'utility.weighted'",
                  div(class = "two-column",
                    div(
                      numericInput("tite_w1",
                        label = div("Weight w1",
                          bsButton("tite_help_w1", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.33, min = 0, max = 2, step = 0.01),
                      bsPopover("tite_help_w1", "Utility Weight w1",
                               "Weight for toxicity-efficacy trade-off",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("tite_w2",
                        label = div("Weight w2",
                          bsButton("tite_help_w2", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 1.09, min = 0, max = 5, step = 0.01),
                      bsPopover("tite_help_w2", "Utility Weight w2",
                               "Penalty weight for toxic doses",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.tite_obd == 'utility.truncated.linear'",
                  div(class = "two-column",
                    div(
                      numericInput("tite_plowast",
                        label = div("Lower Tox Threshold",
                          bsButton("tite_help_plowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.03, min = 0, max = 1, step = 0.01),
                      bsPopover("tite_help_plowast", "Lower Toxicity Threshold",
                               "Lower toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("tite_puppast",
                        label = div("Upper Tox Threshold",
                          bsButton("tite_help_puppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.42, min = 0, max = 1, step = 0.01),
                      bsPopover("tite_help_puppast", "Upper Toxicity Threshold",
                               "Upper toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("tite_qlowast",
                        label = div("Lower Eff Threshold",
                          bsButton("tite_help_qlowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.18, min = 0, max = 1, step = 0.01),
                      bsPopover("tite_help_qlowast", "Lower Efficacy Threshold",
                               "Lower efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("tite_quppast",
                        label = div("Upper Eff Threshold",
                          bsButton("tite_help_quppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.6, min = 0, max = 1, step = 0.01),
                      bsPopover("tite_help_quppast", "Upper Efficacy Threshold",
                               "Upper efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.tite_obd == 'utility.scoring'",
                  div(class = "two-column",
                    div(
                      numericInput("tite_psi00",
                        label = div("Score (T=no, E=no)",
                          bsButton("tite_help_psi00", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 40, min = 0, max = 100),
                      bsPopover("tite_help_psi00", "Utility Score",
                               "Score for no toxicity, no efficacy",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("tite_psi11",
                        label = div("Score (T=yes, E=yes)",
                          bsButton("tite_help_psi11", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 60, min = 0, max = 100),
                      bsPopover("tite_help_psi11", "Utility Score",
                               "Score for toxicity present, efficacy present",
                               placement = "top", trigger = "hover")
                    )
                  )
                )
              )
            ),

            # Simulation Settings Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Simulation Settings",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure the Monte Carlo simulation parameters."),
                div(class = "two-column",
                  div(
                    numericInput("tite_nsim",
                      label = div("Number of Simulations",
                        bsButton("tite_help_nsim", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 1000, min = 10, max = 10000),
                    bsPopover("tite_help_nsim", "Number of Simulations",
                             "Number of simulated trials",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("tite_seed",
                      label = div("Random Seed",
                        bsButton("tite_help_seed", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 100, min = 1, max = 10000),
                    bsPopover("tite_help_seed", "Random Seed",
                             "Random seed for reproducible results",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            br(),
            actionButton("run_titeboinet", "Run TITE-BOIN-ET Simulation",
                        class = "btn-primary",
                        style = "width: 100%; height: 45px; font-size: 16px;"),
            br(), br(),
            div(id = "tite_error_div", textOutput("tite_error"), class = "error-message")
          ),

          box(
            width = 6,
            title = "True Probability Specification",
            status = "info",
            solidHeader = TRUE,
            h5("Toxicity Probabilities"),
            p(em("Specify the true toxicity probability for each dose level:")),
            rHandsontableOutput("tite_tox_table"),
            br(),
            h5("Efficacy Probabilities"),
            p(em("Specify the true efficacy probability for each dose level:")),
            rHandsontableOutput("tite_eff_table")
          )
        ),

        fluidRow(
          box(
            width = 12,
            title = "Simulation Results",
            status = "success",
            solidHeader = TRUE,
            tabsetPanel(
              tabPanel("Operating Characteristics", plotlyOutput("tite_combined_plot", height = "450px")),
              tabPanel("Summary Table", DT::dataTableOutput("tite_summary_table")),
              tabPanel("Overview", verbatimTextOutput("tite_oc_summary"))
            )
          )
        )
      ),

      # gBOIN-ET Tab
      tabItem(
        tabName = "gboinet",
        h2("gBOIN-ET Design Simulation"),

        fluidRow(
          box(
            width = 4,
            title = "Simulation Parameters",
            status = "primary",
            solidHeader = TRUE,

            # Basic Trial Design Section
            div(class = "param-section expanded",
              div(class = "param-section-header",
                "Basic Trial Design",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure the trial structure including ordinal outcome categories."),
                div(class = "two-column",
                  div(
                    numericInput("gboin_ndose",
                      label = div("Number of Doses",
                        bsButton("gboin_help_ndose", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 6, min = 2, max = 10),
                    bsPopover("gboin_help_ndose", "Number of Doses",
                             "Total number of dose levels to investigate",
                             placement = "top", trigger = "hover"),

                    numericInput("gboin_ntoxcat",
                      label = div("Tox Categories",
                        bsButton("gboin_help_ntoxcat", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 4, min = 2, max = 6),
                    bsPopover("gboin_help_ntoxcat", "Toxicity Categories",
                             "Number of ordinal toxicity categories (e.g., None, Mild, Moderate, Severe)",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("gboin_cohortsize",
                      label = div("Cohort Size",
                        bsButton("gboin_help_cohortsize", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 3, min = 1, max = 10),
                    bsPopover("gboin_help_cohortsize", "Cohort Size",
                             "Number of patients per cohort",
                             placement = "top", trigger = "hover"),

                    numericInput("gboin_neffcat",
                      label = div("Eff Categories",
                        bsButton("gboin_help_neffcat", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 3, min = 2, max = 6),
                    bsPopover("gboin_help_neffcat", "Efficacy Categories",
                             "Number of ordinal efficacy categories (e.g., PD, SD, PR, CR)",
                             placement = "top", trigger = "hover")
                  )
                ),
                numericInput("gboin_ncohort",
                  label = div("Number of Cohorts",
                    bsButton("gboin_help_ncohort", "", icon = icon("question-circle"),
                            style = "info", size = "extra-small", class = "help-icon")),
                  value = 12, min = 1, max = 50),
                bsPopover("gboin_help_ncohort", "Number of Cohorts",
                         "Maximum number of cohorts",
                         placement = "top", trigger = "hover")
              )
            ),

            # Target Probabilities Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Target Toxicity and Efficacy Probability",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set target normalized equivalent toxicity/efficacy scores (nETS/nEES)."),
                div(class = "two-column",
                  div(
                    h5("Toxicity Targets"),
                    numericInput("gboin_phi",
                      label = div("Target nETS",
                        bsButton("gboin_help_phi", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.3, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("gboin_help_phi", "Target nETS",
                             "Target normalized equivalent toxicity score",
                             placement = "top", trigger = "hover"),

                    numericInput("gboin_phi1",
                      label = div("Lower nETS",
                        bsButton("gboin_help_phi1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.03, min = 0.001, max = 0.5, step = 0.01),
                    bsPopover("gboin_help_phi1", "Lower nETS Boundary",
                             "Lower boundary for normalized equivalent toxicity score",
                             placement = "top", trigger = "hover"),

                    numericInput("gboin_phi2",
                      label = div("Upper nETS",
                        bsButton("gboin_help_phi2", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.42, min = 0.1, max = 0.99, step = 0.01),
                    bsPopover("gboin_help_phi2", "Upper nETS Boundary",
                             "Upper boundary for normalized equivalent toxicity score",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    h5("Efficacy Targets"),
                    numericInput("gboin_delta",
                      label = div("Target nEES",
                        bsButton("gboin_help_delta", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.4, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("gboin_help_delta", "Target nEES",
                             "Target normalized equivalent efficacy score",
                             placement = "top", trigger = "hover"),

                    numericInput("gboin_delta1",
                      label = div("Min nEES",
                        bsButton("gboin_help_delta1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.24, min = 0.01, max = 0.99, step = 0.01),
                    bsPopover("gboin_help_delta1", "Minimum nEES",
                             "Minimum normalized equivalent efficacy score",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Assessment Window & Accrual Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Assessment Window & Accrual",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Define the time windows for outcome assessment and patient enrollment rate."),
                div(class = "two-column",
                  div(
                    numericInput("gboin_tauT",
                      label = div("Tox Assessment",
                        bsButton("gboin_help_tauT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 30, min = 1, max = 365),
                    bsPopover("gboin_help_tauT", "Toxicity Assessment Window",
                             "Days to assess toxicity outcomes",
                             placement = "top", trigger = "hover"),

                    numericInput("gboin_tauE",
                      label = div("Eff Assessment",
                        bsButton("gboin_help_tauE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 45, min = 1, max = 365),
                    bsPopover("gboin_help_tauE", "Efficacy Assessment Window",
                             "Days to assess efficacy outcomes",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("gboin_accrual",
                      label = div("Accrual Rate",
                        bsButton("gboin_help_accrual", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 10, min = 1, max = 100),
                    bsPopover("gboin_help_accrual", "Accrual Rate",
                             "Average days between patient enrollments",
                             placement = "top", trigger = "hover"),

                    numericInput("gboin_tecorr",
                      label = div("Tox-Eff Correlation",
                        bsButton("gboin_help_tecorr", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.2, min = -1, max = 1, step = 0.1),
                    bsPopover("gboin_help_tecorr", "Toxicity-Efficacy Correlation",
                             "Correlation between toxicity and efficacy",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Data Generation Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Data Generation",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure statistical models for generating outcome data and correlations."),
                div(class = "two-column",
                  div(
                    selectInput("gboin_geneventtime",
                      label = div("Event Time Distribution",
                        bsButton("gboin_help_eventtime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Weibull" = "weibull", "Uniform" = "uniform"),
                      selected = "weibull"),
                    bsPopover("gboin_help_eventtime", "Event Time Distribution",
                             "Distribution for generating time-to-event outcomes",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    selectInput("gboin_genenrolltime",
                      label = div("Enrollment Distribution",
                        bsButton("gboin_help_enrolltime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Uniform" = "uniform", "Exponential" = "exponential"),
                      selected = "uniform"),
                    bsPopover("gboin_help_enrolltime", "Enrollment Distribution",
                             "Distribution for patient enrollment times",
                             placement = "top", trigger = "hover")
                  )
                ),
                div(class = "two-column",
                  div(
                    numericInput("gboin_alphaT1",
                      label = div("Late Tox Prob",
                        bsButton("gboin_help_alphaT1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("gboin_help_alphaT1", "Late Toxicity Probability",
                             "Probability that toxicity occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("gboin_alphaE1",
                      label = div("Late Eff Prob",
                        bsButton("gboin_help_alphaE1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("gboin_help_alphaE1", "Late Efficacy Probability",
                             "Probability that efficacy occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Study Stopping Rules Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Study Stopping Rules",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set criteria for early study termination based on safety and futility."),
                div(class = "three-column",
                  div(
                    numericInput("gboin_stoppingnpts",
                      label = div("Max Patients/Dose",
                        bsButton("gboin_help_stoppingnpts", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 36, min = 1, max = 500),
                    bsPopover("gboin_help_stoppingnpts", "Maximum Patients per Dose",
                             "Maximum number of patients per dose for early study termination",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("gboin_stoppingprobT",
                      label = div("Stop Prob for Tox",
                        bsButton("gboin_help_stopprobT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.95, min = 0.5, max = 1, step = 0.01),
                    bsPopover("gboin_help_stopprobT", "Stop Probability for Toxicity",
                             "Early termination threshold for toxicity",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("gboin_stoppingprobE",
                      label = div("Stop Prob for Eff",
                        bsButton("gboin_help_stopprobE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.99, min = 0.5, max = 1, step = 0.01),
                    bsPopover("gboin_help_stopprobE", "Stop Probability for Efficacy",
                             "Early termination threshold for efficacy",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # OBD Selection Method Section
            div(class = "param-section",
              div(class = "param-section-header",
                "OBD Selection Method",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Choose methods for estimating efficacy and selecting the optimal biological dose."),
                selectInput("gboin_estpt",
                  label = div("Efficacy Estimation",
                    bsButton("gboin_help_estpt", "", icon = icon("question-circle"),
                            style = "info", size = "extra-small", class = "help-icon")),
                  choices = c("Observed Probabilities" = "obs.prob",
                             "Fractional Polynomial" = "fp.logistic"),
                  selected = "obs.prob"),
                bsPopover("gboin_help_estpt", "Efficacy Estimation Method",
                         "Method for estimating efficacy probabilities",
                         placement = "top", trigger = "hover"),

                selectInput("gboin_obd",
                  label = div("OBD Selection",
                    bsButton("gboin_help_obd", "", icon = icon("question-circle"),
                            style = "info", size = "extra-small", class = "help-icon")),
                  choices = c("Max Efficacy" = "max.effprob",
                             "Utility Weighted" = "utility.weighted",
                             "Utility Truncated Linear" = "utility.truncated.linear",
                             "Utility Scoring" = "utility.scoring"),
                  selected = "max.effprob"),
                bsPopover("gboin_help_obd", "OBD Selection Method",
                         "Method for optimal biological dose selection",
                         placement = "top", trigger = "hover"),

                conditionalPanel(
                  condition = "input.gboin_obd == 'utility.weighted'",
                  div(class = "two-column",
                    div(
                      numericInput("gboin_w1",
                        label = div("Weight w1",
                          bsButton("gboin_help_w1", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.33, min = 0, max = 2, step = 0.01),
                      bsPopover("gboin_help_w1", "Utility Weight w1",
                               "Weight for toxicity-efficacy trade-off",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("gboin_w2",
                        label = div("Weight w2",
                          bsButton("gboin_help_w2", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 1.09, min = 0, max = 5, step = 0.01),
                      bsPopover("gboin_help_w2", "Utility Weight w2",
                               "Penalty weight for toxic doses",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.gboin_obd == 'utility.truncated.linear'",
                  div(class = "two-column",
                    div(
                      numericInput("gboin_plowast",
                        label = div("Lower Tox Threshold",
                          bsButton("gboin_help_plowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.03, min = 0, max = 1, step = 0.01),
                      bsPopover("gboin_help_plowast", "Lower Toxicity Threshold",
                               "Lower toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("gboin_puppast",
                        label = div("Upper Tox Threshold",
                          bsButton("gboin_help_puppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.42, min = 0, max = 1, step = 0.01),
                      bsPopover("gboin_help_puppast", "Upper Toxicity Threshold",
                               "Upper toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("gboin_qlowast",
                        label = div("Lower Eff Threshold",
                          bsButton("gboin_help_qlowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.18, min = 0, max = 1, step = 0.01),
                      bsPopover("gboin_help_qlowast", "Lower Efficacy Threshold",
                               "Lower efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("gboin_quppast",
                        label = div("Upper Eff Threshold",
                          bsButton("gboin_help_quppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.4, min = 0, max = 1, step = 0.01),
                      bsPopover("gboin_help_quppast", "Upper Efficacy Threshold",
                               "Upper efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.gboin_obd == 'utility.scoring'",
                  div(class = "two-column",
                    div(
                      numericInput("gboin_psi00",
                        label = div("Score (T=no, E=no)",
                          bsButton("gboin_help_psi00", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 40, min = 0, max = 100),
                      bsPopover("gboin_help_psi00", "Utility Score",
                               "Score for no toxicity, no efficacy",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("gboin_psi11",
                        label = div("Score (T=yes, E=yes)",
                          bsButton("gboin_help_psi11", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 60, min = 0, max = 100),
                      bsPopover("gboin_help_psi11", "Utility Score",
                               "Score for toxicity present, efficacy present",
                               placement = "top", trigger = "hover")
                    )
                  )
                )
              )
            ),

            # Simulation Settings Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Simulation Settings",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "two-column",
                  div(
                    numericInput("gboin_nsim",
                      label = div("Simulations",
                        bsButton("gboin_help_nsim", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 1000, min = 10, max = 10000),
                    bsPopover("gboin_help_nsim", "Number of Simulations",
                             "Number of simulated trials",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("gboin_seed",
                      label = div("Seed",
                        bsButton("gboin_help_seed", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 100, min = 1, max = 10000),
                    bsPopover("gboin_help_seed", "Random Seed",
                             "Random seed for reproducible results",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            br(),
            actionButton("run_gboinet", "Run gBOIN-ET Simulation",
                        class = "btn-primary",
                        style = "width: 100%; height: 45px; font-size: 16px;"),
            br(), br(),
            div(id = "gboin_error_div", textOutput("gboin_error"), class = "error-message")
          ),

          box(
            width = 8,
            title = "Probability and Weight Specification",
            status = "info",
            solidHeader = TRUE,

            div(class = "two-column",
              div(
                h5("Toxicity Weights"),
                p(em("Higher weights = more severe toxicity")),
                rHandsontableOutput("gboin_toxweight_table", height = "120px"),
                br(),
                h5("Toxicity Probabilities"),
                p(em("Rows = categories, Columns = doses (each column must sum to 1)")),
                rHandsontableOutput("gboin_tox_table", height = "180px")
              ),
              div(
                h5("Efficacy Weights"),
                p(em("Higher weights = better response")),
                rHandsontableOutput("gboin_effweight_table", height = "120px"),
                br(),
                h5("Efficacy Probabilities"),
                p(em("Rows = categories, Columns = doses (each column must sum to 1)")),
                rHandsontableOutput("gboin_eff_table", height = "180px")
              )
            )
          )
        ),

        fluidRow(
          box(
            width = 12,
            title = "Simulation Results",
            status = "success",
            solidHeader = TRUE,
            tabsetPanel(
              tabPanel("Operating Characteristics", plotlyOutput("gboin_combined_plot", height = "450px")),
              tabPanel("Toxicity Category Distribution", plotlyOutput("gboin_tox_grade_plot", height = "400px")),
              tabPanel("Efficacy Category Distribution", plotlyOutput("gboin_eff_grade_plot", height = "400px")),
              tabPanel("Summary Table", DT::dataTableOutput("gboin_summary_table")),
              tabPanel("Overview", verbatimTextOutput("gboin_oc_summary"))
            )
          )
        )
      ),

      # TITE-gBOIN-ET Tab
      tabItem(
        tabName = "titegboinet",
        h2("TITE-gBOIN-ET Design Simulation"),

        fluidRow(
          box(
            width = 4,
            title = "Simulation Parameters",
            status = "primary",
            solidHeader = TRUE,

            # Basic Trial Design Section
            div(class = "param-section expanded",
              div(class = "param-section-header",
                "Basic Trial Design",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure the trial structure including ordinal outcome categories and time-to-event features."),
                div(class = "two-column",
                  div(
                    numericInput("titeg_ndose",
                      label = div("Number of Doses",
                        bsButton("titeg_help_ndose", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 6, min = 2, max = 10),
                    bsPopover("titeg_help_ndose", "Number of Doses",
                             "Total number of dose levels to investigate",
                             placement = "top", trigger = "hover"),

                    numericInput("titeg_ntoxcat",
                      label = div("Tox Categories",
                        bsButton("titeg_help_ntoxcat", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 4, min = 2, max = 6),
                    bsPopover("titeg_help_ntoxcat", "Toxicity Categories",
                             "Number of ordinal toxicity categories",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_cohortsize",
                      label = div("Cohort Size",
                        bsButton("titeg_help_cohortsize", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 3, min = 1, max = 10),
                    bsPopover("titeg_help_cohortsize", "Cohort Size",
                             "Number of patients per cohort",
                             placement = "top", trigger = "hover"),

                    numericInput("titeg_neffcat",
                      label = div("Eff Categories",
                        bsButton("titeg_help_neffcat", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 3, min = 2, max = 6),
                    bsPopover("titeg_help_neffcat", "Efficacy Categories",
                             "Number of ordinal efficacy categories",
                             placement = "top", trigger = "hover")
                  )
                ),
                numericInput("titeg_ncohort",
                  label = div("Number of Cohorts",
                    bsButton("titeg_help_ncohort", "", icon = icon("question-circle"),
                            style = "info", size = "extra-small", class = "help-icon")),
                  value = 12, min = 1, max = 50),
                bsPopover("titeg_help_ncohort", "Number of Cohorts",
                         "Maximum number of cohorts",
                         placement = "top", trigger = "hover")
              )
            ),

            # Target Probabilities Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Target Toxicity and Efficacy Probability",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set target normalized equivalent toxicity/efficacy scores (nETS/nEES)."),
                div(class = "two-column",
                  div(
                    h5("Toxicity Targets"),
                    numericInput("titeg_phi",
                      label = div("Target nETS",
                        bsButton("titeg_help_phi", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.3, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("titeg_help_phi", "Target nETS",
                             "Target normalized equivalent toxicity score",
                             placement = "top", trigger = "hover"),

                    numericInput("titeg_phi1",
                      label = div("Lower nETS",
                        bsButton("titeg_help_phi1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.03, min = 0.001, max = 0.5, step = 0.01),
                    bsPopover("titeg_help_phi1", "Lower nETS Boundary",
                             "Lower boundary for normalized equivalent toxicity score",
                             placement = "top", trigger = "hover"),

                    numericInput("titeg_phi2",
                      label = div("Upper nETS",
                        bsButton("titeg_help_phi2", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.42, min = 0.1, max = 0.99, step = 0.01),
                    bsPopover("titeg_help_phi2", "Upper nETS Boundary",
                             "Upper boundary for normalized equivalent toxicity score",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    h5("Efficacy Targets"),
                    numericInput("titeg_delta",
                      label = div("Target nEES",
                        bsButton("titeg_help_delta", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.4, min = 0.01, max = 0.99, step = 0.05),
                    bsPopover("titeg_help_delta", "Target nEES",
                             "Target normalized equivalent efficacy score",
                             placement = "top", trigger = "hover"),

                    numericInput("titeg_delta1",
                      label = div("Min nEES",
                        bsButton("titeg_help_delta1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.24, min = 0.01, max = 0.99, step = 0.01),
                    bsPopover("titeg_help_delta1", "Minimum nEES",
                             "Minimum normalized equivalent efficacy score",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Assessment Window & Accrual Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Assessment Window & Accrual",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Define time windows and accrual for time-to-event ordinal design."),
                div(class = "three-column",
                  div(
                    numericInput("titeg_tauT",
                      label = div("Tox Window",
                        bsButton("titeg_help_tauT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 30, min = 1, max = 365),
                    bsPopover("titeg_help_tauT", "Toxicity Assessment Window",
                             "Days to assess toxicity outcomes",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_tauE",
                      label = div("Eff Window",
                        bsButton("titeg_help_tauE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 45, min = 1, max = 365),
                    bsPopover("titeg_help_tauE", "Efficacy Assessment Window",
                             "Days to assess efficacy outcomes",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_accrual",
                      label = div("Accrual Rate",
                        bsButton("titeg_help_accrual", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 10, min = 1, max = 100),
                    bsPopover("titeg_help_accrual", "Accrual Rate",
                             "Average days between patient enrollments",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Data Generation Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Data Generation",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Configure statistical models for time-to-event ordinal data generation."),
                div(class = "two-column",
                  div(
                    selectInput("titeg_geneventtime",
                      label = div("Event Time Distribution",
                        bsButton("titeg_help_eventtime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Weibull" = "weibull", "Uniform" = "uniform"),
                      selected = "weibull"),
                    bsPopover("titeg_help_eventtime", "Event Time Distribution",
                             "Distribution for generating time-to-event outcomes",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    selectInput("titeg_genenrolltime",
                      label = div("Enrollment Distribution",
                        bsButton("titeg_help_enrolltime", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      choices = c("Uniform" = "uniform", "Exponential" = "exponential"),
                      selected = "uniform"),
                    bsPopover("titeg_help_enrolltime", "Enrollment Distribution",
                             "Distribution for patient enrollment times",
                             placement = "top", trigger = "hover")
                  )
                ),
                div(class = "three-column",
                  div(
                    numericInput("titeg_alphaT1",
                      label = div("Late Tox Prob",
                        bsButton("titeg_help_alphaT1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("titeg_help_alphaT1", "Late Toxicity Probability",
                             "Probability that toxicity occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_alphaE1",
                      label = div("Late Eff Prob",
                        bsButton("titeg_help_alphaE1", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.5, min = 0, max = 1, step = 0.1),
                    bsPopover("titeg_help_alphaE1", "Late Efficacy Probability",
                             "Probability that efficacy occurs in late half of assessment window",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_tecorr",
                      label = div("Tox-Eff Correlation",
                        bsButton("titeg_help_tecorr", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.2, min = -1, max = 1, step = 0.1),
                    bsPopover("titeg_help_tecorr", "Toxicity-Efficacy Correlation",
                             "Correlation between toxicity and efficacy",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # Study Stopping Rules Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Study Stopping Rules",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Set criteria for early study termination based on safety and futility."),
                div(class = "three-column",
                  div(
                    numericInput("titeg_stoppingnpts",
                      label = div("Max Patients/Dose",
                        bsButton("titeg_help_stoppingnpts", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 36, min = 1, max = 500),
                    bsPopover("titeg_help_stoppingnpts", "Maximum Patients per Dose",
                             "Maximum number of patients per dose for early study termination",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_stoppingprobT",
                      label = div("Stop Prob for Tox",
                        bsButton("titeg_help_stopprobT", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.95, min = 0.5, max = 1, step = 0.01),
                    bsPopover("titeg_help_stopprobT", "Stop Probability for Toxicity",
                             "Early termination threshold for toxicity",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_stoppingprobE",
                      label = div("Stop Prob for Eff",
                        bsButton("titeg_help_stopprobE", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 0.99, min = 0.5, max = 1, step = 0.01),
                    bsPopover("titeg_help_stopprobE", "Stop Probability for Efficacy",
                             "Early termination threshold for efficacy",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            # OBD Selection Method Section
            div(class = "param-section",
              div(class = "param-section-header",
                "OBD Selection Method",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "section-description",
                    "Choose methods for estimating efficacy and selecting the optimal biological dose."),
                selectInput("titeg_estpt",
                  label = div("Efficacy Estimation",
                    bsButton("titeg_help_estpt", "", icon = icon("question-circle"),
                            style = "info", size = "extra-small", class = "help-icon")),
                  choices = c("Observed Probabilities" = "obs.prob",
                             "Fractional Polynomial" = "fp.logistic"),
                  selected = "obs.prob"),
                bsPopover("titeg_help_estpt", "Efficacy Estimation Method",
                         "Method for estimating efficacy probabilities",
                         placement = "top", trigger = "hover"),

                selectInput("titeg_obd",
                  label = div("OBD Selection",
                    bsButton("titeg_help_obd", "", icon = icon("question-circle"),
                            style = "info", size = "extra-small", class = "help-icon")),
                  choices = c("Max Efficacy" = "max.effprob",
                             "Utility Weighted" = "utility.weighted",
                             "Utility Truncated Linear" = "utility.truncated.linear",
                             "Utility Scoring" = "utility.scoring"),
                  selected = "max.effprob"),
                bsPopover("titeg_help_obd", "OBD Selection Method",
                         "Method for optimal biological dose selection",
                         placement = "top", trigger = "hover"),

                conditionalPanel(
                  condition = "input.titeg_obd == 'utility.weighted'",
                  div(class = "two-column",
                    div(
                      numericInput("titeg_w1",
                        label = div("Weight w1",
                          bsButton("titeg_help_w1", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.33, min = 0, max = 2, step = 0.01),
                      bsPopover("titeg_help_w1", "Utility Weight w1",
                               "Weight for toxicity-efficacy trade-off",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("titeg_w2",
                        label = div("Weight w2",
                          bsButton("titeg_help_w2", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 1.09, min = 0, max = 5, step = 0.01),
                      bsPopover("titeg_help_w2", "Utility Weight w2",
                               "Penalty weight for toxic doses",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.titeg_obd == 'utility.truncated.linear'",
                  div(class = "two-column",
                    div(
                      numericInput("titeg_plowast",
                        label = div("Lower Tox Threshold",
                          bsButton("titeg_help_plowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.03, min = 0, max = 1, step = 0.01),
                      bsPopover("titeg_help_plowast", "Lower Toxicity Threshold",
                               "Lower toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("titeg_puppast",
                        label = div("Upper Tox Threshold",
                          bsButton("titeg_help_puppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.42, min = 0, max = 1, step = 0.01),
                      bsPopover("titeg_help_puppast", "Upper Toxicity Threshold",
                               "Upper toxicity threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("titeg_qlowast",
                        label = div("Lower Eff Threshold",
                          bsButton("titeg_help_qlowast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.18, min = 0, max = 1, step = 0.01),
                      bsPopover("titeg_help_qlowast", "Lower Efficacy Threshold",
                               "Lower efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover"),

                      numericInput("titeg_quppast",
                        label = div("Upper Eff Threshold",
                          bsButton("titeg_help_quppast", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 0.4, min = 0, max = 1, step = 0.01),
                      bsPopover("titeg_help_quppast", "Upper Efficacy Threshold",
                               "Upper efficacy threshold for truncated linear method",
                               placement = "top", trigger = "hover")
                    )
                  )
                ),
                conditionalPanel(
                  condition = "input.titeg_obd == 'utility.scoring'",
                  div(class = "two-column",
                    div(
                      numericInput("titeg_psi00",
                        label = div("Score (T=no, E=no)",
                          bsButton("titeg_help_psi00", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 40, min = 0, max = 100),
                      bsPopover("titeg_help_psi00", "Utility Score",
                               "Score for no toxicity, no efficacy",
                               placement = "top", trigger = "hover")
                    ),
                    div(
                      numericInput("titeg_psi11",
                        label = div("Score (T=yes, E=yes)",
                          bsButton("titeg_help_psi11", "", icon = icon("question-circle"),
                                  style = "info", size = "extra-small", class = "help-icon")),
                        value = 60, min = 0, max = 100),
                      bsPopover("titeg_help_psi11", "Utility Score",
                               "Score for toxicity present, efficacy present",
                               placement = "top", trigger = "hover")
                    )
                  )
                )
              )
            ),

            # Simulation Settings Section
            div(class = "param-section",
              div(class = "param-section-header",
                "Simulation Settings",
                icon("chevron-down", class = "fa fa-chevron-down")
              ),
              div(class = "param-section-content",
                div(class = "two-column",
                  div(
                    numericInput("titeg_nsim",
                      label = div("Simulations",
                        bsButton("titeg_help_nsim", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 1000, min = 10, max = 10000),
                    bsPopover("titeg_help_nsim", "Number of Simulations",
                             "Number of simulated trials",
                             placement = "top", trigger = "hover")
                  ),
                  div(
                    numericInput("titeg_seed",
                      label = div("Seed",
                        bsButton("titeg_help_seed", "", icon = icon("question-circle"),
                                style = "info", size = "extra-small", class = "help-icon")),
                      value = 100, min = 1, max = 10000),
                    bsPopover("titeg_help_seed", "Random Seed",
                             "Random seed for reproducible results",
                             placement = "top", trigger = "hover")
                  )
                )
              )
            ),

            br(),
            actionButton("run_titegboinet", "Run TITE-gBOIN-ET Simulation",
                        class = "btn-primary",
                        style = "width: 100%; height: 45px; font-size: 16px;"),
            br(), br(),
            div(id = "titeg_error_div", textOutput("titeg_error"), class = "error-message")
          ),

          box(
            width = 8,
            title = "Probability and Weight Specification",
            status = "info",
            solidHeader = TRUE,

            div(class = "two-column",
              div(
                h5("Toxicity Weights"),
                p(em("Higher weights = more severe toxicity")),
                rHandsontableOutput("titeg_toxweight_table", height = "120px"),
                br(),
                h5("Toxicity Probabilities"),
                p(em("Rows = categories, Columns = doses (each column must sum to 1)")),
                rHandsontableOutput("titeg_tox_table", height = "180px")
              ),
              div(
                h5("Efficacy Weights"),
                p(em("Higher weights = better response")),
                rHandsontableOutput("titeg_effweight_table", height = "120px"),
                br(),
                h5("Efficacy Probabilities"),
                p(em("Rows = categories, Columns = doses (each column must sum to 1)")),
                rHandsontableOutput("titeg_eff_table", height = "180px")
              )
            )
          )
        ),

        fluidRow(
          box(
            width = 12,
            title = "Simulation Results",
            status = "success",
            solidHeader = TRUE,
            tabsetPanel(
              tabPanel("Operating Characteristics", plotlyOutput("titeg_combined_plot", height = "450px")),
              tabPanel("Toxicity Category Distribution", plotlyOutput("titeg_tox_grade_plot", height = "400px")),
              tabPanel("Efficacy Category Distribution", plotlyOutput("titeg_eff_grade_plot", height = "400px")),
              tabPanel("Summary Table", DT::dataTableOutput("titeg_summary_table")),
              tabPanel("Overview", verbatimTextOutput("titeg_oc_summary"))
            )
          )
        )
      )
    )
  )
)

# Server logic
server <- function(input, output, session) {

  estimate_simulation_time <- function(n_sim, n_dose, cohort_size, n_cohort) {
    base_time <- 0.05  # seconds per simulation
    complexity_factor <- (n_dose * cohort_size * n_cohort) / 100
    return(n_sim * base_time * (1 + complexity_factor))
  }

  # Auto-update dependent parameters for BOIN-ET
  observe({
    updateNumericInput(session, "boin_phi1", value = round(input$boin_phi * 0.1, 3))
    updateNumericInput(session, "boin_phi2", value = round(input$boin_phi * 1.4, 3))
  })

  observe({
    updateNumericInput(session, "boin_delta1", value = round(input$boin_delta * 0.6, 3))
  })

  observe({
    updateNumericInput(session, "boin_stoppingnpts", value = input$boin_cohortsize * input$boin_ncohort)
  })

  # Auto-update dependent parameters for TITE-BOIN-ET
  observe({
    updateNumericInput(session, "tite_phi1", value = round(input$tite_phi * 0.1, 3))
    updateNumericInput(session, "tite_phi2", value = round(input$tite_phi * 1.4, 3))
  })

  observe({
    updateNumericInput(session, "tite_delta1", value = round(input$tite_delta * 0.6, 3))
  })

  observe({
    updateNumericInput(session, "tite_stoppingnpts", value = input$tite_cohortsize * input$tite_ncohort)
  })

  # Auto-update dependent parameters for gBOIN-ET
  observe({
    updateNumericInput(session, "gboin_phi1", value = round(input$gboin_phi * 0.1, 3))
    updateNumericInput(session, "gboin_phi2", value = round(input$gboin_phi * 1.4, 3))
  })

  observe({
    updateNumericInput(session, "gboin_delta1", value = round(input$gboin_delta * 0.6, 3))
  })

  observe({
    updateNumericInput(session, "gboin_stoppingnpts", value = input$gboin_cohortsize * input$gboin_ncohort)
  })

  # Auto-update dependent parameters for TITE-gBOIN-ET
  observe({
    updateNumericInput(session, "titeg_phi1", value = round(input$titeg_phi * 0.1, 3))
    updateNumericInput(session, "titeg_phi2", value = round(input$titeg_phi * 1.4, 3))
  })

  observe({
    updateNumericInput(session, "titeg_delta1", value = round(input$titeg_delta * 0.6, 3))
  })

  observe({
    updateNumericInput(session, "titeg_stoppingnpts", value = input$titeg_cohortsize * input$titeg_ncohort)
  })

  # Helper functions
  validate_matrix_sums <- function(matrix_data, tolerance = 0.001) {
    if(is.null(matrix_data)) return("Matrix data is missing")
    col_sums <- colSums(matrix_data, na.rm = TRUE)
    if(any(abs(col_sums - 1) > tolerance)) {
      return("Each column in the probability matrix must sum to 1.0")
    }
    return(NULL)
  }

  safe_hot_to_r <- function(hot_table) {
    if(is.null(hot_table)) return(NULL)
    tryCatch({
      hot_to_r(hot_table)
    }, error = function(e) {
      NULL
    })
  }

  # BOIN-ET tables
  output$boin_tox_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$boin_ndose))
    default_tox <- c(0.01, 0.03, 0.06, 0.12, 0.18, 0.30, rep(0.15, 10))[1:n_doses]

    df <- data.frame(matrix(default_tox, nrow = 1))
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- "Probability"

    rhandsontable(df, rowHeaders = TRUE, width = "100%", height = "80px") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  output$boin_eff_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$boin_ndose))
    default_eff <- c(0.06, 0.08, 0.15, 0.25, 0.40, 0.80, rep(0.50, 10))[1:n_doses]

    df <- data.frame(matrix(default_eff, nrow = 1))
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- "Probability"

    rhandsontable(df, rowHeaders = TRUE, width = "100%", height = "80px") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  # TITE-BOIN-ET tables
  output$tite_tox_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$tite_ndose))
    default_tox <- c(0.01, 0.03, 0.06, 0.12, 0.18, 0.30, rep(0.15, 10))[1:n_doses]

    df <- data.frame(matrix(default_tox, nrow = 1))
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- "Probability"

    rhandsontable(df, rowHeaders = TRUE, width = "100%", height = "80px") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  output$tite_eff_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$tite_ndose))
    default_eff <- c(0.06, 0.08, 0.15, 0.25, 0.40, 0.80, rep(0.50, 10))[1:n_doses]

    df <- data.frame(matrix(default_eff, nrow = 1))
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- "Probability"

    rhandsontable(df, rowHeaders = TRUE, width = "100%", height = "80px") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  # gBOIN-ET tables
  output$gboin_toxweight_table <- renderRHandsontable({
    n_cat <- max(2, min(6, input$gboin_ntoxcat))
    default_weights <- c(0, 0.5, 0.8, 1, 1.5, 2)[1:n_cat]

    df <- data.frame(Weight = default_weights)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1, type = "numeric", format = "0.00") %>%
      hot_validate_numeric(col = 1, min = 0)
  })

  output$gboin_effweight_table <- renderRHandsontable({
    n_cat <- max(2, min(6, input$gboin_neffcat))
    default_weights <- c(0, 0.5, 1, 2, 3, 4)[1:n_cat]

    df <- data.frame(Weight = default_weights)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1, type = "numeric", format = "0.00") %>%
      hot_validate_numeric(col = 1, min = 0)
  })

  output$gboin_tox_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$gboin_ndose))
    n_cat <- max(2, min(6, input$gboin_ntoxcat))

    if(n_cat == 4) {
      default_matrix <- rbind(
        c(0.80, 0.75, 0.60, 0.50, 0.30, 0.20),
        c(0.15, 0.20, 0.25, 0.30, 0.40, 0.30),
        c(0.04, 0.04, 0.10, 0.15, 0.20, 0.30),
        c(0.01, 0.01, 0.05, 0.05, 0.10, 0.20)
      )[, 1:n_doses, drop = FALSE]
    } else {
      default_matrix <- matrix(1/n_cat, nrow = n_cat, ncol = n_doses)
    }

    for(j in 1:ncol(default_matrix)) {
      default_matrix[, j] <- default_matrix[, j] / sum(default_matrix[, j])
    }

    df <- as.data.frame(default_matrix)
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  output$gboin_eff_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$gboin_ndose))
    n_cat <- max(2, min(6, input$gboin_neffcat))

    if(n_cat == 3) {
      default_matrix <- rbind(
        c(0.90, 0.85, 0.70, 0.45, 0.30, 0.15),
        c(0.08, 0.10, 0.15, 0.25, 0.35, 0.45),
        c(0.02, 0.05, 0.15, 0.30, 0.35, 0.40)
      )[, 1:n_doses, drop = FALSE]
    } else {
      default_matrix <- matrix(1/n_cat, nrow = n_cat, ncol = n_doses)
    }

    for(j in 1:ncol(default_matrix)) {
      default_matrix[, j] <- default_matrix[, j] / sum(default_matrix[, j])
    }

    df <- as.data.frame(default_matrix)
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  # TITE-gBOIN-ET tables (same as gBOIN-ET)
  output$titeg_toxweight_table <- renderRHandsontable({
    n_cat <- max(2, min(6, input$titeg_ntoxcat))
    default_weights <- c(0, 0.5, 0.8, 1, 1.5, 2)[1:n_cat]

    df <- data.frame(Weight = default_weights)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1, type = "numeric", format = "0.00") %>%
      hot_validate_numeric(col = 1, min = 0)
  })

  output$titeg_effweight_table <- renderRHandsontable({
    n_cat <- max(2, min(6, input$titeg_neffcat))
    default_weights <- c(0, 0.5, 1, 2, 3, 4)[1:n_cat]

    df <- data.frame(Weight = default_weights)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1, type = "numeric", format = "0.00") %>%
      hot_validate_numeric(col = 1, min = 0)
  })

  output$titeg_tox_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$titeg_ndose))
    n_cat <- max(2, min(6, input$titeg_ntoxcat))

    if(n_cat == 4) {
      default_matrix <- rbind(
        c(0.80, 0.75, 0.60, 0.50, 0.30, 0.20),
        c(0.15, 0.20, 0.25, 0.30, 0.40, 0.30),
        c(0.04, 0.04, 0.10, 0.15, 0.20, 0.30),
        c(0.01, 0.01, 0.05, 0.05, 0.10, 0.20)
      )[, 1:n_doses, drop = FALSE]
    } else {
      default_matrix <- matrix(1/n_cat, nrow = n_cat, ncol = n_doses)
    }

    for(j in 1:ncol(default_matrix)) {
      default_matrix[, j] <- default_matrix[, j] / sum(default_matrix[, j])
    }

    df <- as.data.frame(default_matrix)
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  output$titeg_eff_table <- renderRHandsontable({
    n_doses <- max(2, min(10, input$titeg_ndose))
    n_cat <- max(2, min(6, input$titeg_neffcat))

    if(n_cat == 3) {
      default_matrix <- rbind(
        c(0.90, 0.85, 0.70, 0.45, 0.30, 0.15),
        c(0.08, 0.10, 0.15, 0.25, 0.35, 0.45),
        c(0.02, 0.05, 0.15, 0.30, 0.35, 0.40)
      )[, 1:n_doses, drop = FALSE]
    } else {
      default_matrix <- matrix(1/n_cat, nrow = n_cat, ncol = n_doses)
    }

    for(j in 1:ncol(default_matrix)) {
      default_matrix[, j] <- default_matrix[, j] / sum(default_matrix[, j])
    }

    df <- as.data.frame(default_matrix)
    colnames(df) <- paste("Dose", 1:n_doses)
    rownames(df) <- paste("Category", 1:n_cat)

    rhandsontable(df, rowHeaders = TRUE, width = "100%") %>%
      hot_col(col = 1:n_doses, type = "numeric", format = "0.000") %>%
      hot_validate_numeric(col = 1:n_doses, min = 0, max = 1)
  })

  # BOIN-ET Simulation
boinet_results <- eventReactive(input$run_boinet, {
  output$boin_error <- renderText("")

  withProgress(message = 'Running BOIN-ET simulation...', value = 0, {

    # Phase 1: Validation (15%)
    incProgress(0.05, detail = "Validating input parameters...")

    tox_data <- safe_hot_to_r(input$boin_tox_table)
    eff_data <- safe_hot_to_r(input$boin_eff_table)

    if(is.null(tox_data) || is.null(eff_data)) {
      output$boin_error <- renderText("Error: Unable to read probability tables.")
      return(NULL)
    }

    toxprob <- as.numeric(tox_data[1,])
    effprob <- as.numeric(eff_data[1,])

    if(any(is.na(toxprob)) || any(is.na(effprob))) {
      output$boin_error <- renderText("Error: Probabilities cannot contain missing values.")
      return(NULL)
    }

    incProgress(0.10, detail = "Input validation complete")

    # Phase 2: Configuration (15%)
    incProgress(0.05, detail = "Configuring simulation parameters...")

    # Build arguments list for boinet function call - UNCHANGED
    args_list <- list(
      n.dose = input$boin_ndose,
      start.dose = input$boin_startdose,
      size.cohort = input$boin_cohortsize,
      n.cohort = input$boin_ncohort,
      toxprob = toxprob,
      effprob = effprob,
      phi = input$boin_phi,
      phi1 = input$boin_phi1,
      phi2 = input$boin_phi2,
      delta = input$boin_delta,
      delta1 = input$boin_delta1,
      alpha.T1 = input$boin_alphaT1,
      alpha.E1 = input$boin_alphaE1,
      tau.T = input$boin_tauT,
      tau.E = input$boin_tauE,
      te.corr = input$boin_tecorr,
      gen.event.time = input$boin_geneventtime,
      accrual = input$boin_accrual,
      gen.enroll.time = input$boin_genenrolltime,
      stopping.npts = input$boin_stoppingnpts,
      stopping.prob.T = input$boin_stoppingprobT,
      stopping.prob.E = input$boin_stoppingprobE,
      estpt.method = input$boin_estpt,
      obd.method = input$boin_obd,
      n.sim = input$boin_nsim,
      seed.sim = input$boin_seed
    )

    # Add utility-specific parameters if needed - UNCHANGED
    if(input$boin_obd == "utility.weighted") {
      args_list$w1 <- input$boin_w1
      args_list$w2 <- input$boin_w2
    } else if(input$boin_obd == "utility.truncated.linear") {
      args_list$plow.ast <- input$boin_plowast
      args_list$pupp.ast <- input$boin_puppast
      args_list$qlow.ast <- input$boin_qlowast
      args_list$qupp.ast <- input$boin_quppast
    } else if(input$boin_obd == "utility.scoring") {
      args_list$psi00 <- input$boin_psi00
      args_list$psi11 <- input$boin_psi11
    }

    # Display estimated time (for user information only)
    estimated_time <- estimate_simulation_time(
      input$boin_nsim, input$boin_ndose,
      input$boin_cohortsize, input$boin_ncohort
    )

    incProgress(0.10, detail = paste("Setup complete - estimated time:", round(estimated_time, 1), "seconds"))

    # Phase 3: Simulation (60%) - EXACT SAME SIMULATION CALL AS ORIGINAL
    incProgress(0.10, detail = paste("Running", input$boin_nsim, "BOIN-ET simulations..."))

    result <- tryCatch({
      # IDENTICAL simulation call - no changes to simulation logic
      do.call(boinet, args_list)
    }, error = function(e) {
      output$boin_error <- renderText(paste("Error:", e$message))
      return(NULL)
    })

    # Phase 4: Completion (10%)
    incProgress(0.50, detail = "Simulation complete")
    incProgress(0.10, detail = "Processing results...")

    return(result)
  })
})

  # TITE-BOIN-ET Simulation
titeboinet_results <- eventReactive(input$run_titeboinet, {
  output$tite_error <- renderText("")

  withProgress(message = 'Running TITE-BOIN-ET simulation...', value = 0, {

    # Phase 1: Validation (15%)
    incProgress(0.05, detail = "Validating input parameters...")

    tox_data <- safe_hot_to_r(input$tite_tox_table)
    eff_data <- safe_hot_to_r(input$tite_eff_table)

    if(is.null(tox_data) || is.null(eff_data)) {
      output$tite_error <- renderText("Error: Unable to read probability tables.")
      return(NULL)
    }

    toxprob <- as.numeric(tox_data[1,])
    effprob <- as.numeric(eff_data[1,])

    if(any(is.na(toxprob)) || any(is.na(effprob))) {
      output$tite_error <- renderText("Error: Probabilities cannot contain missing values.")
      return(NULL)
    }

    incProgress(0.10, detail = "Input validation complete")

    # Phase 2: Configuration (15%)
    incProgress(0.05, detail = "Configuring TITE simulation parameters...")

    args_list <- list(
      n.dose = input$tite_ndose,
      start.dose = input$tite_startdose,
      size.cohort = input$tite_cohortsize,
      n.cohort = input$tite_ncohort,
      toxprob = toxprob,
      effprob = effprob,
      phi = input$tite_phi,
      phi1 = input$tite_phi1,
      phi2 = input$tite_phi2,
      delta = input$tite_delta,
      delta1 = input$tite_delta1,
      alpha.T1 = input$tite_alphaT1,
      alpha.E1 = input$tite_alphaE1,
      tau.T = input$tite_tauT,
      tau.E = input$tite_tauE,
      te.corr = input$tite_tecorr,
      gen.event.time = input$tite_geneventtime,
      accrual = input$tite_accrual,
      gen.enroll.time = input$tite_genenrolltime,
      stopping.npts = input$tite_stoppingnpts,
      stopping.prob.T = input$tite_stoppingprobT,
      stopping.prob.E = input$tite_stoppingprobE,
      estpt.method = input$tite_estpt,
      obd.method = input$tite_obd,
      n.sim = input$tite_nsim,
      seed.sim = input$tite_seed
    )

    if(input$tite_obd == "utility.weighted") {
      args_list$w1 <- input$tite_w1
      args_list$w2 <- input$tite_w2
    } else if(input$tite_obd == "utility.truncated.linear") {
      args_list$plow.ast <- input$tite_plowast
      args_list$pupp.ast <- input$tite_puppast
      args_list$qlow.ast <- input$tite_qlowast
      args_list$qupp.ast <- input$tite_quppast
    } else if(input$tite_obd == "utility.scoring") {
      args_list$psi00 <- input$tite_psi00
      args_list$psi11 <- input$tite_psi11
    }

    estimated_time <- estimate_simulation_time(
      input$tite_nsim, input$tite_ndose,
      input$tite_cohortsize, input$tite_ncohort
    )

    incProgress(0.10, detail = paste("Setup complete - estimated time:", round(estimated_time, 1), "seconds"))

    # Phase 3: Simulation (60%) - EXACT SAME SIMULATION CALL
    incProgress(0.10, detail = paste("Running", input$tite_nsim, "TITE-BOIN-ET simulations..."))

    result <- tryCatch({
      # IDENTICAL simulation call - no changes to simulation logic
      do.call(tite.boinet, args_list)
    }, error = function(e) {
      output$tite_error <- renderText(paste("Error:", e$message))
      return(NULL)
    })

    # Phase 4: Completion (10%)
    incProgress(0.50, detail = "TITE simulation complete")
    incProgress(0.10, detail = "Processing results...")

    return(result)
  })
})

  # gBOIN-ET Simulation
gboinet_results <- eventReactive(input$run_gboinet, {
  output$gboin_error <- renderText("")

  withProgress(message = 'Running gBOIN-ET simulation...', value = 0, {

    # Phase 1: Validation (20%)
    incProgress(0.05, detail = "Validating input parameters...")

    tox_data <- safe_hot_to_r(input$gboin_tox_table)
    eff_data <- safe_hot_to_r(input$gboin_eff_table)
    tox_weight_data <- safe_hot_to_r(input$gboin_toxweight_table)
    eff_weight_data <- safe_hot_to_r(input$gboin_effweight_table)

    if(is.null(tox_data) || is.null(eff_data) || is.null(tox_weight_data) || is.null(eff_weight_data)) {
      output$gboin_error <- renderText("Error: Unable to read all required tables.")
      return(NULL)
    }

    incProgress(0.05, detail = "Validating probability matrices...")

    toxprob <- as.matrix(tox_data)
    effprob <- as.matrix(eff_data)
    sev.weight <- as.numeric(tox_weight_data[,1])
    res.weight <- as.numeric(eff_weight_data[,1])

    matrix_error <- validate_matrix_sums(toxprob)
    if(!is.null(matrix_error)) {
      output$gboin_error <- renderText(paste("Toxicity matrix error:", matrix_error))
      return(NULL)
    }

    matrix_error <- validate_matrix_sums(effprob)
    if(!is.null(matrix_error)) {
      output$gboin_error <- renderText(paste("Efficacy matrix error:", matrix_error))
      return(NULL)
    }

    incProgress(0.10, detail = "Matrix validation complete")

    # Phase 2: Configuration (15%)
    incProgress(0.05, detail = "Configuring ordinal simulation parameters...")

    args_list <- list(
      n.dose = input$gboin_ndose,
      start.dose = 1,
      size.cohort = input$gboin_cohortsize,
      n.cohort = input$gboin_ncohort,
      toxprob = toxprob,
      effprob = effprob,
      sev.weight = sev.weight,
      res.weight = res.weight,
      phi = input$gboin_phi,
      phi1 = input$gboin_phi1,
      phi2 = input$gboin_phi2,
      delta = input$gboin_delta,
      delta1 = input$gboin_delta1,
      alpha.T1 = input$gboin_alphaT1,
      alpha.E1 = input$gboin_alphaE1,
      tau.T = input$gboin_tauT,
      tau.E = input$gboin_tauE,
      te.corr = input$gboin_tecorr,
      gen.event.time = input$gboin_geneventtime,
      accrual = input$gboin_accrual,
      gen.enroll.time = input$gboin_genenrolltime,
      stopping.npts = input$gboin_stoppingnpts,
      stopping.prob.T = input$gboin_stoppingprobT,
      stopping.prob.E = input$gboin_stoppingprobE,
      estpt.method = input$gboin_estpt,
      obd.method = input$gboin_obd,
      n.sim = input$gboin_nsim,
      seed.sim = input$gboin_seed
    )

    if(input$gboin_obd == "utility.weighted") {
      args_list$w1 <- input$gboin_w1
      args_list$w2 <- input$gboin_w2
    } else if(input$gboin_obd == "utility.truncated.linear") {
      args_list$plow.ast <- input$gboin_plowast
      args_list$pupp.ast <- input$gboin_puppast
      args_list$qlow.ast <- input$gboin_qlowast
      args_list$qupp.ast <- input$gboin_quppast
    } else if(input$gboin_obd == "utility.scoring") {
      args_list$psi00 <- input$gboin_psi00
      args_list$psi11 <- input$gboin_psi11
    }

    estimated_time <- estimate_simulation_time(
      input$gboin_nsim, input$gboin_ndose,
      input$gboin_cohortsize, input$gboin_ncohort
    ) * 1.5  # Ordinal simulations take longer

    incProgress(0.10, detail = paste("Setup complete - estimated time:", round(estimated_time, 1), "seconds"))

    # Phase 3: Simulation (55%) - EXACT SAME SIMULATION CALL
    incProgress(0.10, detail = paste("Running", input$gboin_nsim, "ordinal gBOIN-ET simulations..."))

    result <- tryCatch({
      # IDENTICAL simulation call - no changes to simulation logic
      do.call(gboinet, args_list)
    }, error = function(e) {
      output$gboin_error <- renderText(paste("Error:", e$message))
      return(NULL)
    })

    # Phase 4: Completion (10%)
    incProgress(0.45, detail = "Ordinal simulation complete")
    incProgress(0.10, detail = "Computing nETS and nEES scores...")

    return(result)
  })
})

  # TITE-gBOIN-ET Simulation
titegboinet_results <- eventReactive(input$run_titegboinet, {
  output$titeg_error <- renderText("")

  withProgress(message = 'Running TITE-gBOIN-ET simulation...', value = 0, {

    # Phase 1: Validation (20%)
    incProgress(0.05, detail = "Validating input parameters...")

    tox_data <- safe_hot_to_r(input$titeg_tox_table)
    eff_data <- safe_hot_to_r(input$titeg_eff_table)
    tox_weight_data <- safe_hot_to_r(input$titeg_toxweight_table)
    eff_weight_data <- safe_hot_to_r(input$titeg_effweight_table)

    if(is.null(tox_data) || is.null(eff_data) || is.null(tox_weight_data) || is.null(eff_weight_data)) {
      output$titeg_error <- renderText("Error: Unable to read all required tables.")
      return(NULL)
    }

    incProgress(0.05, detail = "Validating ordinal probability matrices...")

    toxprob <- as.matrix(tox_data)
    effprob <- as.matrix(eff_data)
    sev.weight <- as.numeric(tox_weight_data[,1])
    res.weight <- as.numeric(eff_weight_data[,1])

    matrix_error <- validate_matrix_sums(toxprob)
    if(!is.null(matrix_error)) {
      output$titeg_error <- renderText(paste("Toxicity matrix error:", matrix_error))
      return(NULL)
    }

    matrix_error <- validate_matrix_sums(effprob)
    if(!is.null(matrix_error)) {
      output$titeg_error <- renderText(paste("Efficacy matrix error:", matrix_error))
      return(NULL)
    }

    incProgress(0.10, detail = "Matrix validation complete")

    # Phase 2: Configuration (15%)
    incProgress(0.05, detail = "Configuring time-to-event ordinal parameters...")

    args_list <- list(
      n.dose = input$titeg_ndose,
      start.dose = 1,
      size.cohort = input$titeg_cohortsize,
      n.cohort = input$titeg_ncohort,
      toxprob = toxprob,
      effprob = effprob,
      sev.weight = sev.weight,
      res.weight = res.weight,
      phi = input$titeg_phi,
      phi1 = input$titeg_phi1,
      phi2 = input$titeg_phi2,
      delta = input$titeg_delta,
      delta1 = input$titeg_delta1,
      alpha.T1 = input$titeg_alphaT1,
      alpha.E1 = input$titeg_alphaE1,
      tau.T = input$titeg_tauT,
      tau.E = input$titeg_tauE,
      te.corr = input$titeg_tecorr,
      gen.event.time = input$titeg_geneventtime,
      accrual = input$titeg_accrual,
      gen.enroll.time = input$titeg_genenrolltime,
      stopping.npts = input$titeg_stoppingnpts,
      stopping.prob.T = input$titeg_stoppingprobT,
      stopping.prob.E = input$titeg_stoppingprobE,
      estpt.method = input$titeg_estpt,
      obd.method = input$titeg_obd,
      n.sim = input$titeg_nsim,
      seed.sim = input$titeg_seed
    )

    if(input$titeg_obd == "utility.weighted") {
      args_list$w1 <- input$titeg_w1
      args_list$w2 <- input$titeg_w2
    } else if(input$titeg_obd == "utility.truncated.linear") {
      args_list$plow.ast <- input$titeg_plowast
      args_list$pupp.ast <- input$titeg_puppast
      args_list$qlow.ast <- input$titeg_qlowast
      args_list$qupp.ast <- input$titeg_quppast
    } else if(input$titeg_obd == "utility.scoring") {
      args_list$psi00 <- input$titeg_psi00
      args_list$psi11 <- input$titeg_psi11
    }

    estimated_time <- estimate_simulation_time(
      input$titeg_nsim, input$titeg_ndose,
      input$titeg_cohortsize, input$titeg_ncohort
    ) * 2.0  # Most complex simulation

    incProgress(0.10, detail = paste("Setup complete - estimated time:", round(estimated_time, 1), "seconds"))

    # Phase 3: Simulation (55%) - EXACT SAME SIMULATION CALL
    incProgress(0.10, detail = paste("Running", input$titeg_nsim, "time-to-event ordinal simulations..."))

    result <- tryCatch({
      # IDENTICAL simulation call - no changes to simulation logic
      do.call(tite.gboinet, args_list)
    }, error = function(e) {
      output$titeg_error <- renderText(paste("Error:", e$message))
      return(NULL)
    })

    # Phase 4: Completion (10%)
    incProgress(0.45, detail = "Time-to-event ordinal simulation complete")
    incProgress(0.10, detail = "Computing nETS and nEES time-to-event scores...")

    return(result)
  })
})

  # Helper function for plots
  create_oc_plot <- function(result, title_prefix) {
    doses <- 1:length(result$prop.select)
    dose_labels <- paste("Dose", doses)

    fig <- plot_ly() %>%
      add_bars(
        x = dose_labels,
        y = result$prop.select,
        name = 'Selection Probability (%)',
        marker = list(
          color = '#3498DB',
          line = list(color = '#2980B9', width = 1.5),
          opacity = 0.8
        ),
        yaxis = 'y',
        hovertemplate = '<b>%{x}</b><br>Selection: %{y:.1f}%<extra></extra>'
      ) %>%
      add_trace(
        x = dose_labels,
        y = result$n.patient,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Avg # Patients',
        line = list(color = '#E74C3C', width = 4, shape = 'spline'),
        marker = list(
          color = '#E74C3C',
          size = 12,
          line = list(color = 'white', width = 3)
        ),
        yaxis = 'y2',
        hovertemplate = '<b>%{x}</b><br>Patients: %{y:.1f}<extra></extra>'
      ) %>%
      layout(
        title = list(
          text = paste('<b>', title_prefix, ': Operating Characteristics</b>'),
          font = list(size = 18, color = '#2C3E50', family = 'Arial Black'),
          x = 0.5,
          xanchor = 'center'
        ),
        xaxis = list(
          title = list(text = '<b>Dose Level</b>', font = list(size = 14, color = '#34495E')),
          tickfont = list(size = 12, color = '#2C3E50'),
          showgrid = FALSE,
          showline = TRUE,
          linecolor = '#95A5A6',
          linewidth = 2
        ),
        yaxis = list(
          title = list(text = '<b>Selection Probability (%)</b>', font = list(size = 14, color = '#3498DB')),
          tickfont = list(size = 12, color = '#2C3E50'),
          range = c(0, max(100, max(result$prop.select) * 1.1)),
          gridcolor = '#ECF0F1',
          gridwidth = 1,
          showline = TRUE,
          linecolor = '#95A5A6',
          linewidth = 2
        ),
        yaxis2 = list(
          title = list(text = '<b>Avg # Patients</b>', font = list(size = 14, color = '#E74C3C')),
          tickfont = list(size = 12, color = '#2C3E50'),
          overlaying = 'y',
          side = 'right',
          range = c(0, max(result$n.patient) * 1.2),
          showgrid = FALSE,
          showline = TRUE,
          linecolor = '#95A5A6',
          linewidth = 2
        ),
        legend = list(
          x = 0.02,
          y = 0.98,
          bgcolor = 'rgba(255,255,255,0.95)',
          bordercolor = '#BDC3C7',
          borderwidth = 2,
          font = list(size = 12, color = '#2C3E50'),
          orientation = 'v'
        ),
        plot_bgcolor = '#F8F9FA',
        paper_bgcolor = 'white',
        margin = list(l = 80, r = 80, t = 100, b = 70),
        annotations = list(
          list(
            text = paste(
              '<span style="color:#E67E22;">No OBD: <b>', result$prop.stop, '%</b></span><br>',
              '<span style="color:#27AE60;">Duration: <b>', result$duration, ' days</b></span>'
            ),
            x = 0.02,
            y = 0.75,
            xref = 'paper',
            yref = 'paper',
            xanchor = 'left',
            yanchor = 'top',
            showarrow = FALSE,
            font = list(size = 13),
            bgcolor = 'rgba(255,255,255,0.95)',
            bordercolor = '#BDC3C7',
            borderwidth = 2,
            borderpad = 12
          )
        )
      ) %>%
      config(displayModeBar = TRUE, responsive = TRUE)

    fig
  }

  # All plot outputs
  output$boin_combined_plot <- renderPlotly({
    req(boinet_results())
    result <- boinet_results()
    if(is.null(result)) return(plot_ly())
    create_oc_plot(result, "BOIN-ET")
  })

  output$tite_combined_plot <- renderPlotly({
    req(titeboinet_results())
    result <- titeboinet_results()
    if(is.null(result)) return(plot_ly())
    create_oc_plot(result, "TITE-BOIN-ET")
  })

  output$gboin_combined_plot <- renderPlotly({
    req(gboinet_results())
    result <- gboinet_results()
    if(is.null(result)) return(plot_ly())
    create_oc_plot(result, "gBOIN-ET")
  })

  output$titeg_combined_plot <- renderPlotly({
    req(titegboinet_results())
    result <- titegboinet_results()
    if(is.null(result)) return(plot_ly())
    create_oc_plot(result, "TITE-gBOIN-ET")
  })

  # Summary tables
  output$boin_summary_table <- DT::renderDataTable({
    req(boinet_results())
    result <- boinet_results()

    summary_df <- data.frame(
      Dose = 1:length(result$toxprob),
      `True Tox Prob` = result$toxprob,
      `True Eff Prob` = result$effprob,
      `Selection %` = result$prop.select,
      `Avg Patients` = result$n.patient,
      check.names = FALSE
    )

    DT::datatable(summary_df, options = list(pageLength = 10, dom = 'tip'), rownames = FALSE) %>%
      formatRound(c("True Tox Prob", "True Eff Prob", "Selection %", "Avg Patients"), 1)
  })

  output$tite_summary_table <- DT::renderDataTable({
    req(titeboinet_results())
    result <- titeboinet_results()

    summary_df <- data.frame(
      Dose = 1:length(result$toxprob),
      `True Tox Prob` = result$toxprob,
      `True Eff Prob` = result$effprob,
      `Selection %` = result$prop.select,
      `Avg Patients` = result$n.patient,
      check.names = FALSE
    )

    DT::datatable(summary_df, options = list(pageLength = 10, dom = 'tip'), rownames = FALSE) %>%
      formatRound(c("True Tox Prob", "True Eff Prob", "Selection %", "Avg Patients"), 1)
  })

  output$gboin_summary_table <- DT::renderDataTable({
    req(gboinet_results())
    result <- gboinet_results()

    summary_df <- data.frame(
      Dose = 1:input$gboin_ndose,
      `nETS` = result$nETS,
      `nEES` = result$nEES,
      `Selection %` = result$prop.select,
      `Avg Patients` = result$n.patient,
      check.names = FALSE
    )

    DT::datatable(summary_df, options = list(pageLength = 10, dom = 'tip'), rownames = FALSE) %>%
      formatRound(c("nETS", "nEES", "Selection %", "Avg Patients"), 2)
  })

  output$titeg_summary_table <- DT::renderDataTable({
    req(titegboinet_results())
    result <- titegboinet_results()

    summary_df <- data.frame(
      Dose = 1:input$titeg_ndose,
      `nETS` = result$nETS,
      `nEES` = result$nEES,
      `Selection %` = result$prop.select,
      `Avg Patients` = result$n.patient,
      check.names = FALSE
    )

    DT::datatable(summary_df, options = list(pageLength = 10, dom = 'tip'), rownames = FALSE) %>%
      formatRound(c("nETS", "nEES", "Selection %", "Avg Patients"), 2)
  })

  # Overview outputs
  output$boin_oc_summary <- renderPrint({
    req(boinet_results())
    result <- boinet_results()
    print(result)
  })

  output$tite_oc_summary <- renderPrint({
    req(titeboinet_results())
    result <- titeboinet_results()
    print(result)
  })

  output$gboin_oc_summary <- renderPrint({
    req(gboinet_results())
    result <- gboinet_results()
    print(result)
  })

  output$titeg_oc_summary <- renderPrint({
    req(titegboinet_results())
    result <- titegboinet_results()
    print(result)
  })

  # Grade distribution plots for ordinal designs
  output$gboin_tox_grade_plot <- renderPlotly({
    req(gboinet_results())

    tox_data <- safe_hot_to_r(input$gboin_tox_table)
    if(is.null(tox_data)) return(plot_ly())

    toxprob_matrix <- as.matrix(tox_data)
    doses <- paste("Dose", 1:input$gboin_ndose)

    # Professional color palette - gradient from green (low toxicity) to red (high toxicity)
    category_names <- paste("Category", 1:nrow(toxprob_matrix))
    colors <- c('#2ECC71', '#F39C12', '#E67E22', '#E74C3C', '#8E44AD', '#34495E')[1:nrow(toxprob_matrix)]

    fig <- plot_ly()

    for(i in 1:nrow(toxprob_matrix)) {
      fig <- fig %>% add_trace(
        x = doses,
        y = toxprob_matrix[i,] * 100,
        type = 'bar',
        name = category_names[i],
        marker = list(
          color = colors[i],
          line = list(color = '#FFFFFF', width = 1),
          opacity = 0.9
        ),
        hovertemplate = paste0(
          '<b>', category_names[i], '</b><br>',
          'Dose: %{x}<br>',
          'Probability: %{y:.1f}%<extra></extra>'
        )
      )
    }

    fig %>% layout(
      title = list(
        text = '<b>Toxicity Category Distribution by Dose Level</b>',
        font = list(size = 18, color = '#2C3E50', family = 'Arial Black'),
        x = 0.5,
        xanchor = 'center'
      ),
      xaxis = list(
        title = list(text = '<b>Dose Level</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        type = "category",
        showgrid = FALSE,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      yaxis = list(
        title = list(text = '<b>Probability (%)</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        range = c(0, 100),
        gridcolor = '#ECF0F1',
        gridwidth = 1,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      barmode = 'stack',
      legend = list(
        x = 1.02,
        y = 1,
        bgcolor = 'rgba(255,255,255,0.95)',
        bordercolor = '#BDC3C7',
        borderwidth = 2,
        font = list(size = 12, color = '#2C3E50'),
        orientation = 'v'
      ),
      plot_bgcolor = '#F8F9FA',
      paper_bgcolor = 'white',
      margin = list(l = 80, r = 120, t = 100, b = 70)
    ) %>%
    config(displayModeBar = TRUE, responsive = TRUE)
  })

  output$gboin_eff_grade_plot <- renderPlotly({
    req(gboinet_results())

    eff_data <- safe_hot_to_r(input$gboin_eff_table)
    if(is.null(eff_data)) return(plot_ly())

    effprob_matrix <- as.matrix(eff_data)
    doses <- paste("Dose", 1:input$gboin_ndose)

    # Professional color palette - gradient from red (poor response) to green (good response)
    category_names <- paste("Category", 1:nrow(effprob_matrix))
    colors <- c('#E74C3C', '#F39C12', '#F1C40F', '#2ECC71', '#3498DB', '#9B59B6')[1:nrow(effprob_matrix)]

    fig <- plot_ly()

    for(i in 1:nrow(effprob_matrix)) {
      fig <- fig %>% add_trace(
        x = doses,
        y = effprob_matrix[i,] * 100,
        type = 'bar',
        name = category_names[i],
        marker = list(
          color = colors[i],
          line = list(color = '#FFFFFF', width = 1),
          opacity = 0.9
        ),
        hovertemplate = paste0(
          '<b>', category_names[i], '</b><br>',
          'Dose: %{x}<br>',
          'Probability: %{y:.1f}%<extra></extra>'
        )
      )
    }

    fig %>% layout(
      title = list(
        text = '<b>Efficacy Category Distribution by Dose Level</b>',
        font = list(size = 18, color = '#2C3E50', family = 'Arial Black'),
        x = 0.5,
        xanchor = 'center'
      ),
      xaxis = list(
        title = list(text = '<b>Dose Level</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        type = "category",
        showgrid = FALSE,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      yaxis = list(
        title = list(text = '<b>Probability (%)</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        range = c(0, 100),
        gridcolor = '#ECF0F1',
        gridwidth = 1,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      barmode = 'stack',
      legend = list(
        x = 1.02,
        y = 1,
        bgcolor = 'rgba(255,255,255,0.95)',
        bordercolor = '#BDC3C7',
        borderwidth = 2,
        font = list(size = 12, color = '#2C3E50'),
        orientation = 'v'
      ),
      plot_bgcolor = '#F8F9FA',
      paper_bgcolor = 'white',
      margin = list(l = 80, r = 120, t = 100, b = 70)
    ) %>%
    config(displayModeBar = TRUE, responsive = TRUE)
  })

  output$titeg_tox_grade_plot <- renderPlotly({
    req(titegboinet_results())

    tox_data <- safe_hot_to_r(input$titeg_tox_table)
    if(is.null(tox_data)) return(plot_ly())

    toxprob_matrix <- as.matrix(tox_data)
    doses <- paste("Dose", 1:input$titeg_ndose)

    # Professional color palette - gradient from green (low toxicity) to red (high toxicity)
    category_names <- paste("Category", 1:nrow(toxprob_matrix))
    colors <- c('#2ECC71', '#F39C12', '#E67E22', '#E74C3C', '#8E44AD', '#34495E')[1:nrow(toxprob_matrix)]

    fig <- plot_ly()

    for(i in 1:nrow(toxprob_matrix)) {
      fig <- fig %>% add_trace(
        x = doses,
        y = toxprob_matrix[i,] * 100,
        type = 'bar',
        name = category_names[i],
        marker = list(
          color = colors[i],
          line = list(color = '#FFFFFF', width = 1),
          opacity = 0.9
        ),
        hovertemplate = paste0(
          '<b>', category_names[i], '</b><br>',
          'Dose: %{x}<br>',
          'Probability: %{y:.1f}%<extra></extra>'
        )
      )
    }

    fig %>% layout(
      title = list(
        text = '<b>Toxicity Category Distribution by Dose Level</b>',
        font = list(size = 18, color = '#2C3E50', family = 'Arial Black'),
        x = 0.5,
        xanchor = 'center'
      ),
      xaxis = list(
        title = list(text = '<b>Dose Level</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        type = "category",
        showgrid = FALSE,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      yaxis = list(
        title = list(text = '<b>Probability (%)</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        range = c(0, 100),
        gridcolor = '#ECF0F1',
        gridwidth = 1,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      barmode = 'stack',
      legend = list(
        x = 1.02,
        y = 1,
        bgcolor = 'rgba(255,255,255,0.95)',
        bordercolor = '#BDC3C7',
        borderwidth = 2,
        font = list(size = 12, color = '#2C3E50'),
        orientation = 'v'
      ),
      plot_bgcolor = '#F8F9FA',
      paper_bgcolor = 'white',
      margin = list(l = 80, r = 120, t = 100, b = 70)
    ) %>%
    config(displayModeBar = TRUE, responsive = TRUE)
  })

  output$titeg_eff_grade_plot <- renderPlotly({
    req(titegboinet_results())

    eff_data <- safe_hot_to_r(input$titeg_eff_table)
    if(is.null(eff_data)) return(plot_ly())

    effprob_matrix <- as.matrix(eff_data)
    doses <- paste("Dose", 1:input$titeg_ndose)

    # Professional color palette - gradient from red (poor response) to green (good response)
    category_names <- paste("Category", 1:nrow(effprob_matrix))
    colors <- c('#E74C3C', '#F39C12', '#F1C40F', '#2ECC71', '#3498DB', '#9B59B6')[1:nrow(effprob_matrix)]

    fig <- plot_ly()

    for(i in 1:nrow(effprob_matrix)) {
      fig <- fig %>% add_trace(
        x = doses,
        y = effprob_matrix[i,] * 100,
        type = 'bar',
        name = category_names[i],
        marker = list(
          color = colors[i],
          line = list(color = '#FFFFFF', width = 1),
          opacity = 0.9
        ),
        hovertemplate = paste0(
          '<b>', category_names[i], '</b><br>',
          'Dose: %{x}<br>',
          'Probability: %{y:.1f}%<extra></extra>'
        )
      )
    }

    fig %>% layout(
      title = list(
        text = '<b>Efficacy Category Distribution by Dose Level</b>',
        font = list(size = 18, color = '#2C3E50', family = 'Arial Black'),
        x = 0.5,
        xanchor = 'center'
      ),
      xaxis = list(
        title = list(text = '<b>Dose Level</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        type = "category",
        showgrid = FALSE,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      yaxis = list(
        title = list(text = '<b>Probability (%)</b>', font = list(size = 14, color = '#34495E')),
        tickfont = list(size = 12, color = '#2C3E50'),
        range = c(0, 100),
        gridcolor = '#ECF0F1',
        gridwidth = 1,
        showline = TRUE,
        linecolor = '#95A5A6',
        linewidth = 2
      ),
      barmode = 'stack',
      legend = list(
        x = 1.02,
        y = 1,
        bgcolor = 'rgba(255,255,255,0.95)',
        bordercolor = '#BDC3C7',
        borderwidth = 2,
        font = list(size = 12, color = '#2C3E50'),
        orientation = 'v'
      ),
      plot_bgcolor = '#F8F9FA',
      paper_bgcolor = 'white',
      margin = list(l = 80, r = 120, t = 100, b = 70)
    ) %>%
    config(displayModeBar = TRUE, responsive = TRUE)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
