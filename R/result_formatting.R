
#' Format BOIN-ET Results for Reporting
#'
#' Converts boinet simulation results into various formats optimized for
#' analysis and reporting workflows. This is the MAIN new function.
#'
#' @param boinet_result Result object from any boinet function (boinet,
#'   tite.boinet, gboinet, tite.gboinet)
#' @param output_format Character string specifying output format:
#'   \itemize{
#'     \item "list" - Returns original result unchanged
#'     \item "tidy" - Returns tidy data frames for analysis
#'     \item "gt_ready" - Returns formatted gt tables for reporting
#'   }
#' @return Results in specified format
#' @export
#' @examples
#' \dontrun{
#' # Run simulation first
#' result <- tite.boinet(
#'   n.dose = 4, start.dose = 1, size.cohort = 3, n.cohort = 10,
#'   toxprob = c(0.05, 0.15, 0.25, 0.40),
#'   effprob = c(0.15, 0.30, 0.45, 0.60),
#'   phi = 0.30, delta = 0.60, n.sim = 100
#' )
#'
#' # Format for different uses
#' original <- format_boinet_results(result, "list")
#' tidy_data <- format_boinet_results(result, "tidy")
#' report_tables <- format_boinet_results(result, "gt_ready")
#'
#' # Use formatted results
#' print(tidy_data$operating_characteristics)
#' print(report_tables$oc_table)
#' }
format_boinet_results <- function(boinet_result, output_format = c("list", "tidy", "gt_ready")) {
  # Input validation
  if (!inherits(boinet_result, c("boinet", "tite.boinet", "gboinet", "tite.gboinet"))) {
    stop("Input must be a boinet result object (boinet, tite.boinet, gboinet, or tite.gboinet)")
  }

  output_format <- match.arg(output_format)

  if (output_format == "list") {
    return(boinet_result)
  } else if (output_format == "tidy") {
    return(list(
      operating_characteristics = extract_operating_characteristics(boinet_result),
      design_parameters = extract_design_summary(boinet_result),
      original_result = boinet_result
    ))
  } else if (output_format == "gt_ready") {
    return(list(
      oc_table = create_oc_gt_table(boinet_result),
      design_table = create_design_gt_table(boinet_result),
      data = list(
        operating_characteristics = extract_operating_characteristics(boinet_result),
        design_parameters = extract_design_summary(boinet_result)
      ),
      original_result = boinet_result
    ))
  }
}

#' Create Report-Ready Tables from BOIN-ET Results
#'
#' Generates publication-ready gt tables from boinet simulation results.
#' This is a convenience wrapper for format_boinet_results with gt_ready output.
#'
#' @param boinet_result Result object from any boinet function
#' @param oc_title Title for operating characteristics table
#' @param design_title Title for design parameters table
#' @return List containing formatted gt tables and tidy data
#' @export
#' @examples
#' \dontrun{
#' result <- tite.boinet(...)
#' tables <- create_boinet_tables(result,
#'                               oc_title = "Trial Operating Characteristics",
#'                               design_title = "Design Specifications")
#'
#' # Print tables
#' print(tables$oc_table)
#' print(tables$design_table)
#'
#' # Save tables
#' tables$oc_table |> gt::gtsave("oc_results.html")
#' }
create_boinet_tables <- function(boinet_result,
                                 oc_title = "Operating Characteristics",
                                 design_title = "Design Parameters") {
  # Input validation
  if (!inherits(boinet_result, c("boinet", "tite.boinet", "gboinet", "tite.gboinet"))) {
    stop("Input must be a boinet result object")
  }

  return(list(
    oc_table = create_oc_gt_table(boinet_result, title = oc_title),
    design_table = create_design_gt_table(boinet_result, title = design_title),
    data = list(
      operating_characteristics = extract_operating_characteristics(boinet_result),
      design_parameters = extract_design_summary(boinet_result)
    ),
    original_result = boinet_result
  ))
}

#' Extract Tidy Data from BOIN-ET Results
#'
#' Convenience function to extract tidy data frames from boinet results.
#' This is a wrapper for format_boinet_results with tidy output.
#'
#' @param boinet_result Result object from any boinet function
#' @return List containing tidy data frames
#' @export
#' @examples
#' \dontrun{
#' result <- gboinet(...)
#' tidy_data <- extract_boinet_data(result)
#'
#' # Use tidy data for custom analysis
#' library(ggplot2)
#' tidy_data$operating_characteristics |>
#'   ggplot(aes(x = dose_level, y = selection_prob)) +
#'   geom_col()
#' }
extract_boinet_data <- function(boinet_result) {
  format_boinet_results(boinet_result, output_format = "tidy")
}
