#' Compare Website Accessibility
#'
#' Main function to generate accessibility comparisons across multiple websites
#'
#' @param input Character vector. URLs to analyze or paths to JSON files
#' @param api_key Character string. WAVE API key (required for URL analysis)
#' @param site_names Character vector. Optional custom names for sites
#' @param plot_type Character string. Type of visualization:
#'   - "category_counts": Compare main accessibility categories
#'   - "issues": Detailed breakdown of errors and alerts
#'   - "structure": Compare structural elements
#' @param report_type Integer. WAVE report type (1-4)
#' @param theme Character string. Visual theme for plot (default: "light")
#'
#' @return ggplot object containing the requested visualization
#' @export
#'
#' @examples
#' \dontrun{
#' # Compare multiple websites
#' p <- compare_accessibility(
#'   input = c("https://example.com", "https://example.org"),
#'   api_key = "your_api_key",
#'   plot_type = "category_counts"
#' )
#' }
compare_accessibility <- function(input,
                                  api_key = NULL,
                                  site_names = NULL,
                                  plot_type = c("category_counts", "issues", "structure"),
                                  report_type = 1,
                                  theme = "light") {

  # Determine if input is JSON files
  is_json <- all(file.exists(input))

  # Fetch data
  wave_data <- fetch_wave_data(
    input = input,
    api_key = api_key,
    report_type = report_type,
    is_json = is_json
  )

  # Generate default site names if not provided
  if (is.null(site_names)) {
    if (is_json) {
      site_names <- basename(input[1:length(wave_data)])
    } else {
      site_names <- input[1:length(wave_data)]
    }
  }

  # Create visualization
  p <- compare_wave_results(
    wave_data = wave_data,
    site_names = site_names,
    plot_type = plot_type,
    theme = theme
  )

  return(p)
}
