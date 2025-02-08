library(testthat)

test_that("wave function returns the expected output", {
  # Test case 1: Valid API key and URL
  result <- wave(key = "your_api_key", url = "https://example.com", toDataframe = TRUE)
  expect_is(result, "tbl_df")
  expect_gt(nrow(result), 0)
  expect_named(result, c("category", "subcategory", "item", "value"))
  
  # Test case 2: Missing API key
  expect_error(wave(url = "https://example.com"), "Please provide a valid API key.")
  
  # Test case 3: Missing URL
  expect_error(wave(key = "your_api_key"), "Please provide a valid URL.")
  
  # Test case 4: Invalid API key or URL
  expect_error(wave(key = "invalid_key", url = "https://example.com"), "API request failed. Please check your API key and URL.")
  
  # Test case 5: Return original list when toDataframe is FALSE
  result <- wave(key = "your_api_key", url = "https://example.com", toDataframe = FALSE)
  expect_is(result, "list")
  expect_gt(length(result), 0)
})