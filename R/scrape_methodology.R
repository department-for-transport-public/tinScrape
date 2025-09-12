#' For a provided DfT URL, return the documents that have dynamically updating methodology links.
#' @name scrape_methodology
#' @param url URL of the DfT web page to scrape URLs from.
#' @return A table containing two columns, the collection URL and the methodology URL.
#' @export
#' @importFrom purrr map_vec
#' @importFrom magrittr "%>%"
#' @importFrom xml2 read_html
#' @importFrom tibble tibble
#' @import rvest

##Scrape methodology notes for publications
scrape_methodology <- function(url){
  
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
  links <- links[grep("information|technical|guidance", 
                      link_names, 
                      ignore.case = TRUE)] %>%
    # Get the actual hyperlink attribute
    rvest::html_attr("href")
  
  ##Drop anything that starts with a # or is the guidance and regulation bit
  links <- links[!grepl("^#|search[/]", links)]
  
  ##Append if needed
  tibble::tibble(
    methodology = purrr::map_vec(.x = links,
                                 .f = ~ifelse(!grepl("^https", .x,),
                                              paste0("https://www.gov.uk", .x),
                                              .x))) %>%
    unique()
  
}