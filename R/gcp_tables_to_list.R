#' To tidy published DfT data, stored in GCP, and move to BigQuery
#' @name gcp_tables_to_list
#' @param file_name DfT code for published table.
#' @param bucket_name Name of the GCS bucket that contains the data to be moved into BQ. Locations that exist are "tin_dev_data_storage" for DfT tables and "tin_dev_orr_storage" for ORR tables.
#' @return A list of raw data tables from the file in question, with one table per list item.
#' @export
#' @import dplyr
#' @importFrom odsTableReadr read_all_tables
#' @importFrom googleCloudStorageR gcs_get_object
#' @importFrom rlist list.filter
#' @importFrom magrittr "%>%"

# function to download a published table, using the TS Finder list
gcp_tables_to_list <- function(file_name, bucket_name){
  f <- tempfile()

  # read in list of published tables, from the TS Finder project
  full_table_list <- gcs_list_objects(bucket_name) %>%
    dplyr::filter(grepl(file_name, name, ignore.case = TRUE)) %>%
    dplyr::arrange(desc(updated)) %>%
    dplyr::slice(1L) %>%
    dplyr::pull(name)

  # download the file using the URL
  gcs_get_object(bucket = bucket_name,
                 full_table_list,
                 overwrite = TRUE,
                 saveToDisk = f)

  ##Read in all tables of data
  odsTableReadr::read_all_tables(f) %>%
    # remove any worksheets with only 1 column
    rlist::list.filter(!(ncol(.) == 1))

}
