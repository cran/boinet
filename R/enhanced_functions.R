#' Extract Operating Characteristics in Tidy Format
#'
#' Converts boinet simulation results into a tidy data frame suitable for
#' analysis and reporting.
#'
#' @param boinet_result Result object from boinet functions (tite.boinet,
#'   tite.gboinet, boinet, gboinet)
#' @return A tibble with columns: dose_level, toxicity_prob, efficacy_prob,
#'   n_patients, selection_prob, selection_pct
#' @importFrom tibble tibble
#' @export
extract_operating_characteristics <- function(boinet_result) {
  # Input validation
  if (!inherits(boinet_result, c("boinet", "tite.boinet", "gboinet", "tite.gboinet"))) {
    stop("Input must be a boinet result object (boinet, tite.boinet, gboinet, or tite.gboinet)")
  }

  # Determine if this is a graded function by checking for matrix toxprob
  is_graded <- "toxprob" %in% names(boinet_result) && is.matrix(boinet_result$toxprob)

  if (is_graded) {
    # For gboinet/tite.gboinet: get doses from matrix structure
    n_doses <- ncol(boinet_result$toxprob)
    dose_levels <- colnames(boinet_result$toxprob)
    if (is.null(dose_levels)) {
      dose_levels <- paste0("Dose", 1:n_doses)
    }

    # Use nETS and nEES directly
    toxicity_prob <- as.numeric(boinet_result$nETS)
    efficacy_prob <- as.numeric(boinet_result$nEES)

  } else {
    # For boinet/tite.boinet: get doses from vector structure
    dose_levels <- names(boinet_result$toxprob)
    if (is.null(dose_levels)) {
      n_doses <- length(boinet_result$toxprob)
      dose_levels <- paste0("Dose", 1:n_doses)
    }

    # Use toxprob and effprob directly
    toxicity_prob <- as.numeric(boinet_result$toxprob)
    efficacy_prob <- as.numeric(boinet_result$effprob)
  }

  # Extract patient counts and selection probabilities (same for both types)
  n_patients <- as.numeric(boinet_result$n.patient)
  selection_prob_raw <- as.numeric(boinet_result$prop.select)

  # Ensure conversion from percentages to proportions
  # boinet results store selection probabilities as percentages (0-100),
  # but we want proportions (0-1) for consistency
  selection_prob <- selection_prob_raw / 100

  # Create tidy data frame
  tibble::tibble(
    dose_level = dose_levels,
    toxicity_prob = toxicity_prob,
    efficacy_prob = efficacy_prob,
    n_patients = n_patients,
    selection_prob = selection_prob,
    selection_pct = paste0(round(selection_prob * 100, 1), "%")
  )
}

#' Extract Design Parameters Summary
#'
#' Extracts design parameters from boinet results in a tidy format.
#'
#' @param boinet_result Result object from boinet functions (boinet, tite.boinet,
#'   gboinet, tite.gboinet)
#' @return A tibble with parameter names and values
#' @importFrom tibble tibble
#' @export
extract_design_summary <- function(boinet_result) {
  # Validate input
  if (!inherits(boinet_result, c("boinet", "tite.boinet", "gboinet", "tite.gboinet"))) {
    stop("Input must be a boinet result object (boinet, tite.boinet, gboinet, or tite.gboinet)")
  }

  # Determine if this is a graded function by checking for matrix toxprob
  is_graded <- "toxprob" %in% names(boinet_result) && is.matrix(boinet_result$toxprob)

  # Function to safely extract values (remove names)
  safe_extract <- function(obj, field_name) {
    value <- obj[[field_name]]
    if (is.null(value)) {
      return(NA)
    } else if (is.numeric(value)) {
      return(as.numeric(value[1]))
    } else if (is.character(value)) {
      return(as.character(value[1]))
    } else {
      return(value[1])
    }
  }

  # Get number of doses
  if (is_graded) {
    n_doses <- ncol(boinet_result$toxprob)
  } else {
    n_doses <- length(boinet_result$toxprob)
  }

  # Build parameter list based on type
  if (is_graded) {
    # For gboinet/tite.gboinet
    param_names <- c(
      "Number of Doses",
      "Number of Toxicity Categories",
      "Number of Efficacy Categories",
      "Target nETS",
      "Target nEES",
      "Lower Toxicity Boundary",
      "Upper Toxicity Boundary",
      "Lower Efficacy Boundary",
      "Toxicity Assessment Window (days)",
      "Efficacy Assessment Window (days)",
      "Accrual Rate (days)",
      "Early Stop Probability (%)",
      "Trial Duration (days)",
      "Efficacy Estimation Method",
      "OBD Selection Method"
    )

    param_values <- c(
      n_doses,
      safe_extract(boinet_result, "ncat.T"),
      safe_extract(boinet_result, "ncat.E"),
      safe_extract(boinet_result, "phi"),
      safe_extract(boinet_result, "delta"),
      safe_extract(boinet_result, "lambda1"),
      safe_extract(boinet_result, "lambda2"),
      safe_extract(boinet_result, "eta1"),
      safe_extract(boinet_result, "tau.T"),
      safe_extract(boinet_result, "tau.E"),
      safe_extract(boinet_result, "accrual"),
      safe_extract(boinet_result, "prop.stop"),
      safe_extract(boinet_result, "duration"),
      safe_extract(boinet_result, "estpt.method"),
      safe_extract(boinet_result, "obd.method")
    )

  } else {
    # For boinet/tite.boinet
    param_names <- c(
      "Number of Doses",
      "Target Toxicity Probability",
      "Target Efficacy Probability",
      "Lower Toxicity Boundary",
      "Upper Toxicity Boundary",
      "Lower Efficacy Boundary",
      "Toxicity Assessment Window (days)",
      "Efficacy Assessment Window (days)",
      "Accrual Rate (days)",
      "Early Stop Probability (%)",
      "Trial Duration (days)",
      "Efficacy Estimation Method",
      "OBD Selection Method"
    )

    param_values <- c(
      n_doses,
      safe_extract(boinet_result, "phi"),
      safe_extract(boinet_result, "delta"),
      safe_extract(boinet_result, "lambda1"),
      safe_extract(boinet_result, "lambda2"),
      safe_extract(boinet_result, "eta1"),
      safe_extract(boinet_result, "tau.T"),
      safe_extract(boinet_result, "tau.E"),
      safe_extract(boinet_result, "accrual"),
      safe_extract(boinet_result, "prop.stop"),
      safe_extract(boinet_result, "duration"),
      safe_extract(boinet_result, "estpt.method"),
      safe_extract(boinet_result, "obd.method")
    )
  }

  # Remove NA parameters and ensure consistent data types
  valid_indices <- !is.na(param_values)
  param_names <- param_names[valid_indices]
  param_values <- param_values[valid_indices]

  # Ensure all values are characters for consistency
  param_values <- as.character(param_values)

  # Return tibble
  tibble::tibble(
    parameter = param_names,
    value = param_values
  )
}
