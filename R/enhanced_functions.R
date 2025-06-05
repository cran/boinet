
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
#' @examples
#' \dontrun{
#' # Run BOIN-ET simulation
#' result <- tite.boinet(
#'   n.dose = 4, start.dose = 1, size.cohort = 3, n.cohort = 10,
#'   toxprob = c(0.05, 0.15, 0.25, 0.40),
#'   effprob = c(0.15, 0.30, 0.45, 0.60),
#'   phi = 0.30, delta = 0.60, n.sim = 100
#' )
#'
#' # Extract in tidy format
#' oc_data <- extract_operating_characteristics(result)
#' print(oc_data)
#' }
extract_operating_characteristics <- function(boinet_result) {
  # Input validation
  if (!inherits(boinet_result, c("boinet", "tite.boinet", "gboinet", "tite.gboinet"))) {
    stop("Input must be a boinet result object (boinet, tite.boinet, gboinet, or tite.gboinet)")
  }

  # Extract dose levels
  doses <- names(boinet_result$toxprob)

  # Create tidy data frame
  tibble::tibble(
    dose_level = doses,
    toxicity_prob = as.numeric(boinet_result$toxprob),
    efficacy_prob = as.numeric(boinet_result$effprob),
    n_patients = as.numeric(boinet_result$n.patient),
    selection_prob = as.numeric(boinet_result$prop.select),
    selection_pct = paste0(round(as.numeric(boinet_result$prop.select), 1), "%")
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

  # Create parameter names
  param_names <- c(
    "Target Toxicity Probability",
    "Target Efficacy Probability",
    "Lower Toxicity Boundary",
    "Upper Toxicity Boundary",
    "Lower Efficacy Boundary",
    "Toxicity Assessment Window (days)",
    "Efficacy Assessment Window (days)",
    "Accrual Rate (days)",
    "Trial Duration (days)",
    "Early Stop Probability"
  )

  # Extract values, handling missing ones gracefully
  param_values <- c(
    if (!is.null(boinet_result$phi)) as.numeric(boinet_result$phi) else NA,
    if (!is.null(boinet_result$delta)) as.numeric(boinet_result$delta) else NA,
    if (!is.null(boinet_result$lambda1)) as.numeric(boinet_result$lambda1) else NA,
    if (!is.null(boinet_result$lambda2)) as.numeric(boinet_result$lambda2) else NA,
    if (!is.null(boinet_result$eta1)) as.numeric(boinet_result$eta1) else NA,
    if (!is.null(boinet_result$tau.T)) as.numeric(boinet_result$tau.T) else NA,
    if (!is.null(boinet_result$tau.E)) as.numeric(boinet_result$tau.E) else NA,
    if (!is.null(boinet_result$accrual)) as.numeric(boinet_result$accrual) else NA,
    if (!is.null(boinet_result$duration)) as.numeric(boinet_result$duration) else NA,
    if (!is.null(boinet_result$prop.stop)) as.numeric(boinet_result$prop.stop) else NA
  )

  # Return all parameters, including those with NA values
  tibble::tibble(
    parameter = param_names,
    value = param_values
  )
}
