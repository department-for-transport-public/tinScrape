#' To tidy published DfT data, stored in GCP, and move to BigQuery
#' @name gcp_to_bq
#' @param file_name DfT code for published table.
#' @return A tidied, machine readable version of the table, in a long format, in BQ.
#' @export
#' @import dplyr
#' @importFrom purrr map map_df
#' @importFrom Rmpfr mpfr

gcp_to_bq <- function(file_name){
  
  file_name <- toupper(file_name)
  
  message("Processing ", file_name)
  
  # download the table into the R environment. Enter dft code in speech marks
  sheets_to_r <- table_to_bq(file_name)
  
  ##Set up a safe version of tidied_df that doesn't break the loop
  safe_tidying <- purrr::possibly(tidied_df,
                                  quiet = FALSE)
  
  # apply the function to tidy datasets across list of data sheets in data_sheets
  # and save them as lists, named after the names of the worksheets
  tidy_data <- purrr::map(sheets_to_r, safe_tidying)
  
  ##Remove punctuation from sheet names
  sheet_names <- gsub("[^[:alnum:]_\\-]", "", names(sheets_to_r)) %>%
    gsub("\\-", "_", .)
  
  tidy_data <- tidy_data %>%
    purrr::set_names(sheet_names)
  
  purrr::map2(.x = tidy_data,
              .y = names(tidy_data),
              .f = bq_tableizer,
              # convert any hyphens in the name of the workbook to underscores
              file_name = file_name)
  
}