#' Access WebAIM WAVE Accessibility API
#'
#' This function provides an interface to the WebAIM WAVE accessibility evaluation API.
#' It allows you to analyze web pages for accessibility issues and retrieve detailed reports.
#'
#' @param key Character string. Your WAVE API key
#' @param url Character string. URL of the webpage to analyze
#' @param format Character string. Response format (optional)
#' @param viewportwidth Integer. Viewport width for analysis (optional)
#' @param reporttype Integer. Type of report to generate (1-4) (optional)
#' @param username Character string. Username for protected pages (optional)
#' @param password Character string. Password for protected pages (optional)
#' @param useragent Character string. Custom user agent (optional)
#' @param toDataframe Logical. Whether to convert results to a data frame (default: FALSE)
#' @param file Character string. Optional file path to save JSON results
#'
#' @return List or tibble containing WAVE analysis results
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' results <- wave(key = "your_api_key", url = "https://example.com")
#'
#' # Get results as a data frame
#' df_results <- wave(key = "your_api_key", url = "https://example.com", toDataframe = TRUE)
#'
#' # Save results to a temporary file
#' tmp_file <- file.path(tempdir(), "wave_results.json")
#' wave(key = "your_api_key", url = "https://example.com", file = tmp_file)
#' }
wave <- function(key,
                 url,
                 format = NULL,
                 viewportwidth = NULL,
                 reporttype = NULL,
                 username = NULL,
                 password = NULL,
                 useragent = NULL,
                 toDataframe = FALSE,
                 file = NULL) {

  # Check if the key is provided
  if (missing(key)) {
    stop("Please provide a valid API key.")
  }

  # Check if the URL is provided
  if (missing(url)) {
    stop("Please provide a valid URL.")
  }

  # Set the base URL and query parameters
  base_url <- "http://wave.webaim.org/api/request"
  query_params <- list(
    key = key,
    url = url,
    format = format,
    viewportwidth = viewportwidth,
    reporttype = reporttype,
    username = username,
    password = password,
    useragent = useragent
  )

  # Remove NULL parameters
  query_params <- query_params[!sapply(query_params, is.null)]

  # Make the API request
  response <- httr::GET(base_url, query = query_params)

  # Check if the request was successful
  if (httr::status_code(response) != 200) {
    stop("API request failed. Please check your API key and URL.")
  }

  # Extract the response content as text
  response_text <- httr::content(response, as = "text", encoding = "UTF-8")

  # Remove the BOM (Byte Order Mark) character if present
  response_text <- sub("^\xef\xbb\xbf", "", response_text)

  # Parse the JSON response
  data <- jsonlite::fromJSON(response_text)

  # If file is provided, save the data as JSON
  if (!is.null(file)) {
    jsonlite::write_json(data, path = file, pretty = TRUE)
    message(paste("Data saved as JSON file:", file))
  }

  # If toDataframe is TRUE, convert the data to a tidy data frame
  if (toDataframe) {
    # Initialize an empty data frame
    output_data <- tibble::tibble()

    # Iterate over each category in the data
    for (cat in names(data)) {
      # Check if the category is a list
      if (is.list(data[[cat]])) {
        # Iterate over each subcategory in the category
        for (subcat in names(data[[cat]])) {
          # Check if the subcategory is a list
          if (is.list(data[[cat]][[subcat]])) {
            # Iterate over each item in the subcategory
            for (item in names(data[[cat]][[subcat]])) {
              # Create a tibble for the item and add it to the output data frame
              item_data <- tibble::tibble(
                category = cat,
                subcategory = subcat,
                item = item,
                value = as.character(unlist(data[[cat]][[subcat]][[item]]))
              )
              output_data <- dplyr::bind_rows(output_data, item_data)
            }
          } else {
            # Create a tibble for the subcategory and add it to the output data frame
            subcat_data <- tibble::tibble(
              category = cat,
              subcategory = subcat,
              item = NA,
              value = as.character(unlist(data[[cat]][[subcat]]))
            )
            output_data <- dplyr::bind_rows(output_data, subcat_data)
          }
        }
      } else {
        # Create a tibble for the category and add it to the output data frame
        cat_data <- tibble::tibble(
          category = cat,
          subcategory = NA,
          item = NA,
          value = as.character(unlist(data[[cat]]))
        )
        output_data <- dplyr::bind_rows(output_data, cat_data)
      }
    }
    return(output_data)
  }

  # If toDataframe is FALSE (default), return the original list
  return(data)
}
