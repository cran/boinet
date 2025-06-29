## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

# Check package availability
ggplot2_available <- requireNamespace("ggplot2", quietly = TRUE)

## ----setup--------------------------------------------------------------------
library(boinet)
library(dplyr)

# Load ggplot2 if available
if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
}

## ----simulation, eval=FALSE---------------------------------------------------
# # Example TITE-BOIN-ET simulation
# result <- tite.boinet(
#   n.dose = 5,
#   start.dose = 1,
#   size.cohort = 3,
#   n.cohort = 15,
#   toxprob = c(0.02, 0.08, 0.15, 0.25, 0.40),
#   effprob = c(0.10, 0.20, 0.35, 0.50, 0.65),
#   phi = 0.30,
#   delta = 0.60,
#   tau.T = 28,
#   tau.E = 42,
#   accrual = 7,
#   estpt.method = "obs.prob",
#   obd.method = "max.effprob",
#   n.sim = 1000
# )

## ----mock_result, echo=FALSE--------------------------------------------------
# Create mock result for demonstration
result <- list(
  toxprob = c("1" = 0.02, "2" = 0.08, "3" = 0.15, "4" = 0.25, "5" = 0.40),
  effprob = c("1" = 0.10, "2" = 0.20, "3" = 0.35, "4" = 0.50, "5" = 0.65),
  n.patient = c("1" = 8.2, "2" = 12.5, "3" = 15.8, "4" = 10.3, "5" = 7.2),
  prop.select = c("1" = 5.2, "2" = 18.7, "3" = 42.1, "4" = 28.3, "5" = 5.7),
  phi = 0.30,
  delta = 0.60,
  lambda1 = 0.03,
  lambda2 = 0.42,
  eta1 = 0.36,
  tau.T = 28,
  tau.E = 42,
  accrual = 7,
  duration = 156.3,
  prop.stop = 3.2,
  n.sim = 1000
)
class(result) <- "tite.boinet"

## ----manual_extraction--------------------------------------------------------
# Extract operating characteristics manually
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

# Extract design parameters manually
extract_design_data <- function(boinet_result) {
  params <- data.frame(
    parameter = c("Target Toxicity Rate (φ)", "Target Efficacy Rate (δ)", 
                  "Lower Toxicity Boundary (λ₁)", "Upper Toxicity Boundary (λ₂)",
                  "Efficacy Boundary (η₁)", "Early Stop Rate (%)", 
                  "Average Duration (days)", "Number of Simulations"),
    value = c(boinet_result$phi, boinet_result$delta, 
              boinet_result$lambda1, boinet_result$lambda2,
              boinet_result$eta1, boinet_result$prop.stop, 
              boinet_result$duration, boinet_result$n.sim),
    stringsAsFactors = FALSE
  )
  
  # Add time-specific parameters if available
  if (!is.null(boinet_result$tau.T)) {
    time_params <- data.frame(
      parameter = c("Toxicity Assessment Window (days)", 
                    "Efficacy Assessment Window (days)",
                    "Accrual Rate (days)"),
      value = c(boinet_result$tau.T, boinet_result$tau.E, boinet_result$accrual),
      stringsAsFactors = FALSE
    )
    params <- rbind(params, time_params)
  }
  
  return(params)
}

# Extract data
oc_data <- extract_oc_data(result)
design_data <- extract_design_data(result)

# View operating characteristics
oc_data

## ----design_params------------------------------------------------------------
# View design parameters
design_data

## ----design_types, eval=FALSE-------------------------------------------------
# # The extraction functions work with any boinet result type:
# # - tite.boinet results
# # - tite.gboinet results
# # - boinet results
# # - gboinet results
# 
# # Example usage:
# # oc_data <- extract_oc_data(any_boinet_result)
# # design_data <- extract_design_data(any_boinet_result)

## ----dose_analysis------------------------------------------------------------
# Find optimal dose
optimal_dose <- oc_data$dose_level[which.max(oc_data$selection_prob)]
cat("Optimal dose level:", optimal_dose, "\n")
cat("Selection probability:", round(max(oc_data$selection_prob), 1), "%\n")

# Doses with reasonable selection probability (>10%)
viable_doses <- oc_data[oc_data$selection_prob > 10, ]
viable_doses

## ----safety_analysis----------------------------------------------------------
# Assess safety profile
safety_summary <- oc_data %>%
  mutate(
    safety_category = case_when(
      toxicity_prob <= 0.10 ~ "Low toxicity",
      toxicity_prob <= 0.25 ~ "Moderate toxicity", 
      TRUE ~ "High toxicity"
    )
  ) %>%
  group_by(safety_category) %>%
  summarise(
    n_doses = n(),
    total_selection_prob = sum(selection_prob),
    avg_patients = mean(n_patients),
    .groups = "drop"
  )

safety_summary

## ----tradeoff_analysis--------------------------------------------------------
# Analyze efficacy-toxicity trade-off
tradeoff_data <- oc_data %>%
  mutate(
    benefit_risk_ratio = efficacy_prob / (toxicity_prob + 0.01),  # Add small constant to avoid division by zero
    utility_score = efficacy_prob - 2 * toxicity_prob  # Simple utility function
  ) %>%
  arrange(desc(utility_score))

# Top doses by utility
head(tradeoff_data[, c("dose_level", "toxicity_prob", "efficacy_prob", 
                       "selection_prob", "utility_score")], 3)

## ----visualization, eval=ggplot2_available, fig.cap="Dose Selection Probabilities"----
if (ggplot2_available) {
  oc_data %>%
    ggplot(aes(x = dose_level, y = selection_prob)) +
    geom_col(fill = "steelblue", alpha = 0.7) +
    geom_text(aes(label = paste0(round(selection_prob, 1), "%")), 
              vjust = -0.3, size = 3.5) +
    labs(
      x = "Dose Level",
      y = "Selection Probability (%)",
      title = "TITE-BOIN-ET: Dose Selection Performance",
      subtitle = paste("Optimal dose:", optimal_dose, 
                      "selected in", round(max(oc_data$selection_prob), 1), "% of trials")
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5, size = 12)
    )
} else {
  cat("ggplot2 package not available. Install with: install.packages('ggplot2')\n")
}

## ----efficacy_toxicity_plot, eval=ggplot2_available, fig.cap="Efficacy vs Toxicity Trade-off"----
if (ggplot2_available) {
  oc_data %>%
    ggplot(aes(x = toxicity_prob, y = efficacy_prob)) +
    geom_point(aes(size = selection_prob), alpha = 0.7, color = "darkred") +
    geom_text(aes(label = dose_level), vjust = -1.2) +
    scale_size_continuous(name = "Selection\nProbability (%)", range = c(2, 10)) +
    labs(
      x = "True Toxicity Probability",
      y = "True Efficacy Probability", 
      title = "Efficacy-Toxicity Profile",
      subtitle = "Point size represents selection probability"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5, size = 12)
    )
} else {
  cat("ggplot2 package not available for visualization.\n")
}

## ----oc_table-----------------------------------------------------------------
# Create a nicely formatted table using base R
create_oc_summary <- function(oc_data) {
  formatted_data <- oc_data
  formatted_data$toxicity_prob <- round(formatted_data$toxicity_prob, 3)
  formatted_data$efficacy_prob <- round(formatted_data$efficacy_prob, 3)
  formatted_data$n_patients <- round(formatted_data$n_patients, 1)
  formatted_data$selection_prob <- round(formatted_data$selection_prob, 1)
  
  # Rename columns for display
  names(formatted_data) <- c("Dose Level", "True Toxicity Prob", 
                           "True Efficacy Prob", "Avg N Treated", 
                           "Selection Prob (%)")
  
  return(formatted_data)
}

# Create formatted table
formatted_oc <- create_oc_summary(oc_data)
print(formatted_oc)

## ----design_table-------------------------------------------------------------
# Create formatted design parameters table
create_design_summary <- function(design_data) {
  formatted_design <- design_data
  formatted_design$value <- round(as.numeric(formatted_design$value), 3)
  
  # Clean up parameter names
  names(formatted_design) <- c("Parameter", "Value")
  
  return(formatted_design)
}

formatted_design <- create_design_summary(design_data)
print(formatted_design)

## ----summary_output-----------------------------------------------------------
# Enhanced summary automatically detects design type
summary(result)

## ----export_data, eval=FALSE--------------------------------------------------
# # Export data for external analysis
# write.csv(oc_data, "operating_characteristics.csv", row.names = FALSE)
# write.csv(design_data, "design_parameters.csv", row.names = FALSE)
# 
# # Save as RDS for R users
# saveRDS(list(oc_data = oc_data, design_data = design_data), "boinet_results.rds")
# 
# # Create summary report
# summary_stats <- list(
#   optimal_dose = optimal_dose,
#   max_selection_prob = max(oc_data$selection_prob),
#   early_stop_rate = result$prop.stop,
#   avg_duration = result$duration,
#   design_type = class(result)[1]
# )
# 
# saveRDS(summary_stats, "summary_statistics.rds")

## ----validation---------------------------------------------------------------
# Always check your results make sense
total_selection <- sum(oc_data$selection_prob) + as.numeric(result$prop.stop)
cat("Total probability (selection + early stop):", round(total_selection, 1), "%\n")

# Check for reasonable dose allocation
cat("Patient allocation summary:\n")
print(summary(oc_data$n_patients))

# Verify dose ordering makes sense
if (all(diff(oc_data$toxicity_prob) >= 0)) {
  cat("✓ Toxicity probabilities are non-decreasing\n")
} else {
  cat("⚠ Warning: Toxicity probabilities not monotonic\n")
}

## ----reproducibility----------------------------------------------------------
# Document analysis parameters
analysis_info <- list(
  date = Sys.Date(),
  design_type = class(result)[1],
  r_version = R.version.string,
  boinet_version = as.character(packageVersion("boinet")),
  key_findings = list(
    optimal_dose = optimal_dose,
    selection_probability = max(oc_data$selection_prob),
    early_stop_rate = as.numeric(result$prop.stop)
  )
)

# Display analysis info
str(analysis_info)

## ----utility_functions--------------------------------------------------------
# Create reusable utility functions
calculate_utility_score <- function(eff_prob, tox_prob, eff_weight = 1, tox_weight = 2) {
  eff_weight * eff_prob - tox_weight * tox_prob
}

find_best_doses <- function(oc_data, n_top = 3) {
  oc_data %>%
    arrange(desc(selection_prob)) %>%
    head(n_top) %>%
    select(dose_level, selection_prob, toxicity_prob, efficacy_prob)
}

# Use utility functions
oc_data$utility <- calculate_utility_score(oc_data$efficacy_prob, oc_data$toxicity_prob)
top_doses <- find_best_doses(oc_data)

cat("Top doses by selection probability:\n")
print(top_doses)

## ----sensitivity_analysis-----------------------------------------------------
# Analyze sensitivity to design parameters
sensitivity_summary <- data.frame(
  metric = c("Optimal Dose", "Max Selection %", "Early Stop %", 
             "Avg Duration", "Total Patients"),
  value = c(optimal_dose, round(max(oc_data$selection_prob), 1),
            round(result$prop.stop, 1), round(result$duration, 0),
            round(sum(oc_data$n_patients), 0)),
  stringsAsFactors = FALSE
)

print(sensitivity_summary)

## ----comparison_framework-----------------------------------------------------
# Framework for comparing multiple designs
create_design_comparison <- function(result_list, design_names) {
  comparison_data <- data.frame()
  
  for (i in seq_along(result_list)) {
    oc_data <- extract_oc_data(result_list[[i]])
    optimal_dose <- oc_data$dose_level[which.max(oc_data$selection_prob)]
    
    summary_row <- data.frame(
      design = design_names[i],
      optimal_dose = optimal_dose,
      max_selection = max(oc_data$selection_prob),
      early_stop = result_list[[i]]$prop.stop,
      avg_duration = result_list[[i]]$duration,
      stringsAsFactors = FALSE
    )
    
    comparison_data <- rbind(comparison_data, summary_row)
  }
  
  return(comparison_data)
}

# Example usage (would work with multiple results)
cat("Comparison framework ready for multiple design evaluation\n")

