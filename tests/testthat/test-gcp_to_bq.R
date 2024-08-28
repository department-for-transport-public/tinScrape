library(testthat)
library(purrr)

# Mock functions to avoid actual processing
local_mocked_bindings(
  table_to_bq = function(file_name) {
    return(list(sheet1 = data.frame(col1 = 1:3, col2 = letters[1:3]),
                sheet2 = data.frame(col1 = 4:6, col2 = letters[4:6])))
  },

  tidied_df = function(df) {
    return(df %>%
             dplyr::mutate(col3 = col1 * 2))
  },

  bq_tableizer = function(data, name, file_name) {

    return(data)
  }
)

test_that("gcp_to_bq processes file_name correctly", {
  expect_message(gcp_to_bq("table1"), "Processing TABLE1")
  expect_message(gcp_to_bq("TABLEtable"), "Processing TABLETABLE")
  expect_message(gcp_to_bq("Test1"), "Processing TEST1")
})

test_that("gcp_to_bq returns the expected sheets", {

 expect_named(gcp_to_bq("table1"), c("sheet1", "sheet2"))

})


test_that("gcp_to_bq cleans sheet names", {
  ##Create table with cleanable names
  local_mocked_bindings(
    gcp_tables_to_list = function(file_name) {
      return(list("sheet.3!" = data.frame(col1 = 1:3, col2 = letters[1:3]),
                  "sheet(4)" = data.frame(col1 = 4:6, col2 = letters[4:6])))
    }
  )

  expect_named(gcp_to_bq("table1"), c("sheet3", "sheet4"))
})

test_that("gcp_to_bq handles errors in tidying function gracefully", {
  local_mocked_bindings(
    gcp_tables_to_list = function(file_name) {
      return(list("sheet.3!" = data.frame(col1 = 1:3, col2 = letters[1:3]),
                  "sheet(4)" = "Error time"))
    }
  )

  expect_no_error(gcp_to_bq("table1"))
})
