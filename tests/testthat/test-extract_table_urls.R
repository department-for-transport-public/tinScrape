test_that("no errors are returned", {
  expect_no_error(extract_table_urls())
})

test_that("no NA values are returned", {
  raw_values <- extract_table_urls()

  expect_equal(nrow(raw_values), nrow(na.omit(raw_values)))

})
