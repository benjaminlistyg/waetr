library(testthat)
library(mockery)

# Helper function to create mock response
mock_get_response <- function() {
  structure(
    list(
      url = "https://wave.webaim.org/api/request"
    ),
    class = "response"
  )
}

test_that("wave function validates input parameters", {
  # Test case 2: Missing API key
  expect_error(wave(url = "https://example.com"), "Please provide a valid API key.")

  # Test case 3: Missing URL
  expect_error(wave(key = "your_api_key"), "Please provide a valid URL.")
})

test_that("wave function handles API response correctly", {
  # Create a mock sample response
  sample_response <- list(
    statistics = list(
      pageurl = "https://example.com",
      pagetitle = "Example Domain",
      time = 1,
      creditsremaining = 100,
      errors = 2
    ),
    categories = list(
      error = list(count = 2),
      alert = list(count = 3),
      structure = list(count = 10)
    )
  )

  # Mock httr::GET to avoid real API calls
  stub(wave, 'httr::GET', mock_get_response())

  # Mock httr::status_code to return 200
  stub(wave, 'httr::status_code', 200)

  # Mock httr::content to return our sample JSON
  stub(wave, 'httr::content', jsonlite::toJSON(sample_response))

  # Mock jsonlite::fromJSON to return our sample data
  stub(wave, 'jsonlite::fromJSON', sample_response)

  # Test case 1: Default return value (list)
  result <- wave(key = "mock_key", url = "https://example.com")
  expect_type(result, "list")
  expect_identical(result$statistics$creditsremaining, 100)
  expect_identical(result$categories$error$count, 2)

  # Test case 4: Return as data frame
  stub(wave, 'jsonlite::fromJSON', sample_response)
  result_df <- wave(key = "mock_key", url = "https://example.com", toDataframe = TRUE)
  expect_s3_class(result_df, "data.frame")
})
