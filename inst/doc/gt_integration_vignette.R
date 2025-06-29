## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6
)

# Check if gt is available
gt_available <- requireNamespace("gt", quietly = TRUE)

## ----setup--------------------------------------------------------------------
library(boinet)
library(dplyr)

# Only load gt if available
if (requireNamespace("gt", quietly = TRUE)) {
  library(gt)
}

## ----check_gt, echo=FALSE, results='asis'-------------------------------------
if (!gt_available) {
  cat("**Note:** The gt package is not installed. To use the table formatting features, install it with:\n\n")
  cat("```r\n")
  cat("install.packages('gt')\n")
  cat("```\n\n")
  cat("The code examples below will not run without gt installed.\n\n")
}

## ----mock_data----------------------------------------------------------------
# Create realistic mock data for demonstration
create_mock_result <- function(design_type = "tite.boinet") {
  result <- list(
    toxprob = c("50mg" = 0.02, "100mg" = 0.08, "200mg" = 0.15, "400mg" = 0.25, "800mg" = 0.40),
    effprob = c("50mg" = 0.10, "100mg" = 0.20, "200mg" = 0.35, "400mg" = 0.50, "800mg" = 0.65),
    n.patient = c("50mg" = 8.2, "100mg" = 12.5, "200mg" = 15.8, "400mg" = 10.3, "800mg" = 7.2),
    prop.select = c("50mg" = 5.2, "100mg" = 18.7, "200mg" = 42.1, "400mg" = 28.3, "800mg" = 5.7),
    phi = 0.30,
    delta = 0.60,
    lambda1 = 0.03,
    lambda2 = 0.42,
    eta1 = 0.36,
    duration = 156.3,
    prop.stop = 3.2,
    n.sim = 1000
  )
  
  if (design_type %in% c("tite.boinet", "tite.gboinet")) {
    result$tau.T <- 28
    result$tau.E <- 42
    result$accrual <- 7
  }
  
  class(result) <- design_type
  return(result)
}

# Create sample results
tite_result <- create_mock_result("tite.boinet")
gboinet_result <- create_mock_result("gboinet")

## ----helper_functions---------------------------------------------------------
# Helper function to create basic operating characteristics table
create_basic_oc_table <- function(result) {
  if (!gt_available) {
    cat("gt package not available. Install with: install.packages('gt')\n")
    return(NULL)
  }
  
  # Extract data from result object
  dose_levels <- names(result$n.patient)
  
  # Create data frame
  oc_data <- data.frame(
    `Dose Level` = dose_levels,
    `True Toxicity Probability` = round(as.numeric(result$toxprob), 3),
    `True Efficacy Probability` = round(as.numeric(result$effprob), 3),
    `Average N Treated` = round(as.numeric(result$n.patient), 1),
    `Selection Probability (%)` = round(as.numeric(result$prop.select), 1),
    check.names = FALSE
  )
  
  # Create gt table
  gt_table <- oc_data %>%
    gt() %>%
    tab_header(
      title = "Operating Characteristics",
      subtitle = "BOIN-ET Design Simulation Results"
    ) %>%
    fmt_number(
      columns = c("True Toxicity Probability", "True Efficacy Probability"),
      decimals = 3
    ) %>%
    fmt_number(
      columns = "Average N Treated",
      decimals = 1
    ) %>%
    fmt_number(
      columns = "Selection Probability (%)",
      decimals = 1
    ) %>%
    cols_align(
      align = "center",
      columns = everything()
    ) %>%
    cols_align(
      align = "left",
      columns = "Dose Level"
    )
  
  return(gt_table)
}

# Helper function to create design parameters table
create_design_parameters_table <- function(result) {
  if (!gt_available) {
    cat("gt package not available. Install with: install.packages('gt')\n")
    return(NULL)
  }
  
  # Extract design parameters
  design_params <- data.frame(
    Parameter = c("Target Toxicity Rate (φ)", "Target Efficacy Rate (δ)", 
                  "Lower Toxicity Boundary (λ₁)", "Upper Toxicity Boundary (λ₂)",
                  "Efficacy Boundary (η₁)", "Early Stop Rate (%)", 
                  "Average Duration (days)"),
    Value = c(result$phi, result$delta, result$lambda1, result$lambda2,
              result$eta1, result$prop.stop, result$duration),
    stringsAsFactors = FALSE
  )
  
  # Add time-specific parameters if available
  if (!is.null(result$tau.T)) {
    time_params <- data.frame(
      Parameter = c("Toxicity Assessment Window (days)", 
                    "Efficacy Assessment Window (days)",
                    "Accrual Rate (days)"),
      Value = c(result$tau.T, result$tau.E, result$accrual),
      stringsAsFactors = FALSE
    )
    design_params <- rbind(design_params, time_params)
  }
  
  # Create gt table
  gt_table <- design_params %>%
    gt() %>%
    tab_header(
      title = "Design Parameters",
      subtitle = paste("Based on", result$n.sim, "simulated trials")
    ) %>%
    fmt_number(
      columns = "Value",
      decimals = 3
    ) %>%
    cols_align(
      align = "left",
      columns = "Parameter"
    ) %>%
    cols_align(
      align = "center",
      columns = "Value"
    )
  
  return(gt_table)
}

## ----basic_oc_table, eval=gt_available----------------------------------------
# Create operating characteristics table
oc_table <- create_basic_oc_table(tite_result)
if (!is.null(oc_table)) {
  oc_table
}

## ----basic_design_table, eval=gt_available------------------------------------
# Create design parameters table
design_table <- create_design_parameters_table(tite_result)
if (!is.null(design_table)) {
  design_table
}

## ----custom_styling, eval=gt_available----------------------------------------
# Create table with custom styling
if (gt_available) {
  custom_oc_table <- create_basic_oc_table(tite_result) %>%
    # Update header with subtitle using tab_header
    tab_header(
      title = "Table 1: TITE-BOIN-ET Operating Characteristics for Drug XYZ-123",
      subtitle = "Phase I Dose-Finding Study"
    ) %>%
    # Add footnotes
    tab_footnote(
      footnote = "Based on 1,000 simulated trials",
      locations = cells_title(groups = "title")
    ) %>%
    tab_footnote(
      footnote = "Highlighted row indicates dose with highest selection probability",
      locations = cells_column_labels(columns = "Selection Probability (%)")
    ) %>%
    # Highlight optimal dose (row with highest selection probability)
    tab_style(
      style = cell_fill(color = "lightblue"),
      locations = cells_body(
        rows = `Selection Probability (%)` == max(`Selection Probability (%)`)
      )
    ) %>%
    # Add source note
    tab_source_note(
      source_note = "Generated using boinet package"
    ) %>%
    # Professional styling
    tab_style(
      style = list(
        cell_text(weight = "bold"),
        cell_borders(sides = "bottom", weight = px(2))
      ),
      locations = cells_column_labels()
    )
  
  custom_oc_table
}

## ----clinical_table, eval=gt_available----------------------------------------
# Create a table suitable for regulatory submission
if (gt_available) {
  regulatory_table <- create_basic_oc_table(tite_result) %>%
    # Professional styling
    tab_header(
      title = "Operating Characteristics Summary",
      subtitle = "Regulatory Submission Table"
    ) %>%
    tab_style(
      style = list(
        cell_text(weight = "bold"),
        cell_borders(sides = "bottom", weight = px(2))
      ),
      locations = cells_column_labels()
    ) %>%
    tab_style(
      style = cell_text(align = "center"),
      locations = cells_body(columns = everything())
    ) %>%
    tab_style(
      style = cell_text(align = "left"),
      locations = cells_body(columns = "Dose Level")
    ) %>%
    # Add regulatory footnotes
    tab_footnote(
      footnote = "Target toxicity probability: 30%; Target efficacy probability: 60%",
      locations = cells_title()
    ) %>%
    # Regulatory-style source note
    tab_source_note(
      source_note = paste("Study Protocol ABC-123-001 |", 
                         "Statistical Analysis Plan v2.0 |",
                         "Generated:", format(Sys.Date(), "%d-%b-%Y"))
    ) %>%
    # Adjust table options for print
    tab_options(
      table.font.size = 11,
      heading.title.font.size = 12,
      footnotes.font.size = 9,
      table.width = pct(100)
    )
  
  regulatory_table
}

## ----scenario_comparison, eval=gt_available-----------------------------------
if (gt_available) {
  # Create comparison data
  scenarios <- data.frame(
    `Dose Level` = names(tite_result$prop.select),
    `Conservative (φ=0.25)` = c(8.1, 32.4, 45.2, 12.1, 2.2),
    `Standard (φ=0.30)` = as.numeric(tite_result$prop.select),
    `Aggressive (φ=0.35)` = c(2.3, 12.8, 35.6, 38.9, 10.4),
    check.names = FALSE
  )
  
  comparison_table <- scenarios %>%
    gt() %>%
    tab_header(
      title = "Scenario Comparison: Impact of Target Toxicity Rate",
      subtitle = "Selection Probabilities Across Different Design Parameters"
    ) %>%
    # Format numbers consistently
    fmt_number(
      columns = contains("φ="),
      decimals = 1
    ) %>%
    # Add spanning header
    tab_spanner(
      label = "Selection Probability (%)",
      columns = contains("φ=")
    ) %>%
    # Color code the scenarios
    tab_style(
      style = cell_fill(color = "lightgreen"),
      locations = cells_body(columns = contains("Conservative"))
    ) %>%
    tab_style(
      style = cell_fill(color = "lightyellow"), 
      locations = cells_body(columns = contains("Standard"))
    ) %>%
    tab_style(
      style = cell_fill(color = "lightcoral"),
      locations = cells_body(columns = contains("Aggressive"))
    ) %>%
    cols_align(
      align = "center",
      columns = everything()
    ) %>%
    cols_align(
      align = "left",
      columns = "Dose Level"
    )
  
  comparison_table
}

## ----advanced_design, eval=gt_available---------------------------------------
if (gt_available) {
  # Create enhanced design parameters table with categories
  design_data <- data.frame(
    category = c(rep("Design Criteria", 5), rep("Trial Logistics", 3)),
    parameter = c("Target Toxicity Rate (φ)", "Target Efficacy Rate (δ)", 
                  "Lower Toxicity Boundary (λ₁)", "Upper Toxicity Boundary (λ₂)",
                  "Efficacy Boundary (η₁)",
                  "Toxicity Assessment Window", "Efficacy Assessment Window", "Accrual Rate"),
    value = c(tite_result$phi, tite_result$delta, tite_result$lambda1, 
              tite_result$lambda2, tite_result$eta1,
              paste(tite_result$tau.T, "days"), 
              paste(tite_result$tau.E, "days"),
              paste(tite_result$accrual, "days")),
    stringsAsFactors = FALSE
  )
  
  enhanced_design_table <- design_data %>%
    gt(groupname_col = "category") %>%
    tab_header(
      title = "TITE-BOIN-ET Design Specifications",
      subtitle = "Drug XYZ-123 Phase I Study"
    ) %>%
    cols_label(
      parameter = "Parameter",
      value = "Value"
    ) %>%
    # Style the groups
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_row_groups()
    ) %>%
    tab_style(
      style = cell_fill(color = "gray95"),
      locations = cells_row_groups()
    ) %>%
    cols_align(
      align = "left",
      columns = "parameter"
    ) %>%
    cols_align(
      align = "center",
      columns = "value"
    )
  
  enhanced_design_table
}

## ----save_examples, eval=FALSE------------------------------------------------
# # Save tables in different formats (examples - not run)
# if (gt_available && exists("oc_table") && !is.null(oc_table)) {
# 
#   # HTML (interactive)
#   # oc_table %>% gtsave("operating_characteristics.html")
# 
#   # PNG (for presentations)
#   # oc_table %>% gtsave("operating_characteristics.png")
# 
#   # Word document (for reports)
#   # oc_table %>% gtsave("operating_characteristics.docx")
# 
#   # RTF (for regulatory submissions)
#   # oc_table %>% gtsave("operating_characteristics.rtf")
# 
#   cat("Tables can be saved using gtsave() function\n")
#   cat("Example: table %>% gtsave('filename.html')\n")
# }

## ----professional_example, eval=gt_available----------------------------------
if (gt_available) {
  # Example of professional formatting
  professional_table <- create_basic_oc_table(tite_result) %>%
    # Consistent alignment
    tab_style(
      style = cell_text(align = "center"),
      locations = cells_body(columns = c("True Toxicity Probability", 
                                       "True Efficacy Probability",
                                       "Selection Probability (%)"))
    ) %>%
    tab_style(
      style = cell_text(align = "right"),
      locations = cells_body(columns = "Average N Treated")
    ) %>%
    # Clear borders
    tab_style(
      style = cell_borders(sides = "top", weight = px(2)),
      locations = cells_body(rows = 1)
    ) %>%
    # Appropriate precision
    fmt_number(
      columns = "Average N Treated",
      decimals = 1
    ) %>%
    tab_header(
      title = "Professional Table Example",
      subtitle = "Consistent formatting and alignment"
    )
  
  professional_table
}

## ----troubleshooting_info, eval=FALSE-----------------------------------------
# # Issue: gt package not installed
# if (!requireNamespace("gt", quietly = TRUE)) {
#   message("Installing gt package...")
#   # install.packages("gt")
# }
# 
# # Issue: Functions not found
# # Solution: Ensure boinet package is properly loaded
# library(boinet)
# 
# # Issue: Tables not displaying in PDF
# # Solution: Use specific styling for PDF output and consider using gtsave()
# 
# cat("Common troubleshooting tips:\n")
# cat("1. Ensure gt package is installed: install.packages('gt')\n")
# cat("2. Load boinet package: library(boinet)\n")
# cat("3. For PDF output, use gtsave() to export tables\n")
# cat("4. Check that result objects have expected structure\n")

