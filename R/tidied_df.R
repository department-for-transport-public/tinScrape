#' Tidies tables in ODS workbooks and converts to long format
#' @name tidied_df
#' @param data Name of the dataset to tidy, which will be the name of the worksheet in the ODS workbook
#' @return A tidied, long table that has a value and grouped_var column, and a column stating the date and time of when the dataset was tidied, at a minimum
#' @export
#' @import utils
#' @importFrom purrr map map_df map_vec
#' @importFrom stringr str_replace
#' @importFrom tibble as_tibble
#' @importFrom dplyr mutate_at mutate_if mutate
#' @importFrom janitor clean_names
#' @importFrom tidyr pivot_longer

# function to convert ODS table into tidy format
tidied_df <- function(data){

  prep_df <- tibble::as_tibble(data)

  ##Remove notes from column names
  names(prep_df) <- stringr::str_replace(
    names(prep_df), "(| )\\[.*\\]", "")

  prep_df <- prep_df %>%
    janitor::clean_names(use_make_names = FALSE) %>%
    # remove any mention of " []" text in the table, and their contents
    dplyr::mutate_at(vars(
      dplyr::everything()),
      ~ stringr::str_replace(., "(| )\\[.*\\]|Zero value", "")) %>%
    # automatically set appropriate classes for variables
    utils::type.convert(as.is = TRUE) %>%
    ##Convert integer to numeric we're not about that life
    dplyr::mutate_if(is.integer, as.numeric) %>%
    # remove any mentions of notes and revised/revisions in table
    .[!grepl("note|revis", names(.), ignore.case = TRUE)]


  # must pass all checks above to be considered to be a year column
  year_column <- grep("TRUE", purrr::map_vec(prep_df, year_column_check))


  # find the text columns
  df_text_classes <- grep("character", purrr::map(prep_df, class))

  ##Check if any columns are left!
 if(ncol(prep_df) ==
    sum(1:ncol(prep_df) %in% c(df_text_classes, year_column), na.rm = TRUE)){

   stop("No columns in correct format for tidying.
        Please ensure there is at least one numeric column which does not contain a year value")

 }

  tidy_df <-
    suppressWarnings(
    prep_df %>%
    # change the format of dataframe from wide to long, where all text columns and the year column are excluded
    tidyr::pivot_longer(
      cols = -c(df_text_classes, year_column),
      names_to = "grouped_var",
      values_to = "value"
    ) %>%
    # create variable stating time of last update
    dplyr::mutate(date_updated = Sys.time()))

  ##Clean up the column names to exclude characters BQ doesn't accept
  names(tidy_df) <- gsub("[^[:alnum:]]", "_", names(tidy_df))

  return(tidy_df)

}
