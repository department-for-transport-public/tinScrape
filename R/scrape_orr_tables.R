#' For a provided url, return a table of urls of uploaded ODS and CSV files
#' @name extract_orr_urls
#' @param url URL of the web page to scrape urls from.
#' @return a table containing three columns, the collection url, the document url and the time of collection
#' @export
#' @import dplyr
#' @importFrom purrr map map_df
#' @importFrom Rmpfr mpfr

extract_table_urls <- function(url = "https://dataportal.orr.gov.uk/statistics/usage/passenger-rail-usage/"){

  # Extract the URLs
 hyperlinks <- xml2::read_html(url) %>%
   #Return reports section
   rvest::html_nodes(xpath = "//div[contains(@class, 'reports')]") %>%
    # Get hyperlinks from reports section
   rvest::html_nodes(xpath = ".//a") %>%
    # Get the actual hyperlink attribute
    rvest::html_attr("href")

   # put together full list of tables
  purrr::map(.x = collect_collections(url),
             .f = collect_links) %>%
    purrr::map_df(.f = scrape_tables,
                  .id = "collection") %>%
    unique() %>%
    ##Drop anything that starts with a hash
    dplyr::filter(!grepl("^[#]", urls)) %>%
    ##Create columns for table name and upload number
    #Regex my fave
    ##This will strip out everything before the final slash, regex are greedy by default
    dplyr::mutate(file_name = gsub("^.*[/]", "", urls),
                  #Keep everything after the word file, then drop the file name
                  upload_id = gsub("^.*(media|file)[/]", "", urls),
                  upload_id = gsub("/.*", "", upload_id),
                  ##Deal with upload ids: sometimes these will be numerics
                  #Sometimes they will be hexadecimals
                  #Sometimes they will just make you cry
                  upload_id =
                    case_when(!is.na(as.numeric.silent(upload_id)) ~
                                as.numeric.silent(upload_id),
                              !is.na(Rmpfr::mpfr(upload_id, base = 16)) ~
                                as.numeric.silent(Rmpfr::mpfr(upload_id, base = 16)),
                              TRUE ~ as.numeric.silent(paste0("1", gsub("[^0-9]", "", upload_id))))) %>%
    ##Group and slice to keep the highest upload no
    dplyr::group_by(file_name) %>%
    dplyr::arrange(desc(upload_id)) %>%
    dplyr::slice(1L) %>%
    ##Add process time
    dplyr::mutate(time_of_check = Sys.time()) %>%
    #Simplify the upload ID to a small integer
    dplyr::mutate(upload_id = as.integer(upload_id/1e24)) %>%
    dplyr::rename(collection_url = collection, doc_url = urls) %>%
    dplyr::mutate(collection = upper_case(gsub("^.*[/]", "", collection_url)),
                  collection = gsub("-", " ", collection),
                  collection = gsub("covid 19", "(COVID-19)", collection))
}
