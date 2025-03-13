# waetr 0.1.0

## Initial CRAN submission

* Added core functions for WebAIM WAVE API interaction:
  * `wave()` - Main function to analyze websites for accessibility issues
  * `check_wave_credits()` - Function to check remaining API credits
  * `fetch_wave_data()` - Function to retrieve accessibility data from WAVE API or JSON files
  * `compare_accessibility()` - Function to compare accessibility metrics across websites
  * `create_accessibility_report()` - Function to generate comprehensive accessibility reports

* Implemented visualization capabilities:
  * Category count comparisons
  * Detailed accessibility issue analysis
  * Structural element comparisons
  
* Added utility functions for file handling and data processing
  * JSON file import/export
  * Report generation and formatting
  
* Included comprehensive documentation and examples

---

Note: This is the first release of the waetr package, providing an R interface to the WebAIM WAVE accessibility evaluation API.
