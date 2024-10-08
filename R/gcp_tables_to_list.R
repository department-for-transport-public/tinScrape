# function to download a published table, using the TS Finder list
gcp_tables_to_list <- function(df_name){
  f <- tempfile()

  # read in list of published tables, from the TS Finder project
  full_table_list <- gcs_list_objects("tin_dev_data_storage") %>%
    dplyr::filter(grepl(df_name, name, ignore.case = TRUE)) %>%
    dplyr::arrange(desc(updated)) %>%
    dplyr::slice(1L) %>%
    dplyr::pull(name)

  # download the file using the URL
  gcs_get_object(bucket = "tin_dev_data_storage",
                 full_table_list,
                 overwrite = TRUE,
                 saveToDisk = f)

  ##Read in all tables of data
  odsTableReadr::read_all_tables(f) %>%
    # remove any worksheets with only 1 column
    rlist::list.filter(!(ncol(.) == 1))

}
