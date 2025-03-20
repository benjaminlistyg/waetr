# ====================
# report_generation.R
# ====================

#' Create Comprehensive Accessibility Report
#'
#' Generates a complete accessibility report with visualizations and summary data
#'
#' @param input Character vector. URLs to analyze or paths to JSON files
#' @param api_key Character string. WAVE API key (required for URL analysis)
#' @param output_dir Character string. Directory to save report files
#' @param report_type Integer. WAVE report type (1-4)
#' @param include_plots Logical. Whether to include plots in the report (default: TRUE)
#' @param custom_theme Character string. Visual theme for plots (default: "light")
#'
#' @return List containing plots and summary data frame
#' @export
#'
#' @examples
#' \dontrun{
#' report <- create_accessibility_report(
#'   input = c("https://example.com", "https://example.org"),
#'   api_key = "your_api_key",
#'   output_dir = tempdir()
#' )
#' }
create_accessibility_report <- function(input,
                                        api_key = NULL,
                                        output_dir = NULL,
                                        report_type = 1,
                                        include_plots = TRUE,
                                        custom_theme = "light") {

  # Use tempdir() if output_dir is NULL
  if (is.null(output_dir)) {
    output_dir <- tempdir()
  }

  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Initialize results list
  results <- list(
    metadata = list(
      timestamp = Sys.time(),
      input_sources = input,
      report_type = report_type
    ),
    plots = list(),
    summary = NULL,
    report_file = NULL
  )

  # Generate plots if requested
  if (include_plots) {
    plot_types <- c("category_counts", "issues", "structure")

    for (type in plot_types) {
      tryCatch({
        p <- compare_accessibility(
          input = input,
          api_key = api_key,
          plot_type = type,
          report_type = report_type,
          theme = custom_theme
        )

        # Save plot
        filename <- generate_report_filename("accessibility", type)
        plot_path <- file.path(output_dir, filename)
        ggsave(plot_path, p, width = 10, height = 6)

        # Store plot in results
        results$plots[[type]] <- list(
          plot = p,
          file = plot_path
        )
      }, error = function(e) {
        warning(sprintf("Failed to generate %s plot: %s", type, e$message))
      })
    }
  }

  # Create summary data frame
  results$summary <- create_summary_data(input, api_key, report_type)

  # Save summary as CSV
  summary_filename <- generate_report_filename("accessibility_summary", "data", "csv")
  summary_path <- file.path(output_dir, summary_filename)
  write.csv(results$summary, summary_path, row.names = FALSE)

  # Generate HTML report
  report_filename <- generate_report_filename("accessibility_report", "full", "html")
  report_path <- file.path(output_dir, report_filename)

  # Create HTML report content
  html_content <- create_html_report(
    results = results,
    input = input,
    report_type = report_type
  )

  # Save HTML report
  writeLines(html_content, report_path)
  results$report_file <- report_path

  # Add report metadata
  results$metadata$files <- list(
    summary = summary_path,
    report = report_path,
    plots = if (include_plots) sapply(results$plots, function(x) x$file) else NULL
  )

  return(results)
}

#' Create HTML Report
#'
#' Internal function to generate HTML report content
#'
#' @param results List. Analysis results and plots
#' @param input Character vector. Input URLs or files
#' @param report_type Integer. WAVE report type used
#'
#' @return Character string containing HTML content
#' @keywords internal
create_html_report <- function(results, input, report_type) {
  # Create HTML header
  html <- c(
    "<!DOCTYPE html>",
    "<html>",
    "<head>",
    "<title>WAVE Accessibility Report</title>",
    "<style>",
    "body { font-family: Arial, sans-serif; margin: 40px; }",
    "table { border-collapse: collapse; width: 100%; margin: 20px 0; }",
    "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }",
    "th { background-color: #f2f2f2; }",
    "img { max-width: 100%; height: auto; margin: 20px 0; }",
    ".summary { margin: 20px 0; }",
    ".plot-section { margin: 30px 0; }",
    "</style>",
    "</head>",
    "<body>"
  )

  # Add report header
  html <- c(html,
            sprintf("<h1>WAVE Accessibility Report</h1>"),
            sprintf("<p>Generated: %s</p>", format(results$metadata$timestamp, "%Y-%m-%d %H:%M:%S")),
            sprintf("<p>Report Type: %d</p>", report_type),
            "<h2>Analyzed Sources</h2>",
            "<ul>"
  )

  # Add input sources
  html <- c(html,
            sapply(input, function(x) sprintf("<li>%s</li>", x)),
            "</ul>"
  )

  # Add summary section
  if (!is.null(results$summary)) {
    html <- c(html,
              "<h2>Summary Statistics</h2>",
              "<div class='summary'>",
              create_html_table(results$summary),
              "</div>"
    )
  }

  # Add plots section if available
  if (length(results$plots) > 0) {
    html <- c(html, "<h2>Visualizations</h2>")

    for (plot_type in names(results$plots)) {
      plot_info <- results$plots[[plot_type]]
      html <- c(html,
                "<div class='plot-section'>",
                sprintf("<h3>%s</h3>", tools::toTitleCase(gsub("_", " ", plot_type))),
                sprintf("<img src='%s' alt='%s visualization'>",
                        basename(plot_info$file),
                        plot_type),
                "</div>"
      )
    }
  }

  # Close HTML
  html <- c(html,
            "</body>",
            "</html>"
  )

  return(paste(html, collapse = "\n"))
}

#' Create HTML Table
#'
#' Internal function to convert data frame to HTML table
#'
#' @param df Data frame to convert
#'
#' @return Character string containing HTML table
#' @keywords internal
create_html_table <- function(df) {
  # Create table header
  html <- c("<table>",
            "<tr>",
            sprintf("<th>%s</th>", names(df)),
            "</tr>")

  # Add table rows
  for (i in 1:nrow(df)) {
    html <- c(html,
              "<tr>",
              sprintf("<td>%s</td>", df[i,]),
              "</tr>")
  }

  html <- c(html, "</table>")
  return(paste(html, collapse = "\n"))
}
