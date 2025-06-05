
test_that("format_boinet_results works correctly", {
  # Create mock boinet result for testing
  mock_result <- list(
    toxprob = c("1" = 0.1, "2" = 0.2, "3" = 0.3),
    effprob = c("1" = 0.2, "2" = 0.4, "3" = 0.6),
    n.patient = c("1" = 5.0, "2" = 8.0, "3" = 6.0),
    prop.select = c("1" = 20.0, "2" = 60.0, "3" = 20.0),
    phi = 0.3,
    delta = 0.6,
    duration = 100,
    prop.stop = 5.0
  )
  class(mock_result) <- "tite.boinet"

  # Test list format (should return unchanged)
  result_list <- format_boinet_results(mock_result, "list")
  expect_identical(result_list, mock_result)

  # Test tidy format
  result_tidy <- format_boinet_results(mock_result, "tidy")
  expect_type(result_tidy, "list")
  expect_true("operating_characteristics" %in% names(result_tidy))
  expect_true("design_parameters" %in% names(result_tidy))
  expect_true("original_result" %in% names(result_tidy))
  expect_s3_class(result_tidy$operating_characteristics, "tbl_df")

  # Test gt_ready format (skip if gt not available)
  skip_if_not_installed("gt")
  result_gt <- format_boinet_results(mock_result, "gt_ready")
  expect_type(result_gt, "list")
  expect_true("oc_table" %in% names(result_gt))
  expect_true("design_table" %in% names(result_gt))
  expect_true("data" %in% names(result_gt))
  expect_s3_class(result_gt$oc_table, "gt_tbl")
})

test_that("format_boinet_results works with all boinet types", {
  # Test with different class types
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

  # Test each class
  boinet_classes <- c("boinet", "tite.boinet", "gboinet", "tite.gboinet")

  for (class_name in boinet_classes) {
    class(mock_result) <- class_name

    # Test tidy format works for all types
    result_tidy <- format_boinet_results(mock_result, "tidy")
    expect_type(result_tidy, "list")
    expect_s3_class(result_tidy$operating_characteristics, "tbl_df")

    # Test list format works for all types
    result_list <- format_boinet_results(mock_result, "list")
    expect_s3_class(result_list, class_name)
  }
})

test_that("create_boinet_tables works correctly", {
  mock_result <- list(
    toxprob = c("1" = 0.1, "2" = 0.2),
    effprob = c("1" = 0.2, "2" = 0.4),
    n.patient = c("1" = 5.0, "2" = 8.0),
    prop.select = c("1" = 40.0, "2" = 60.0),
    phi = 0.3, delta = 0.6, duration = 100, prop.stop = 5.0
  )
  class(mock_result) <- "tite.boinet"

  skip_if_not_installed("gt")

  # Test with default titles
  tables_default <- create_boinet_tables(mock_result)
  expect_type(tables_default, "list")
  expect_true("oc_table" %in% names(tables_default))
  expect_true("design_table" %in% names(tables_default))
  expect_s3_class(tables_default$oc_table, "gt_tbl")

  # Test with custom titles
  tables_custom <- create_boinet_tables(
    mock_result,
    oc_title = "Custom OC Title",
    design_title = "Custom Design Title"
  )
  expect_type(tables_custom, "list")
  expect_s3_class(tables_custom$oc_table, "gt_tbl")
})

test_that("extract_boinet_data works correctly", {
  mock_result <- list(
    toxprob = c("1" = 0.1, "2" = 0.2),
    effprob = c("1" = 0.2, "2" = 0.4),
    n.patient = c("1" = 5.0, "2" = 8.0),
    prop.select = c("1" = 40.0, "2" = 60.0),
    phi = 0.3, delta = 0.6, duration = 100, prop.stop = 5.0
  )
  class(mock_result) <- "gboinet"

  tidy_data <- extract_boinet_data(mock_result)
  expect_type(tidy_data, "list")
  expect_true("operating_characteristics" %in% names(tidy_data))
  expect_true("design_parameters" %in% names(tidy_data))
  expect_s3_class(tidy_data$operating_characteristics, "tbl_df")
})

test_that("result formatting functions require correct input class", {
  wrong_input <- list(a = 1, b = 2)

  expect_error(
    format_boinet_results(wrong_input),
    "Input must be a boinet result object"
  )

  expect_error(
    create_boinet_tables(wrong_input),
    "Input must be a boinet result object"
  )

  expect_error(
    extract_boinet_data(wrong_input),
    "Input must be a boinet result object"
  )
})

test_that("format_boinet_results validates output_format parameter", {
  mock_result <- list(
    toxprob = c("1" = 0.1),
    effprob = c("1" = 0.2),
    n.patient = c("1" = 5.0),
    prop.select = c("1" = 100.0),
    phi = 0.3, delta = 0.6, prop.stop = 0.0
  )
  class(mock_result) <- "boinet"

  # Test invalid format
  expect_error(
    format_boinet_results(mock_result, "invalid_format"),
    "should be one of"
  )

  # Test default format
  result_default <- format_boinet_results(mock_result)
  expect_identical(result_default, mock_result)  # Should default to "list"
})

test_that("summary methods work correctly for all types", {
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

  # Test summary for each class
  boinet_classes <- c("boinet", "tite.boinet", "gboinet", "tite.gboinet")
  expected_titles <- c("BOIN-ET", "TITE-BOIN-ET", "gBOIN-ET", "TITE-gBOIN-ET")

  for (i in seq_along(boinet_classes)) {
    class(mock_result) <- boinet_classes[i]
    expect_output(summary(mock_result), expected_titles[i])
    expect_invisible(summary(mock_result))
  }
})
