library(dplyr)
library(stringr)
library(rvest)
library(lubridate)
library(data.table)
library(bigrquery)


#' For a provided url, reads in the page and extracts all the link addresses from that page
#' @name scrape_links
#' @param url URL of the web page to scrape urls from
#' @importFrom xml read_html
#' @importFrom

scrape_links <- function(url){
  # Create an html document from the url
  webpage <- xml2::read_html(url)

  # Extract the URLs
  webpage %>%
    # refers to java script where hyperlinks are indicated with
    # an "a" at the start of the text
    rvest::html_nodes("a") %>%
    # refers to java script, specifically the attribute
    # information, which is actual hyperlink
    rvest::html_attr("href")
  # # renames the link_ and url_ variables to link and url respectively
}


#' For a provided url, returns links associated with statistical collections
#' @name collect_collections
#' @param url URL of the web page to scrape urls from

collect_collections <- function(url){
  # get hyperlinks to DfT topic areas found on the Statistics at DfT webpage,
  # fitering for collections only
  collections <-  scrape_links(stats_url)[
    grepl("statistics/transport|statistics/developing-faster|^https://www.gov.uk/government/collections/+", scrape_links(stats_url))] %>%
    ##Convert to list
    as.list()

  #Name the list with the names of the collections
  names(collections) <- unlist(collections)

  collections
}


#' For a provided url, returns links associated with uploaded statistical publication files
#' @name collect_links
#' @param url URL of the web page to scrape urls from

collect_links <- function(url){
  # use the unique number to identify the URL to be used for each collection

  links <- scrape_links(url) %>%
    unique()

  ##Relative links, add the url starter

  links <- links[grepl("/government/statisti|uploads", links)]

  ##Append if needed
  purrr::map_vec(.x = links,
                 .f = ~ifelse(!grepl("^https", .x,),
                              paste0("https://www.gov.uk", .x),
                              .x))


}


#' For a provided url, returns urls of uploaded ODS and CSV files associated with statistical publications
#' @name scrape_tables
#' @param url URL of the web page to scrape urls from
scrape_tables <- function(url){

  links <- purrr::map(.x = url,
                      .f = scrape_links) %>%
    unlist()

  ##Keep only upload links for ods/csv files
  tibble(
    urls = links[grepl(".ods$|.csv$", links)])

}

