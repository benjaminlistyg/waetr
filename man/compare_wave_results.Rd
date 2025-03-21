% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compare_wave_results.R
\name{compare_wave_results}
\alias{compare_wave_results}
\title{Process and Visualize WAVE Results}
\usage{
compare_wave_results(
  wave_data,
  site_names = NULL,
  plot_type = c("category_counts", "issues", "structure"),
  theme = "light"
)
}
\arguments{
\item{wave_data}{List. WAVE analysis results}

\item{site_names}{Character vector. Names for each site}

\item{plot_type}{Character string. Type of visualization to generate}

\item{theme}{Character string. Visual theme for plot}
}
\value{
ggplot object containing the visualization
}
\description{
Internal function to process WAVE data and create visualizations
}
\keyword{internal}
