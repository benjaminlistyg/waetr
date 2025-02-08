# ====================
# compare_wave_results.R
# ====================

#' Process and Visualize WAVE Results
#'
#' Internal function to process WAVE data and create visualizations
#'
#' @param wave_data List. WAVE analysis results
#' @param site_names Character vector. Names for each site
#' @param plot_type Character string. Type of visualization to generate
#' @param theme Character string. Visual theme for plot
#'
#' @return ggplot object containing the visualization
#' @keywords internal
compare_wave_results <- function(wave_data,
                                 site_names = NULL,
                                 plot_type = c("category_counts", "issues", "structure"),
                                 theme = "light") {

  # Match plot type argument
  plot_type <- match.arg(plot_type)

  # If wave_data is a list of file paths, read the JSON files
  if (is.character(wave_data)) {
    wave_data <- lapply(wave_data, jsonlite::fromJSON)
  }

  # If site names not provided, generate default names
  if (is.null(site_names)) {
    site_names <- paste("Site", seq_along(wave_data))
  }

  # Create a data frame mapping sites to their data
  sites_df <- data.frame(
    site_name = site_names,
    site_url = sapply(wave_data, function(x) x$statistics$pageurl),
    stringsAsFactors = FALSE
  )

  # Choose the appropriate visualization based on plot_type
  if (plot_type == "category_counts") {
    p <- plot_category_counts(wave_data, sites_df, theme)
  } else if (plot_type == "issues") {
    p <- plot_issue_details(wave_data, sites_df, theme)
  } else if (plot_type == "structure") {
    p <- plot_structure_comparison(wave_data, sites_df, theme)
  }

  return(p)
}
