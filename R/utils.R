##Convert to numerics without warnings
#' @export
as.numeric.silent <- function(x){
  suppressWarnings(as.numeric(x))
}


#' For a provided url, reads in the page and extracts all the link addresses from that page
#' @name scrape_links
#' @param url URL of the web page to scrape urls from
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_attr

scrape_links <- function(url){
  # Create an html document from the url
  webpage <- xml2::read_html(url)

  # Extract the URLs
  webpage %>%
    # refers to java script where hyperlinks are indicated with
    # an "a" at the start of the text
    rvest::html_nodes("a") %>%
     ##Find all hyperlinks, drop anything that's a related link
    rvest::html_nodes(xpath =
                        "../a[not(contains(@class, 'gem-c-related'))]") %>%
    # Get the actual hyperlink attribute
    rvest::html_attr("href")
}


#' For a provided url, returns links associated with statistical collections
#' @name collect_collections
#' @param url URL of the web page to scrape urls from

collect_collections <- function(url){
  # get hyperlinks to DfT topic areas found on the Statistics at DfT webpage,
  # fitering for collections only
  collections <-  scrape_links(url)

  collections <- collections[
    grepl("(statistics[/](t|d))|collections[/]", collections)] %>%
    unique() %>%
    ##Convert to list
    as.list()

  #Name the list with the names of the collections
  names(collections) <- unlist(collections)

  return(collections)
}


#' For a provided url, returns links associated with uploaded statistical publication files
#' @name collect_links
#' @param url URL of the web page to scrape urls from
#' @importFrom purrr map_vec

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
#' @importFrom purrr map


scrape_tables <- function(url){

  links <- purrr::map(.x = url,
                      .f = scrape_links) %>%
    unlist()

  ##Keep only upload links for ods/csv files
  tibble(
    urls = links[grepl(".ods$|.csv$", links)])

  }

# capitalise first letter of string
upper_case <- function(x){

  # extract first letter of string, and make capital
  paste(toupper(substring(x, 1, 1)),
        # make subsequent letters lowercase
        tolower(substring(x, 2, nchar(x))),
        sep = "")

}


##Scrape methodology notes for publications
scrape_method <- function(url){

  webpage <- xml2::read_html(url)

  # Extract the URLs that are govuk-links
  links <- webpage %>%
    ##Drop anything that's a related link or a footer
    rvest::html_nodes(xpath =
                        "//a[not(contains(@class, 'gem-c-related')) and
                      not(contains(@class, 'govuk-footer'))]")


  ##Find the information link
  link_names <- links %>%
    rvest::html_text()

  ##Return the whole links for the information ones
  links <- links[grep("information|technical|guidance", link_names, ignore.case = TRUE)] %>%
    # Get the actual hyperlink attribute
    rvest::html_attr("href")

  ##Drop anything that starts with a # or is the guidance and regulation bit
  links <- links[!grepl("^#|search[/]", links)]

  ##Append if needed
  tibble(
    methodology = purrr::map_vec(.x = links,
                 .f = ~ifelse(!grepl("^https", .x,),
                              paste0("https://www.gov.uk", .x),
                              .x))) %>%
    unique()

}

