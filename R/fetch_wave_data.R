#' Fetch WAVE Analysis Data
#'
#' Retrieves accessibility analysis data either from WAVE API or local JSON files
#'
#' @param input Character vector. Either URLs to analyze or paths to JSON files
#' @param api_key Character string. WAVE API key (required for URL analysis)
#' @param report_type Integer. WAVE report type (1-4):
#'   - 1: Basic statistics only (1 credit)
#'   - 2: Includes WAVE items (2 credits)
#'   - 3: Includes XPath data (3 credits)
#'   - 4: Includes CSS selector data (3 credits)
#' @param is_json Logical. Whether input contains JSON file paths (default: FALSE)
#' @param delay Numeric. Delay between API calls in seconds (default: 1)
#'
#' @return List of WAVE analysis results
#' @export
#'
#' @examples
#' \dontrun{
#' # Fetch from URLs
#' results <- fetch_wave_data(
#'   input = c("https://example.com", "https://example.org"),
#'   api_key = "your_api_key"
#' )
#'
#' # Load from JSON files
#' json_results <- fetch_wave_data(
#'   input = c("site1.json", "site2.json"),
#'   is_json = TRUE
#' )
#' }
fetch_wave_data <- function(input,
                            api_key = NULL,
                            report_type = 1,
                            is_json = FALSE,
                            delay = 1) {

  if (!is_json && is.null(api_key)) {
    stop("API key is required for URL analysis")
  }

  results <- list()

  for (i in seq_along(input)) {
    if (is_json) {
      # Read JSON file
      tryCatch({
        data <- jsonlite::fromJSON(input[i])
        results[[i]] <- data
      }, error = function(e) {
        warning(sprintf("Failed to read JSON file %s: %s", input[i], e$message))
        return(NULL)
      })
    } else {
      # Make API request
      url <- paste0(
        "https://wave.webaim.org/api/request?",
        sprintf("key=%s&url=%s&reporttype=%d",
                api_key,
                utils::URLencode(input[i]),
                report_type)
      )

      tryCatch({
        response <- httr::GET(url)
        httr::stop_for_status(response)
        data <- httr::content(response, "parsed")
        results[[i]] <- data

        # Respect rate limiting
        if (i < length(input)) {
          Sys.sleep(delay)
        }
      }, error = function(e) {
        warning(sprintf("Failed to fetch data for URL %s: %s", input[i], e$message))
        return(NULL)
      })
    }
  }

  # Remove NULL results
  results <- Filter(Negate(is.null), results)
  return(results)
}
