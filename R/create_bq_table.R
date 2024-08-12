#' For a provided table, create and upload a table to BigQuery
#' @name create_bq_table
#' @param x Name of dataset
#' @param name Name of workbook
#' @param file_name Name of worksheet
#' @return The creation and uploading of a tidied dataset in BigQuery
#' @export
#' @import dplyr
#' @import bigrquery
#' @import googleCloudStorageR
#' @importFrom purrr map map_df map_vec

create_bq_table <- function(x, name, file_name){
  
  file_name <- gsub("-", "_", file_name, fixed = TRUE)
  file_name <- gsub("\\\\.*", "", file_name)
  
  ##Check if dataset exists and create if not
  if(!bq_dataset_exists(paste0("dft-stats-diss-dev.", file_name))){
    bq_dataset_create(paste0("dft-stats-diss-dev.", file_name),
                      location = "europe-west2")
  }
  
  ##Temp object from x
  data <- x
  ##Create table name
  table_name <- paste("dft-stats-diss-dev", file_name, name, sep = ".")
  
  ##Delete the table if it already exists and the schema doesn't match
  if(bq_table_exists(table_name)){
    
    ##Get schemas
    current <- bq_table_fields(table_name) %>%
      purrr::map_vec(.f = ~ .x$name)
    
    new <- as_bq_fields(data) %>%
      purrr::map_vec(.f = ~ .x$name)
    
    ##If schemas don't match, delete whole table, but also warn
    if(!identical(new, current)){
      
      warning("Schema for ", table_name, " changed")
      bq_table_delete(table_name)
      bq_table_create(table_name,
                      as_bq_fields(data))
    }
  } else{
    bq_table_create(table_name,
                    as_bq_fields(data))
  }
  
  bq_table_upload(table_name,
                  data,
                  create_disposition='CREATE_IF_NEEDED',
                  write_disposition = "WRITE_TRUNCATE")
  
}