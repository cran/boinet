
#' Summary method for boinet objects
#'
#' Provides a formatted summary of boinet simulation results.
#'
#' @param object A boinet result object
#' @param ... Additional arguments (currently unused)
#' @return Formatted summary output (invisible)
#' @export
#' @method summary boinet
summary.boinet <- function(object, ...) {
  design_type <- class(object)[1]

  cat(sprintf("%s Design Operating Characteristics\n",
              switch(design_type,
                     "boinet" = "BOIN-ET",
                     "tite.boinet" = "TITE-BOIN-ET",
                     "gboinet" = "gBOIN-ET",
                     "tite.gboinet" = "TITE-gBOIN-ET",
                     "BOIN-ET")))
  cat("=========================================\n\n")

  # Design parameters
  cat("Design Parameters:\n")
  cat(sprintf("  Target Toxicity Probability: %.2f\n", as.numeric(object$phi)))
  cat(sprintf("  Target Efficacy Probability: %.2f\n", as.numeric(object$delta)))
  if (!is.null(object$duration)) {
    cat(sprintf("  Trial Duration: %.1f days\n", as.numeric(object$duration)))
  }
  cat(sprintf("  Early Stop Probability: %.1f%%\n", as.numeric(object$prop.stop)))
  cat("\n")

  # Operating characteristics table
  cat("Operating Characteristics by Dose Level:\n")
  oc_data <- extract_operating_characteristics(object)
  print(oc_data, n = Inf)

  invisible(object)
}

#' Summary method for tite.boinet objects
#'
#' @param object A tite.boinet result object
#' @param ... Additional arguments (currently unused)
#' @return Formatted summary output (invisible)
#' @export
#' @method summary tite.boinet
summary.tite.boinet <- function(object, ...) {
  # Call the general boinet summary method
  summary.boinet(object, ...)
}

#' Summary method for gboinet objects
#'
#' @param object A gboinet result object
#' @param ... Additional arguments (currently unused)
#' @return Formatted summary output (invisible)
#' @export
#' @method summary gboinet
summary.gboinet <- function(object, ...) {
  # Call the general boinet summary method
  summary.boinet(object, ...)
}

#' Summary method for tite.gboinet objects
#'
#' @param object A tite.gboinet result object
#' @param ... Additional arguments (currently unused)
#' @return Formatted summary output (invisible)
#' @export
#' @method summary tite.gboinet
summary.tite.gboinet <- function(object, ...) {
  # Call the general boinet summary method
  summary.boinet(object, ...)
}
