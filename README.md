# waetr: Web Accessibility Evaluation Tools in R

<img src="man/figures/logo.png" align="right" height="150" />

## Overview

waetr is an R package that provides a comprehensive interface to the [WAVE](https://wave.webaim.org/) (Web Accessibility Evaluation) API. It enables automated accessibility testing of web pages with support for batch processing, detailed reporting, and data visualization.

## Features

- Direct interface with WAVE API
- Support for batch URL processing
- Multiple visualization types for accessibility metrics
- Comprehensive HTML report generation
- Data export in multiple formats
- Customizable analysis parameters

## Installation

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install waetr from GitHub
devtools::install_github("benjaminlistyg/waetr")
```

## Prerequisites

- A WAVE API key (obtain from [WebAIM WAVE API](https://wave.webaim.org/api/))
- R version 3.5.0 or higher
- Required R packages (automatically installed):
  - ggplot2
  - dplyr
  - tidyr
  - purrr
  - httr
  - jsonlite
  - progress

## Basic Usage

### Single URL Analysis

```r
library(waetr)

# Analyze a single URL
result <- wave(
  key = "your_api_key",
  url = "https://example.com"
)

# View summary statistics
print(result$statistics)
```

### Batch Analysis

```r
# Analyze multiple URLs
urls <- c(
  "https://example.com",
  "https://example.org",
  "https://example.net"
)

# Generate comprehensive report
report <- create_accessibility_report(
  input = urls,
  api_key = "your_api_key",
  output_dir = "accessibility_report"
)
```

### Visualizations

```r
# Compare accessibility categories
compare_accessibility(
  input = urls,
  api_key = "your_api_key",
  plot_type = "category_counts"
)

# View detailed issues
compare_accessibility(
  input = urls,
  api_key = "your_api_key",
  plot_type = "issues"
)

# Compare structural elements
compare_accessibility(
  input = urls,
  api_key = "your_api_key",
  plot_type = "structure"
)
```

## Function Documentation

### Main Functions

- `wave()`: Core function for making WAVE API requests
- `compare_accessibility()`: Generate accessibility comparisons across websites
- `create_accessibility_report()`: Create comprehensive accessibility reports

### Visualization Functions

- Plot Types:
  - `category_counts`: Compare main accessibility categories
  - `issues`: Detailed breakdown of errors and alerts
  - `structure`: Compare structural elements

### Report Generation

The `create_accessibility_report()` function generates:
- HTML report with interactive visualizations
- CSV summary data
- PNG plot files
- Detailed accessibility metrics

## API Credits

The WAVE API uses a credit system:
- Report Type 1: 1 credit per URL
- Report Type 2: 2 credits per URL
- Report Type 3/4: 3 credits per URL

Monitor your credit usage with:
```r
check_wave_credits("your_api_key")
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

Steps to contribute:
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Running Tests

```r
# Run all tests
devtools::test()

# Run specific test file
devtools::test(filter = "wave")
```

## Code of Conduct

Please note that the waetr project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- WebAIM for providing the WAVE API
- R community for package development tools and guidance
- All contributors and users of the package

## Contact

For questions and feedback:
- Open an issue on GitHub: https://github.com/benjaminlistyg/waetr/issues
- Email: Submit an issue for contact information

## Citation

If you use waetr in your research, please cite it as:

```
Ross, B.V., & Listyg, B. (2024). waetr: R Package for Web Accessibility Evaluation Testing. 
GitHub repository: https://github.com/benjaminlistyg/waetr
```
