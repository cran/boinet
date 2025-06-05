test_that("create_oc_gt_table works correctly", {
  skip_if_not_installed("gt")

  mock_result <- list(
    toxprob = c("1" = 0.1, "2" = 0.2),
    effprob = c("1" = 0.2, "2" = 0.4),
    n.patient = c("1" = 5.0, "2" = 8.0),
    prop.select = c("1" = 40.0, "2" = 60.0),
    phi = 0.3,
    delta = 0.6,
    duration = 100,
    prop.stop = 5.0
  )
  class(mock_result) <- "tite.boinet"

  gt_table <- create_oc_gt_table(mock_result)

  expect_s3_class(gt_table, "gt_tbl")
})

test_that("create_design_gt_table works correctly", {
  skip_if_not_installed("gt")

  mock_result <- list(
    toxprob = c("1" = 0.1, "2" = 0.2),
    effprob = c("1" = 0.2, "2" = 0.4),
    n.patient = c("1" = 5.0, "2" = 8.0),
    prop.select = c("1" = 40.0, "2" = 60.0),
    phi = 0.3,
    delta = 0.6,
    duration = 100,
    prop.stop = 5.0,
    lambda1 = 0.1,
    lambda2 = 0.4,
    eta1 = 0.2,
    tau.T = 30,
    tau.E = 45,
    accrual = 2
  )
  class(mock_result) <- "gboinet"

  gt_table <- create_design_gt_table(mock_result, title = "Custom Title")

  expect_s3_class(gt_table, "gt_tbl")
})

test_that("gt functions fail gracefully without gt package", {
  # Test input validation first
  expect_error(
    create_oc_gt_table(list()),
    "boinet result object"
  )

  # Note: Full gt unavailability testing requires manual verification
  # when gt package is not installed
})

test_that("gt tables work with all boinet types", {
  skip_if_not_installed("gt")

  mock_result <- list(
    toxprob = c("1" = 0.1, "2" = 0.2),
    effprob = c("1" = 0.2, "2" = 0.4),
    n.patient = c("1" = 5.0, "2" = 8.0),
    prop.select = c("1" = 40.0, "2" = 60.0),
    phi = 0.3,
    delta = 0.6,
    duration = 100,
    prop.stop = 5.0,
    lambda1 = 0.1,
    lambda2 = 0.4,
    eta1 = 0.2,
    tau.T = 30,
    tau.E = 45,
    accrual = 2
  )

  boinet_classes <- c("boinet", "tite.boinet", "gboinet", "tite.gboinet")

  for (class_name in boinet_classes) {
    class(mock_result) <- class_name
    expect_s3_class(create_oc_gt_table(mock_result), "gt_tbl")
    expect_s3_class(create_design_gt_table(mock_result), "gt_tbl")
  }
})

test_that("compare_scenarios_gt works correctly", {
  skip("compare_scenarios_gt function not yet implemented")
})
