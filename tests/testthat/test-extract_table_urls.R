test_that("no errors are returned", {
  expect_no_error(extract_table_urls())
})

test_that("no NA values are returned", {
  raw_values <- extract_table_urls()

  expect_equal(nrow(raw_values), nrow(na.omit(raw_values)))

})

test_that("column classes are correct", {
  raw_values <- extract_table_urls()

  expect_equal(class(raw_values$collection_url), "character")
  expect_equal(class(raw_values$doc_url), "character")
  expect_equal(class(raw_values$file_name), "character")
  expect_equal(class(raw_values$upload_id), "integer")

})
