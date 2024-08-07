#' For a given vatiable, check if it includes year information
#' @name year_column_check
#' @param col Name of the variable to check
#' @return Returns a true or false value as to whether the variable contains year data, and meets the checks included. Checks include if the length of the value is 4, numeric and starts with '19' or '20'.
#' @export
#' @import dplyr

year_column_check <- function(col){
  
  # test if length of values in column are 4
  length_test <- all(nchar(col) == 4)
  
  # test if the class of the column is numeric, integer or double
  class_test <- is.numeric(col) | is.integer(col) | is.double(col)
  
  # test if there are NA values for all rows. If so, unlikely to be year data
  na_test <- all(!is.na(col))
  
  # test to see if the first two characters in all rows of data start with 19
  # or 20, representing 19xx or 20xx values
  values_test <- all(substr(col, 1, 2) %in% c("19", "20"))
  
  return(sum(length_test, class_test, na_test, values_test) == 4)
}
