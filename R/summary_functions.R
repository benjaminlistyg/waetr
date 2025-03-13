#' Create Summary Data from WAVE Results
#'
#' Generates a summary data frame from WAVE accessibility results
#'
#' @param input Character vector. URLs to analyze or paths to JSON files
#' @param api_key Character string. WAVE API key (required for URL analysis)
#' @param report_type Integer. WAVE report type (1-4)
#'
#' @return Data frame containing summary statistics
#' @keywords internal
create_summary_data <- function(input, api_key = NULL, report_type = 1) {
  # Determine if input is JSON files
  is_json <- all(file.exists(input))

  # Fetch data if needed
  wave_data <- fetch_wave_data(
    input = input,
    api_key = api_key,
    report_type = report_type,
    is_json = is_json
  )

  # Initialize summary data frame
  summary_df <- data.frame(
    source = character(0),
    url = character(0),
    page_title = character(0),
    total_errors = numeric(0),
    total_alerts = numeric(0),
    total_features = numeric(0),
    total_structure = numeric(0),
    total_aria = numeric(0),
    contrast_errors = numeric(0),
    stringsAsFactors = FALSE
  )

  # Process each result
  for (i in seq_along(wave_data)) {
    data <- wave_data[[i]]
    source_name <- if (is_json) basename(input[i]) else input[i]

    # Extract key statistics
    stats <- data$statistics
    categories <- data$categories

    # Create a row for this source
    row_data <- data.frame(
      source = source_name,
      url = stats$pageurl,
      page_title = stats$pagetitle,
      total_errors = ifelse(is.null(categories$error$count), 0, categories$error$count),
      total_alerts = ifelse(is.null(categories$alert$count), 0, categories$alert$count),
      total_features = ifelse(is.null(categories$feature$count), 0, categories$feature$count),
      total_structure = ifelse(is.null(categories$structure$count), 0, categories$structure$count),
      total_aria = ifelse(is.null(categories$aria$count), 0, categories$aria$count),
      contrast_errors = ifelse(is.null(categories$contrast$count), 0, categories$contrast$count),
      stringsAsFactors = FALSE
    )

    # Add to summary data frame
    summary_df <- rbind(summary_df, row_data)
  }

  return(summary_df)
}
