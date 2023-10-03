#' For a provided url, return a table of urls of uploaded ODS and CSV files
#' @name extract_table_urls
#' @param url URL of the web page to scrape urls from. Defaults to the gov.uk stats homepage
#' @return a table containing three columns, the collection url, the document url and the time of collection
#' @export
#' @import dplyr
#' @importFrom purrr map map_df

extract_table_urls <- function(url = "https://www.gov.uk/government/organisations/department-for-transport/about/statistics"){
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
                  upload_id = gsub("^.*file[/]", "", urls),
                  upload_id = as.numeric(gsub("/.*", "", upload_id))) %>%
    ##Group and slice to keep the highest upload no
    dplyr::group_by(file_name) %>%
    dplyr::arrange(desc(upload_no)) %>%
    dplyr::slice(1L) %>%
    ##Add process time
    dplyr::mutate(time_of_check = Sys.time()) %>%
    dplyr::rename(collection_url = collection, doc_url = urls)
}

