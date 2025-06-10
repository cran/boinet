
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
  # The function returns rows only for parameters that exist in the result
  # Based on actual behavior, this returns 8 rows
  expect_equal(nrow(design_result), 8)

  # TITE-specific parameters should not be present for non-TITE designs
  tite_params <- c("Toxicity Assessment Window (days)",
                   "Efficacy Assessment Window (days)",
                   "Accrual Rate (days)")

  # These parameters should not be in the result
  tite_rows <- design_result[design_result$parameter %in% tite_params, ]
  expect_equal(nrow(tite_rows), 0)
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

  # Should still work and only return rows for present parameters
  design_result <- extract_design_summary(very_minimal_result)
  expect_s3_class(design_result, "tbl_df")
  # Based on actual behavior, this returns 4 rows
  expect_equal(nrow(design_result), 4)

  # Verify that the parameters we provided are included
  params_in_result <- design_result$parameter

  # Check for presence of key parameters (allowing for slight naming variations)
  has_toxicity_param <- any(grepl("Toxicity.*Probability", params_in_result, ignore.case = TRUE))
  has_efficacy_param <- any(grepl("Efficacy.*Probability", params_in_result, ignore.case = TRUE))
  has_stop_param <- any(grepl("Stop", params_in_result, ignore.case = TRUE))

  expect_true(has_toxicity_param)
  expect_true(has_efficacy_param)
  expect_true(has_stop_param)

  # Parameters that should NOT be present
  missing_params <- c("Lower Toxicity Boundary", "Upper Toxicity Boundary",
                      "Lower Efficacy Boundary", "Trial Duration",
                      "Toxicity Assessment Window", "Efficacy Assessment Window",
                      "Accrual Rate")

  for (param in missing_params) {
    param_present <- any(grepl(param, params_in_result, ignore.case = TRUE))
    expect_false(param_present)
  }
})
