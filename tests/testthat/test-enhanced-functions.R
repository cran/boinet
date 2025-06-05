
test_that("extract functions handle missing components gracefully", {
  # Test with minimal mock result (missing some optional components)
  minimal_result <- list(
    toxprob = c("1" = 0.1),
    effprob = c("1" = 0.2),
    n.patient = c("1" = 5.0),
    prop.select = c("1" = 100.0),
    phi = 0.3,
    delta = 0.6,
    prop.stop = 0.0,
    # Include required components that might be missing in edge cases
    lambda1 = 0.03,
    lambda2 = 0.42,
    eta1 = 0.18,
    duration = 100
    # Note: tau.T, tau.E, accrual are missing (TITE-specific parameters)
  )
  class(minimal_result) <- "boinet"  # Non-TITE design

  # Should work even with missing optional components
  oc_result <- extract_operating_characteristics(minimal_result)
  expect_s3_class(oc_result, "tbl_df")
  expect_equal(nrow(oc_result), 1)

  design_result <- extract_design_summary(minimal_result)
  expect_s3_class(design_result, "tbl_df")
  expect_equal(nrow(design_result), 10)  # Should have all 10 parameters

  # TITE-specific parameters should be NA for non-TITE designs
  tite_params <- c("Toxicity Assessment Window (days)",
                   "Efficacy Assessment Window (days)",
                   "Accrual Rate (days)")

  tite_rows <- design_result[design_result$parameter %in% tite_params, ]
  expect_true(all(is.na(tite_rows$value)))
})

test_that("extract functions handle completely missing optional components", {
  # Test with truly minimal result (some components completely missing)
  very_minimal_result <- list(
    toxprob = c("1" = 0.1),
    effprob = c("1" = 0.2),
    n.patient = c("1" = 5.0),
    prop.select = c("1" = 100.0),
    phi = 0.3,
    delta = 0.6,
    prop.stop = 0.0
    # Missing: lambda1, lambda2, eta1, duration, tau.T, tau.E, accrual
  )
  class(very_minimal_result) <- "boinet"

  # Should still work and return appropriate NA values
  design_result <- extract_design_summary(very_minimal_result)
  expect_s3_class(design_result, "tbl_df")
  expect_equal(nrow(design_result), 10)

  # Missing components should be NA
  missing_params <- c("Lower Toxicity Boundary", "Upper Toxicity Boundary",
                      "Lower Efficacy Boundary", "Trial Duration (days)",
                      "Toxicity Assessment Window (days)",
                      "Efficacy Assessment Window (days)",
                      "Accrual Rate (days)")

  missing_rows <- design_result[design_result$parameter %in% missing_params, ]
  expect_true(all(is.na(missing_rows$value)))

  # Present components should not be NA
  present_params <- c("Target Toxicity Probability", "Target Efficacy Probability",
                      "Early Stop Probability")
  present_rows <- design_result[design_result$parameter %in% present_params, ]
  expect_true(all(!is.na(present_rows$value)))
})
