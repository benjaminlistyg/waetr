# ====================
# utils.R
# ====================

#' Generate WAVE Report Filename
#'
#' Creates a standardized filename for WAVE reports
#'
#' @param base_name Character string. Base name for the file
#' @param type Character string. Type of report
#' @param ext Character string. File extension
#'
#' @return Character string containing formatted filename
#' @keywords internal
#'
generate_report_filename <- function(base_name, type, ext = "png") {
  clean_name <- gsub("[^[:alnum:]]", "_", base_name)
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  sprintf("%s_%s_%s.%s", clean_name, type, timestamp, ext)
}

#' Check WAVE API Credits
#'
#' Checks remaining WAVE API credits for the provided key
#'
#' @param api_key Character string. WAVE API key
#'
#' @return Numeric value of remaining credits
#' @export
#'
#' @examples
#' \dontrun{
#' credits <- check_wave_credits("your_api_key")
#' print(sprintf("Remaining credits: %d", credits))
#' }
check_wave_credits <- function(api_key) {
  if (is.null(api_key)) {
    stop("API key is required")
  }

  # Make a minimal API call to check credits
  url <- paste0(
    "https://wave.webaim.org/api/request?",
    sprintf("key=%s&url=%s&reporttype=1",
            api_key,
            utils::URLencode("https://example.com"))
  )

  tryCatch({
    response <- httr::GET(url)
    httr::stop_for_status(response)
    data <- httr::content(response, "parsed")
    return(data$statistics$creditsremaining)
  }, error = function(e) {
    warning(sprintf("Failed to check API credits: %s", e$message))
    return(NULL)
  })
}

#' Calculate Required API Credits
#'
#' Calculates total API credits needed for analysis
#'
#' @param n_urls Integer. Number of URLs to analyze
#' @param report_type Integer. WAVE report type (1-4)
#'
#' @return Integer value of required credits
#' @keywords internal
calculate_required_credits <- function(n_urls, report_type = 1) {
  credits_per_url <- switch(as.character(report_type),
                            "1" = 1,
                            "2" = 2,
                            "3" = 3,
                            "4" = 3,
                            1)  # default to 1 if invalid report type

  return(n_urls * credits_per_url)
}

#' Validate WAVE Parameters
#'
#' Validates input parameters for WAVE API calls
#'
#' @param input Character vector. URLs or file paths
#' @param api_key Character string. WAVE API key
#' @param report_type Integer. WAVE report type
#'
#' @return Logical TRUE if valid, stops with error if invalid
#' @keywords internal
validate_wave_params <- function(input, api_key = NULL, report_type = 1) {
  # Check input
  if (length(input) == 0) {
    stop("Input cannot be empty")
  }

  # Check report type
  if (!report_type %in% 1:4) {
    stop("Report type must be between 1 and 4")
  }

  # If not using JSON files, check API key
  if (!all(file.exists(input)) && is.null(api_key)) {
    stop("API key is required for URL analysis")
  }

  return(TRUE)
}
