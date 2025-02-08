# ====================
# plotting_functions.R
# ====================

#' Plot Category Counts Comparison
#'
#' Creates a bar plot comparing accessibility category counts across sites
#'
#' @param wave_data List. WAVE analysis results
#' @param sites_df Data frame. Site information
#' @param theme Character string. Visual theme for plot
#'
#' @return ggplot object showing category comparisons
#' @keywords internal
plot_category_counts <- function(wave_data, sites_df, theme = "light") {
  # Extract category counts
  category_data <- map_df(seq_along(wave_data), function(i) {
    data <- wave_data[[i]]
    categories <- data$categories

    tibble(
      site_name = sites_df$site_name[i],
      category = names(categories),
      count = sapply(categories, function(x) x$count)
    )
  })

  # Create the plot
  p <- ggplot(category_data, aes(x = category, y = count, fill = site_name)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(
      title = "Accessibility Categories Comparison",
      x = "Category",
      y = "Count",
      fill = "Website"
    ) +
    scale_fill_brewer(palette = "Set2") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(hjust = 0.5)
    )

  return(p)
}

#' Plot Detailed Issue Comparison
#'
#' Creates a faceted bar plot showing detailed accessibility issues
#'
#' @param wave_data List. WAVE analysis results
#' @param sites_df Data frame. Site information
#' @param theme Character string. Visual theme for plot
#'
#' @return ggplot object showing issue details
#' @keywords internal
plot_issue_details <- function(wave_data, sites_df, theme = "light") {
  # Extract issue details
  issue_data <- map_df(seq_along(wave_data), function(i) {
    data <- wave_data[[i]]

    # Only process if items exist in the data
    if (!is.null(data$categories$error$items)) {
      issues <- bind_rows(
        process_category_items(data$categories$error$items, "error"),
        process_category_items(data$categories$alert$items, "alert")
      )

      issues$site_name <- sites_df$site_name[i]
      return(issues)
    }
    return(NULL)
  })

  # Create the plot
  p <- ggplot(issue_data, aes(x = reorder(issue, count), y = count, fill = type)) +
    geom_bar(stat = "identity") +
    facet_wrap(~site_name) +
    coord_flip() +
    labs(
      title = "Detailed Accessibility Issues",
      x = "Issue Type",
      y = "Count",
      fill = "Category"
    ) +
    scale_fill_manual(values = c("error" = "#FF9999", "alert" = "#FFB366")) +
    theme_minimal() +
    theme(
      axis.text.y = element_text(size = 8),
      plot.title = element_text(hjust = 0.5)
    )

  return(p)
}

#' Plot Structural Element Comparison
#'
#' Creates a bar plot comparing structural elements across sites
#'
#' @param wave_data List. WAVE analysis results
#' @param sites_df Data frame. Site information
#' @param theme Character string. Visual theme for plot
#'
#' @return ggplot object showing structural element comparison
#' @keywords internal
plot_structure_comparison <- function(wave_data, sites_df, theme = "light") {
  # Extract structural elements
  structure_data <- map_df(seq_along(wave_data), function(i) {
    data <- wave_data[[i]]

    if (!is.null(data$categories$structure$items)) {
      structures <- data.frame(
        element = names(data$categories$structure$items),
        count = sapply(data$categories$structure$items, function(x) x$count),
        site_name = sites_df$site_name[i],
        stringsAsFactors = FALSE
      )
      return(structures)
    }
    return(NULL)
  })

  # Create the plot
  p <- ggplot(structure_data, aes(x = element, y = count, fill = site_name)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(
      title = "Structural Elements Comparison",
      x = "Element Type",
      y = "Count",
      fill = "Website"
    ) +
    scale_fill_brewer(palette = "Set3") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(hjust = 0.5)
    )

  return(p)
}
