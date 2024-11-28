#' For a provided url, return a table of urls of uploaded ODS and CSV files
#' @name extract_orr_urls
#' @param url URL of the web page to scrape urls from.
#' @return a table containing three columns, the collection url, the document url and the time of collection
#' @export
#' @import dplyr
#' @importFrom tibble tibble
#' @importFrom purrr map_vec

extract_orr_urls <- function(url = "https://dataportal.orr.gov.uk/statistics/usage/passenger-rail-usage/"){

    # Extract the splash page URLs from the landing page
 extract_orr_pages(url) %>%
   ##Extract the actual table links from each of the splash pages and create a table
      tibble::tibble(
        doc_url = purrr::map_vec(.x = .,
                                   .f = extract_orr_pages),
        collection_url = url,
        upload_id = 1) %>%
    dplyr::select(-.) %>%
    ##Keep just the name after the final slash for the file name
    dplyr::mutate(file_name = gsub("(^.*[/])(.*$)", "\\2", doc_url))
}
