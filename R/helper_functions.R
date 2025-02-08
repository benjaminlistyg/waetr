# ====================
# helper_functions.R
# ====================

#' Process Category Items
#'
#' Internal helper function to process WAVE category items
#'
#' @param items List. Category items from WAVE results
#' @param category_type Character string. Type of category being processed
#'
#' @return Tibble containing processed item data
#' @keywords internal
process_category_items <- function(items, category_type) {
  if (is.null(items) || length(items) == 0) {
    return(NULL)
  }

  tibble(
    issue = sapply(items, function(x) x$description),
    count = sapply(items, function(x) x$count),
    type = category_type
  )
}
