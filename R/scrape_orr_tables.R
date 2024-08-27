#' For a provided url, return a table of urls of uploaded ODS and CSV files
#' @name extract_orr_urls
#' @param url URL of the web page to scrape urls from.
#' @return a table containing three columns, the collection url, the document url and the time of collection
#' @export
#' @import dplyr
#' @importFrom purrr map map_df
#' @importFrom Rmpfr mpfr

extract_orr_urls <- function(url = "https://dataportal.orr.gov.uk/statistics/usage/passenger-rail-usage/"){

  # Extract the splash page URLs from the landing page
names =  extract_orr_pages(url) %>%
 ##Extract the actual table links from each of the splash pages and create a table
    tibble::tibble(
      file_name = purrr::map_vec(.x = .,
                                 .f = extract_orr_pages),
      collection = url) %>%
  dplyr::rename("table_name" = ".")

}
