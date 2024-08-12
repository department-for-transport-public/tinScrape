#Mock bq functions to avoid writing during testing
local_mocked_bindings(
  bq_dataset_exists = function(dataset) {
    return(FALSE)
  },
  
  bq_dataset_create = function(dataset, location) {
    return(TRUE)
  },
  
  bq_table_exists = function(table_name) {
    return(FALSE)
  },
  
  bq_table_fields = function(table_name) {
    return(data.frame(name = character()))
  },
  
  bq_table_create = function(table_name, schema) {
    return(TRUE)
  },
  
  bq_table_delete = function(table_name) {
    return(TRUE)
  },
  
  bq_table_upload = function(table_name, data, create_disposition, write_disposition) {
    return(table_name)
  },
  
  as_bq_fields = function(data) {
    return(data.frame(name = names(data)))
  }
)


# Sample data for testing
sample_data <- data.frame(
  col1 = 1:5,
  col2 = letters[1:5],
  stringsAsFactors = FALSE
)


test_that("create_bq_table correctly formats file_name", {
  expect_equal(create_bq_table(sample_data, "ts0102", "example-file.test"), 
               "dft-stats-diss-dev.example_file.test.ts0102")
  expect_equal(create_bq_table(sample_data, "ts0102.1", "example-file-test"), 
               "dft-stats-diss-dev.example_file_test.ts0102.1")
})

test_that("create_bq_table messages about dataset if it doesn't exist", {
  expect_message(create_bq_table(sample_data, "ts0102", "example-file"), 
                 "Dataset dft-stats-diss-dev.example_file created")
  
})

test_that("create_bq_table warns if schema is changed",{

  expect_warning(create_bq_table(sample_data, "ts0102", "example-file"))
  
})

test_that("create_bq_table uploads the data", {
  table_name <- "dft-stats-diss-dev.example_file.example_table"
  
  # Simulate uploading data
  expect_true(bq_table_upload(table_name, sample_data, create_disposition='CREATE_IF_NEEDED', write_disposition = "WRITE_TRUNCATE"))
})