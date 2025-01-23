#' For a provided ORR url, return those stats which have dynamically updating methodology links
#' @name scrape_orr_methodology
#' @param url URL of the ORR web page to scrape urls from
#' @return a table containing two columns, the collection url and the methodology url
#' @export
#' @importFrom dplyr filter
#' @importFrom purrr map list_rbind
#' @importFrom magrittr "%>%"
#'
##Scrape the odd dynamic methodology
scrape_orr_methodology <- function(url){
  
##Get the collection links
  links <- scrape_links(url) %>% 
    ##Turn into a data frame
    purrr::map(.f = ~tibble(methodology = .x)) %>%
    purrr::list_rbind(names_to = "element_number") %>% 
    dplyr::filter(grepl("quality-report.pdf$", methodology, ignore.case = TRUE)) %>% 
    dplyr::mutate(collection = url,
                  methodology = paste0("https://dataportal.orr.gov.uk", methodology)) %>% 
    dplyr::select(collection, methodology) %>% 
    unique()
  
}
