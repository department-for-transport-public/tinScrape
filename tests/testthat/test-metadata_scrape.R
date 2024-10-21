library(testthat)
library(dplyr)
library(purrr)
library(tibble)

# Mock functions to avoid actual processing
local_mocked_bindings(
  gcs_list_objects = function(bucket_name) {
    tibble(name = "example_table.ods", updated = Sys.Date())
  },

  gcs_get_object = function(bucket, object_name, overwrite, saveToDisk) {
    # Assume file saved successfully
  },

  list_ods_sheets = function(file) {
    c("Cover Sheet", "Data")
  },

  read_ods = function(path, sheet, na) {
    tibble(column1 = c("Email: user@example.com", "Updated: January 2024"))
  }
)

test_that("download_cover returns a tibble with expected columns", {
  result <- download_cover("example_table")

  #Check that result is a tibble
  expect_true(is_tibble(result))

  # Check that the columns are as expected
  expect_equal(names(result), c("text", "info", "source"))

  # Check for correct data
  expect_equal(result$info[1], " user@example.com")
  expect_equal(result$info[2], "January 2024")
}
)

test_that("download_cover correctly detects date and email formats", {

  ##Mock sheet content
  local_mocked_bindings(

    read_ods = function(path, sheet, na) {
      tibble(column1 = c(
        "Email: user@example.com",      # Non-date (email)
        "Updated: January 2024",        # Date format
        "Next review: March 2023",      # Date format
        "This is not a date string Feb 2021",      # Non-date
        "Published: February 2022",     # Date format
        "Contact: another@example.com"  # Non-date
      ))
    }
  )

      result <- download_cover("example_table")

      # Check that dates are properly detected
      expect_equal(result$info[2], "January 2024")
      expect_equal(result$info[3], "March 2023")
      expect_equal(result$info[4], "February 2022")

      ##Check that emails are properly detected
      expect_equal(result$info[1], " user@example.com")
      expect_true(is.na(result$info[5]))

    }
  )


test_that("download_cover returns NA tibble when no cover sheet is found", {
  # Mock external dependencies for no cover sheet scenario
  local_mocked_bindings(
    list_ods_sheets = function(file) {
      c("Data")
    }
  )

  result <- download_cover("example_table")

  # Check that result is a tibble
  expect_true(is_tibble(result))

  # Check that the tibble contains NA values as expected
  expect_true(all(is.na(result$info)))
  expect_true(all(is.na(result$text)))
})

test_that("download_cover handles missing or invalid .ods file", {
  # Mock external dependencies for invalid file scenario
  mock_gcs_list_objects <- function(bucket_name) {
    tibble(name = "invalid_file.csv", updated = Sys.Date())
  }

  mock_gcs_get_object <- function(bucket, object_name, overwrite, saveToDisk) {
    # No valid file downloaded
  }

  # Use mocking
  mockr::with_mock(
    `googleCloudStorageR::gcs_list_objects` = mock_gcs_list_objects,
    `googleCloudStorageR::gcs_get_object` = mock_gcs_get_object,

    {
      result <- download_cover("example_table")

      # Check that result is a tibble with NA values
      expect_true(is_tibble(result))
      expect_true(all(is.na(result$info)))
    }
  )
})
#
# test_that("download_cover returns empty tibble when no matching tables are found", {
#   # Mock external dependencies for no matching files
#   mock_gcs_list_objects <- function(bucket_name) {
#     tibble(name = character(), updated = as.Date(character()))
#   }
#
#   # Use mocking
#   mockr::with_mock(
#     `googleCloudStorageR::gcs_list_objects` = mock_gcs_list_objects,
#
#     {
#       result <- download_cover("non_existent_table")
#
#       # Check that result is a tibble with NA values
#       expect_true(is_tibble(result))
#       expect_true(all(is.na(result$info)))
#     }
#   )
# })
