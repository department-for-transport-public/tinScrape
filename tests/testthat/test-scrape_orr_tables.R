# Load necessary libraries
library(testthat)
library(tibble)
library(dplyr)

local_file <- "../data/passenger-rail-usage.html"

test_that("extract_orr_urls returns a tibble of expected size", {
  result <- extract_orr_urls(local_file)
  # Test that the result is a tibble
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 13)
  expect_equal(ncol(result), 4)
})

test_that("extract_orr_urls has the correct columns", {

  result <- extract_orr_urls(local_file)
  expect_equal(c("file_name", "doc_url", "collection_url", "upload_id"),
               colnames(result))

})

test_that("file_name column contains expected values", {

  result <- extract_orr_urls(local_file)

  ##All files have a name
  expect_true(all(!is.na(result$file_name)))
  #All names start with table and only have one slash at the end
  expect_true(all(grepl("^table.*[/]$", result$file_name)))
})

test_that("doc_url column contains valid URLs", {
  result <- extract_orr_urls(local_file)

  expect_true(all(grepl("^https?://", result$doc_url)))
})

test_that("collection_url column matches input file path", {
  result <- extract_orr_urls(local_file)

  # Check if collection_url matches the file path passed as input
  expect_true(all(result$collection_url[1] == local_file))
})

test_that("upload_id is correctly set", {
  result <- extract_orr_urls(local_file)

  # Test that the upload_id is always 1
  expect_true(all(result$upload_id == 1))
})
