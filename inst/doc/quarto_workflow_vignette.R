## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6
)

# Check package availability
gt_available <- requireNamespace("gt", quietly = TRUE)
ggplot2_available <- requireNamespace("ggplot2", quietly = TRUE)
quarto_available <- nzchar(Sys.which("quarto"))

## ----setup--------------------------------------------------------------------
library(boinet)
library(dplyr)

# Load additional packages for reporting
if (requireNamespace("gt", quietly = TRUE)) library(gt)
if (requireNamespace("ggplot2", quietly = TRUE)) library(ggplot2)

## ----availability-check, echo=FALSE, results='asis'---------------------------
if (!gt_available) {
  cat("**Note:** Some features require the gt package. Install with: `install.packages('gt')`\n\n")
}

if (!ggplot2_available) {
  cat("**Note:** Visualization features require ggplot2. Install with: `install.packages('ggplot2')`\n\n")
}

if (!quarto_available) {
  cat("**Note:** Full Quarto features require Quarto CLI. Install from: https://quarto.org/docs/get-started/\n\n")
}

## ----helper-functions---------------------------------------------------------
# Extract operating characteristics data
extract_oc_data <- function(boinet_result) {
  dose_levels <- names(boinet_result$n.patient)
  
  data.frame(
    dose_level = dose_levels,
    toxicity_prob = as.numeric(boinet_result$toxprob),
    efficacy_prob = as.numeric(boinet_result$effprob),
    n_patients = as.numeric(boinet_result$n.patient),
    selection_prob = as.numeric(boinet_result$prop.select),
    stringsAsFactors = FALSE
  )
}

# Create summary statistics
create_summary_stats <- function(boinet_result) {
  oc_data <- extract_oc_data(boinet_result)
  optimal_dose <- oc_data$dose_level[which.max(oc_data$selection_prob)]
  
  list(
    optimal_dose = optimal_dose,
    max_selection_prob = max(oc_data$selection_prob),
    early_stop_rate = as.numeric(boinet_result$prop.stop),
    avg_duration = as.numeric(boinet_result$duration),
    total_patients = sum(oc_data$n_patients),
    design_type = class(boinet_result)[1]
  )
}

# Create formatted text summaries
create_text_summary <- function(boinet_result) {
  stats <- create_summary_stats(boinet_result)
  
  sprintf(
    "The %s design selected dose level %s in %.1f%% of trials, with an average trial duration of %.0f days and early stopping rate of %.1f%%.",
    toupper(gsub("\\.", "-", stats$design_type)),
    stats$optimal_dose,
    stats$max_selection_prob,
    stats$avg_duration,
    stats$early_stop_rate
  )
}

# Create design parameters table
create_design_table <- function(result) {
  design_params <- data.frame(
    Parameter = c("Target Toxicity Rate (φ)", "Target Efficacy Rate (δ)", 
                  "Lower Toxicity Boundary (λ₁)", "Upper Toxicity Boundary (λ₂)",
                  "Efficacy Boundary (η₁)", "Early Stop Rate (%)", 
                  "Average Duration (days)", "Toxicity Assessment Window (days)",
                  "Efficacy Assessment Window (days)", "Accrual Rate (days)"),
    Value = c(result$phi, result$delta, result$lambda1, result$lambda2,
              result$eta1, result$prop.stop, result$duration,
              result$tau.T, result$tau.E, result$accrual),
    stringsAsFactors = FALSE
  )
  
  # Format values
  design_params$Value <- round(as.numeric(design_params$Value), 3)
  
  if (gt_available) {
    design_params %>%
      gt() %>%
      tab_header(
        title = "TITE-BOIN-ET Design Parameters",
        subtitle = paste("Based on", result$n.sim, "simulated trials")
      ) %>%
      fmt_number(columns = "Value", decimals = 3) %>%
      cols_align(align = "left", columns = "Parameter") %>%
      cols_align(align = "center", columns = "Value")
  } else {
    # Fallback to basic table
    print(design_params)
  }
}

# Create operating characteristics table
create_oc_table <- function(result) {
  dose_levels <- names(result$n.patient)
  
  oc_data <- data.frame(
    `Dose Level` = dose_levels,
    `True Toxicity Probability` = round(as.numeric(result$toxprob), 3),
    `True Efficacy Probability` = round(as.numeric(result$effprob), 3),
    `Average N Treated` = round(as.numeric(result$n.patient), 1),
    `Selection Probability (%)` = round(as.numeric(result$prop.select), 1),
    check.names = FALSE
  )
  
  if (gt_available) {
    oc_data %>%
      gt() %>%
      tab_header(
        title = "Operating Characteristics",
        subtitle = "TITE-BOIN-ET Design Simulation Results"
      ) %>%
      fmt_number(columns = c("True Toxicity Probability", "True Efficacy Probability"), decimals = 3) %>%
      fmt_number(columns = "Average N Treated", decimals = 1) %>%
      fmt_number(columns = "Selection Probability (%)", decimals = 1) %>%
      cols_align(align = "center", columns = everything()) %>%
      cols_align(align = "left", columns = "Dose Level") %>%
      tab_style(
        style = cell_fill(color = "lightblue"),
        locations = cells_body(
          rows = `Selection Probability (%)` == max(`Selection Probability (%)`)
        )
      )
  } else {
    # Fallback to basic table
    print(oc_data)
  }
}

## ----mock-data----------------------------------------------------------------
# Create mock result for demonstration
boinet_result <- list(
  toxprob = c("1" = 0.02, "2" = 0.08, "3" = 0.15, "4" = 0.25, "5" = 0.40),
  effprob = c("1" = 0.10, "2" = 0.20, "3" = 0.35, "4" = 0.50, "5" = 0.65),
  n.patient = c("1" = 8.2, "2" = 12.5, "3" = 15.8, "4" = 10.3, "5" = 7.2),
  prop.select = c("1" = 5.2, "2" = 18.7, "3" = 42.1, "4" = 28.3, "5" = 5.7),
  phi = 0.30, delta = 0.60, lambda1 = 0.03, lambda2 = 0.42, eta1 = 0.36,
  tau.T = 28, tau.E = 42, accrual = 7, duration = 156.3, prop.stop = 3.2, n.sim = 1000
)
class(boinet_result) <- "tite.boinet"

## ----demo-design-table, eval=gt_available-------------------------------------
# Design specifications table
create_design_table(boinet_result)

## ----demo-oc-table, eval=gt_available-----------------------------------------
# Operating characteristics table
create_oc_table(boinet_result)

## ----demo-analysis------------------------------------------------------------
# Extract key statistics for inline reporting
dose_levels <- names(boinet_result$n.patient)
selection_probs <- as.numeric(boinet_result$prop.select)
best_dose_idx <- which.max(selection_probs)
best_dose <- dose_levels[best_dose_idx]
max_selection <- max(selection_probs)
avg_duration <- as.numeric(boinet_result$duration)
early_stop <- as.numeric(boinet_result$prop.stop)

cat("Key findings:\n")
cat("- Optimal dose level:", best_dose, "\n")
cat("- Selection probability:", round(max_selection, 1), "%\n")
cat("- Average trial duration:", round(avg_duration, 0), "days\n")
cat("- Early stopping rate:", round(early_stop, 1), "%\n")

## ----demo-selection-plot, eval=ggplot2_available, fig.cap="Dose selection probabilities"----
if (ggplot2_available) {
  # Create data frame for plotting
  plot_data <- data.frame(
    dose_level = names(boinet_result$n.patient),
    selection_prob = as.numeric(boinet_result$prop.select)
  )
  
  plot_data %>%
    ggplot(aes(x = dose_level, y = selection_prob)) +
    geom_col(fill = "steelblue", alpha = 0.7) +
    geom_text(aes(label = paste0(round(selection_prob, 1), "%")), 
              vjust = -0.3) +
    labs(
      x = "Dose Level",
      y = "Selection Probability (%)",
      title = "TITE-BOIN-ET Dose Selection Performance"
    ) +
    theme_minimal()
} else {
  cat("ggplot2 package not available for visualization.\n")
}

## ----demo-risk-benefit, eval=ggplot2_available, fig.cap="Efficacy-toxicity profile"----
if (ggplot2_available) {
  # Create risk-benefit plot data
  rb_data <- data.frame(
    dose_level = names(boinet_result$n.patient),
    toxicity_prob = as.numeric(boinet_result$toxprob),
    efficacy_prob = as.numeric(boinet_result$effprob),
    selection_prob = as.numeric(boinet_result$prop.select)
  )
  
  rb_data %>%
    ggplot(aes(x = toxicity_prob, y = efficacy_prob)) +
    geom_point(aes(size = selection_prob), alpha = 0.7, color = "darkred") +
    geom_text(aes(label = dose_level), vjust = -1.5) +
    scale_size_continuous(name = "Selection\nProbability (%)", range = c(3, 12)) +
    labs(
      x = "True Toxicity Probability",
      y = "True Efficacy Probability",
      title = "Risk-Benefit Profile"
    ) +
    theme_minimal()
} else {
  cat("ggplot2 package not available for risk-benefit visualization.\n")
}

## ----parameterized-demo-------------------------------------------------------
# Demonstration of the concept using mock parameters
mock_params <- list(
  target_tox = 0.30,
  target_eff = 0.60,
  protocol_id = "ABC-001",
  compound_name = "XYZ-123"
)

cat("Parameterized report demonstration:\n")
cat("Protocol:", mock_params$protocol_id, "\n")
cat("Compound:", mock_params$compound_name, "\n")
cat("Target toxicity:", mock_params$target_tox, "\n")
cat("Target efficacy:", mock_params$target_eff, "\n")

# This shows how you could customize analysis based on parameters
cat("\nCustomized analysis settings:\n")
if (mock_params$target_tox < 0.25) {
  cat("- Conservative toxicity approach\n")
} else if (mock_params$target_tox > 0.35) {
  cat("- Aggressive toxicity approach\n")
} else {
  cat("- Standard toxicity approach\n")
}

## ----batch-demo---------------------------------------------------------------
# Demonstrate the concept with executable code
scenarios <- list(
  conservative = list(phi = 0.25, delta = 0.50, name = "Conservative"),
  standard = list(phi = 0.30, delta = 0.60, name = "Standard"),
  aggressive = list(phi = 0.35, delta = 0.70, name = "Aggressive")
)

# Function to create scenario-specific summaries
create_scenario_summary <- function(scenario) {
  sprintf(
    "Scenario: %s (φ=%.2f, δ=%.2f)",
    scenario$name, scenario$phi, scenario$delta
  )
}

# Generate summaries for all scenarios
scenario_summaries <- lapply(scenarios, create_scenario_summary)
cat("Available scenarios:\n")
for(summary in scenario_summaries) {
  cat("-", summary, "\n")
}

## ----conditional-content------------------------------------------------------
# Extract results for conditional logic
oc_data <- extract_oc_data(boinet_result)
max_selection_prob <- max(oc_data$selection_prob)
optimal_dose <- oc_data$dose_level[which.max(oc_data$selection_prob)]

# Conditional content based on results
if (max_selection_prob > 40) {
  recommendation <- "Strong evidence for optimal dose identification"
  confidence_level <- "High"
} else if (max_selection_prob > 25) {
  recommendation <- "Moderate evidence for dose selection"
  confidence_level <- "Moderate"  
} else {
  recommendation <- "Weak evidence - consider design modifications"
  confidence_level <- "Low"
}

cat("Recommendation Confidence:", confidence_level, "\n")
cat("Analysis Conclusion:", recommendation, "\n")
cat(sprintf("The optimal dose level %s was selected in %.1f%% of simulations.\n", 
            optimal_dose, max_selection_prob))

## ----reproducible-workflow-demo-----------------------------------------------
# Include session information
cat("R version:", R.version.string, "\n")
cat("boinet version:", as.character(packageVersion("boinet")), "\n")

if (gt_available) {
  cat("gt version:", as.character(packageVersion("gt")), "\n")
}

if (ggplot2_available) {
  cat("ggplot2 version:", as.character(packageVersion("ggplot2")), "\n")
}

# Document analysis timestamp
cat("Analysis completed:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

## ----clinical-template--------------------------------------------------------
# Function to create standardized clinical report content
create_clinical_report_content <- function(boinet_result, protocol_info) {
  
  # Extract key information
  oc_data <- extract_oc_data(boinet_result)
  stats <- create_summary_stats(boinet_result)
  
  # Create content structure
  content <- list(
    title = sprintf("Protocol %s: %s Analysis", 
                   protocol_info$id, protocol_info$compound),
    summary = create_text_summary(boinet_result),
    key_findings = list(
      optimal_dose = stats$optimal_dose,
      selection_prob = round(stats$max_selection_prob, 1),
      duration = round(stats$avg_duration, 0),
      early_stop = round(stats$early_stop_rate, 1)
    ),
    oc_data = oc_data
  )
  
  return(content)
}

# Example usage
protocol_info <- list(id = "XYZ-2024-001", compound = "Novel Kinase Inhibitor")
demo_result <- boinet_result
report_content <- create_clinical_report_content(demo_result, protocol_info)

cat("Report title:", report_content$title, "\n")
cat("Summary:", report_content$summary, "\n")

## ----regulatory-template------------------------------------------------------
# Function to create regulatory-style formatting
create_regulatory_content <- function(boinet_result, submission_info) {
  
  stats <- create_summary_stats(boinet_result)
  
  # Regulatory-style summary
  reg_summary <- sprintf(
    "Study %s evaluated %d dose levels using a %s design. The recommended Phase II dose is %s, selected in %s%% of %d simulated trials.",
    submission_info$study_id,
    length(names(boinet_result$n.patient)),
    toupper(gsub("\\.", "-", stats$design_type)),
    stats$optimal_dose,
    format(stats$max_selection_prob, digits = 3),
    boinet_result$n.sim
  )
  
  return(list(
    summary = reg_summary,
    table_title = sprintf("Table %s: Operating Characteristics", submission_info$table_number),
    stats = stats
  ))
}

# Example usage
submission_info <- list(study_id = "ABC-123-001", table_number = "14.2.1")
demo_result <- boinet_result
reg_content <- create_regulatory_content(demo_result, submission_info)

cat("Regulatory summary:", reg_content$summary, "\n")

## ----troubleshooting----------------------------------------------------------
# Check required packages
required_packages <- c("boinet", "dplyr")
optional_packages <- c("gt", "ggplot2", "knitr", "rmarkdown")

check_package_status <- function(packages, required = TRUE) {
  status <- sapply(packages, function(pkg) {
    requireNamespace(pkg, quietly = TRUE)
  })
  
  missing <- names(status)[!status]
  if (length(missing) > 0) {
    cat(ifelse(required, "Missing required", "Missing optional"), "packages:", 
        paste(missing, collapse = ", "), "\n")
    cat("Install with: install.packages(c('", paste(missing, collapse = "', '"), "'))\n")
  } else {
    cat("All", ifelse(required, "required", "optional"), "packages available\n")
  }
}

check_package_status(required_packages, TRUE)
check_package_status(optional_packages, FALSE)

# Check Quarto availability
if (quarto_available) {
  cat("✓ Quarto CLI available\n")
} else {
  cat("⚠ Quarto CLI not found. Install from: https://quarto.org\n")
}

## ----performance-tips---------------------------------------------------------
# Tips for handling large simulations
check_result_size <- function(result) {
  size_mb <- object.size(result) / (1024^2)
  cat(sprintf("Result object size: %.1f MB\n", size_mb))
  
  if (size_mb > 50) {
    cat("⚠ Large result object detected. Consider:\n")
    cat("  - Using cache: true in chunks\n")
    cat("  - Reducing n.sim for development\n")
    cat("  - Extracting only needed data\n")
  } else {
    cat("✓ Result size is manageable\n")
  }
}

# Use the demo result we created earlier
demo_result <- boinet_result
check_result_size(demo_result)

# Memory-efficient data extraction
extract_minimal_data <- function(result) {
  list(
    oc_summary = data.frame(
      dose = names(result$n.patient),
      selection_prob = as.numeric(result$prop.select),
      stringsAsFactors = FALSE
    ),
    key_stats = list(
      optimal_dose = names(result$prop.select)[which.max(result$prop.select)],
      duration = result$duration,
      early_stop = result$prop.stop
    )
  )
}

minimal_data <- extract_minimal_data(demo_result)
cat("Minimal data extracted successfully\n")

