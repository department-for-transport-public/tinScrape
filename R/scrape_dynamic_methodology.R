#' For a provided url, return those stats which have dynamically updating methdology links
#' @name scrape_odd_methodology
#' @param url URL of the web page to scrape urls from. Defaults to the gov.uk stats homepage
#' @return a table containing two columns, the collection url and the methodoloy url
#' @export
#' @importFrom dplyr filter
#' @importFrom purrr map list_rbind
#' @importFrom magrittr "%>%"
#'
##Scrape the odd dynamic methodology
scrape_odd_methodology <- function(url = "https://www.gov.uk/government/organisations/department-for-transport/about/statistics"){
  ##Get the collection links
  links <- collect_collections(url)

  ##Keep the top stats answer for each page
  keep_1 <- function(x){

    x <- x[grepl("statistics[/](national|walking)", x)]
    x[1]
  }

  ##Keep just the two we need
  purrr::map(.x = links[grepl("travel-attitudes|walking", links)],
             .f = collect_links) %>%
    ##Keep the most recent stats for each page
    purrr::map(.f = keep_1) %>%
    ##Get the links on those pages
    purrr::map(.f = collect_links) %>%
    ##Turn into a data frame
    purrr::map(.f = ~tibble(methodology = .x)) %>%
    purrr::list_rbind(names_to = "collection") %>%
    ##Keep only technical/methodology pages
    dplyr::filter(grepl("technical|methodology", methodology))
}

