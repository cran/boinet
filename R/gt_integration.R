#' Create GT Table for Operating Characteristics
#'
#' Creates a formatted gt table displaying operating characteristics from
#' boinet simulation results.
#'
#' @param boinet_result Result object from boinet functions
#' @param title Optional table title
#' @return A gt table object
#' @importFrom gt gt tab_header cols_label fmt_percent fmt_number cols_hide
#'   tab_style cell_text cells_column_labels tab_options
#' @export
create_oc_gt_table <- function(boinet_result, title = "Operating Characteristics") {
  # Check if gt is available
  if (!requireNamespace("gt", quietly = TRUE)) {
    warning("Package 'gt' is required for this function. Returning data frame instead.")
    return(extract_operating_characteristics(boinet_result))
  }

  # Determine if this is a graded function by checking for matrix toxprob
  is_graded <- "toxprob" %in% names(boinet_result) && is.matrix(boinet_result$toxprob)

  # Extract operating characteristics
  oc_data <- extract_operating_characteristics(boinet_result)

  # Create GT table with appropriate column labels
  if (is_graded) {
    # For gboinet/tite.gboinet: use nETS/nEES labels
    gt_table <- oc_data |>
      gt::gt() |>
      gt::tab_header(title = title) |>
      gt::cols_label(
        dose_level = "Dose Level",
        toxicity_prob = "nETS",
        efficacy_prob = "nEES",
        n_patients = "Average N Treated",
        selection_prob = "Selection Probability"
      ) |>
      gt::fmt_number(
        columns = c("toxicity_prob", "efficacy_prob"),
        decimals = 3
      )
  } else {
    # For boinet/tite.boinet: use probability labels
    gt_table <- oc_data |>
      gt::gt() |>
      gt::tab_header(title = title) |>
      gt::cols_label(
        dose_level = "Dose Level",
        toxicity_prob = "True Toxicity Probability",
        efficacy_prob = "True Efficacy Probability",
        n_patients = "Average N Treated",
        selection_prob = "Selection Probability"
      ) |>
      gt::fmt_percent(
        columns = c("toxicity_prob", "efficacy_prob"),
        decimals = 1
      )
  }

  # Apply common formatting
  gt_table <- gt_table |>
    gt::fmt_percent(
      columns = "selection_prob",
      decimals = 1
    ) |>
    gt::fmt_number(
      columns = "n_patients",
      decimals = 1
    ) |>
    gt::cols_hide("selection_pct") |>  # Hide redundant column
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) |>
    gt::tab_options(
      table.font.size = 12,
      heading.title.font.size = 14
    )

  return(gt_table)
}

#' Create GT Table for Design Parameters
#'
#' Creates a formatted gt table displaying design parameters.
#'
#' @param boinet_result Result object from boinet functions
#' @param title Optional table title
#' @return A gt table object
#' @importFrom gt gt tab_header cols_label fmt_number tab_style cell_text
#'   cells_column_labels tab_options
#' @export
create_design_gt_table <- function(boinet_result, title = "Design Parameters") {
  if (!requireNamespace("gt", quietly = TRUE)) {
    warning("Package 'gt' is required for this function. Returning data frame instead.")
    return(extract_design_summary(boinet_result))
  }

  # Extract design data
  design_data <- extract_design_summary(boinet_result)

  # Create GT table
  gt_table <- design_data |>
    gt::gt() |>
    gt::tab_header(title = title) |>
    gt::cols_label(
      parameter = "Parameter",
      value = "Value"
    ) |>
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) |>
    gt::tab_options(
      table.font.size = 12,
      heading.title.font.size = 14
    )

  return(gt_table)
}
