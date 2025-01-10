#' Download the cover sheet from a published ORR table
#'
#' This function downloads the most recent ORR table that matches the provided
#' name from a Google Cloud Storage (GCS) bucket and extracts the cover sheet
#' containing relevant metadata such as emails and dates.
#' @name download_cover
#' @param df_name A string representing the name of the ORR table to be downloaded.
#' The function will look for tables in the specified GCS bucket that match this string (case-insensitive).
#' @param bucket_name A string representing the name of the GCS bucket from which the table will be downloaded. Default is `"tin_dev_orr_storage"`.
#'
#' @return A tibble containing two types of metadata:
#' - Emails: rows containing email addresses found on the cover sheet.
#' - Dates: rows containing date information found on the cover sheet.
#' If no cover sheet is found, the tibble will contain `NA` values for the columns `info`, `text`, and `source`.
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom tidyr separate
#' @importFrom purrr is_empty
#' @importFrom readODS list_ods_sheets read_ods
#' @importFrom googleCloudStorageR gcs_list_objects gcs_get_object
#' @importFrom tibble tibble
#' @export

download_orr_cover <- function(df_name, bucket_name = "tin_dev_orr_storage") {
  f <- tempfile()
  
  # read in list of published tables
  full_table_list <- gcs_list_objects(bucket_name) %>%
    dplyr::filter(grepl("table-", name)) %>% 
    dplyr::filter(grepl(df_name, name, ignore.case = TRUE)) %>%
    dplyr::arrange(desc(updated)) %>%
    dplyr::slice(1L) %>%
    dplyr::pull(name)
  
  ##If no file is returned, give an error
  if(length(full_table_list) == 0){
    stop("File ", df_name, " not found")
  }
  
  # download the file using the URL
  gcs_get_object(
    bucket = bucket_name,
    full_table_list,
    overwrite = TRUE,
    saveToDisk = f
  )
  
  # extract the names of the different worksheets in the workbook
  sheets <- list_ods_sheets(f)
  ##Keep just the cover sheet
  sheets <- sheets[grepl("cover", sheets, ignore.case = TRUE)]
  
  if (!purrr::is_empty(sheets)) {
    cover_info <- read_ods(path = f,
                           sheet = sheets[1],
                           # remove any mentions of [x] and .. from worksheets
                           na = c("[x]", ".."))[1]
    
    cover_info <- read_ods(f, sheets[1], na = c("[x]", ".."))
    ##Set column name
    names(cover_info) <- "column1"
    
    ##Make a nice string of month names
    month_nms <- paste(month.name, collapse = "|")
    
    ##Get emails
    emails <- cover_info %>%
      dplyr::filter(!is.na(column1)) %>%
      ##Let's try and detect dates generally
      dplyr::filter(grepl("@|orr.gov.uk", column1, ignore.case = TRUE)) %>%
      tidyr::separate(col = column1,
                      sep = " \\(",
                      into = c("info", "text")) %>%
      dplyr::mutate(text = "ORR rail statistics") %>% 
      dplyr::select(text, info) %>% 
      dplyr::mutate(source = df_name)
    
    ##Get rid of na values
    dates <- cover_info %>%
      dplyr::filter(!is.na(column1)) %>%
      ##Let's try and detect dates generally
      dplyr::filter(grepl(month_nms, column1, ignore.case = TRUE),
                    grepl(" published at 09:30 on |The next publication date is ", 
                          column1)) %>%
      ##Split into date info and other stuff
      dplyr::mutate(info = dplyr::case_when(
        grepl(
          paste0("(", month_nms, ")", " \\d{4}"),
          ignore.case = TRUE,
          column1
        ) ~
          gsub(
            paste0(".*(", month_nms, ") (\\d{4}).*"),
            "\\1 \\2",
            ignore.case = TRUE,
            column1
          )
      )) %>%
      dplyr::mutate(source = df_name, 
                    text = as.character(column1),
                    text = dplyr::case_when(
                      grepl(" published at ", text, 
                            ignore.case = TRUE) == TRUE ~ "last_updated",
                      grepl("^ORR rail statistics$", text, 
                            ignore.case = TRUE) == TRUE ~ "email",
                      TRUE ~ "next_update")) %>%
      dplyr::select(-column1)
    
    info <- bind_rows(emails, dates)
    
  } else {
    info <- tibble::tibble("info" = NA_character_,
                           "text" = NA_character_,
                           "source" = df_name)
  }
  
  unlink(f)
  return(info)
}

#' Extract metadata from the most recent ORR files in a Google Cloud Storage bucket
#'
#' This function extracts metadata from the most recent `.ods` ORR files in a 
#' specified Google Cloud Storage (GCS) bucket. It uses the `download_orr_cover` 
#' function to retrieve the cover sheet metadata (emails and dates) and processes 
#' it into a tidy format.
#'
#' @name extract_metadata
#' @param bucket_name A string representing the name of the GCS bucket from which the metadata will be extracted.
#'
#' @return A tibble containing the metadata (e.g., email, next_update, last_update) from the most recent `.ods` files.
#'
#' @importFrom purrr possibly map list_rbind
#' @import dplyr
#' @importFrom tidyr pivot_wider
#' @importFrom googleCloudStorageR gcs_list_objects
#' @export


extract_orr_metadata <- function(bucket_name = "tin_dev_orr_storage") {
  ##Use function safely
  download_cover_meta <-  purrr::possibly(download_orr_cover)
  
  ##Check there are any bucket objects
  all_bucket_objects <- gcs_list_objects(bucket_name)
  
  if(nrow(all_bucket_objects) == 0){
    
    stop("No objects found in bucket ", bucket_name)
    
  }
  
  ##Check there are relevant bucket objects
  all_bucket_objects <- all_bucket_objects %>%
    ##Keep only most recent files
    dplyr::mutate(updated = as.Date(updated)) %>%
    dplyr::filter(updated == max(updated, na.rm = TRUE), grepl("[.]ods$", name))
  
  if(nrow(all_bucket_objects) == 0){
    
    stop("No ods objects found for most recent date")
    
  }
  
  ##Extract all objects in the bucket
  all_updates <-  all_bucket_objects %>%
    ##Keep names only
    dplyr::pull(name) %>%
    purrr::map(.f = download_cover_meta) %>%
    ##Turn into a dataframe
    purrr::list_rbind() %>%
    ##Remove NA info
    dplyr::filter(!is.na(info)) %>%
    dplyr::mutate(
      text = dplyr::case_when(
        grepl("email|ORR rail statistics", text, ignore.case = TRUE) ~ "email",
        grepl("next|(provisional update)", text, ignore.case = TRUE) ~ "next_update",
        grepl("updated|( published on)", text, ignore.case = TRUE) ~ "last_update")) %>%
    dplyr::filter(!is.na(text)) %>%
    unique() %>%
    tidyr::pivot_wider(names_from = "text", values_from = "info")
  
  return(all_updates)
}
