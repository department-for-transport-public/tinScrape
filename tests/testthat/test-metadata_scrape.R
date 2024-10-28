library(testthat)
library(dplyr)
library(purrr)
library(tibble)

#Download cover tests ####

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
  local_mocked_bindings(
    gcs_list_objects = function(bucket_name) {
      tibble(name = "missing_table.csv", updated = Sys.Date())
    }
  )

  expect_error(download_cover("example_table"))
  expect_error(download_cover("example_table"), "File example_table not found")


}
)

###Extract metadata tests-----
# Mock functions to avoid actual processing
local_mocked_bindings(
  gcs_list_objects = function(bucket_name) {
    tibble(name = "example_table.ods", updated = Sys.Date())
  },

  download_cover = function(df_name) {
    tibble(
      info = c("user@example.com", "January 2024", "March 2023"),
      text = c("email", "published on", "Next published"),
      source = df_name
    )
})


test_that("extract_metadata handles single valid .ods file", {
  result <- extract_metadata("bucket_name")

  # Check that result is a tibble
  expect_true(is_tibble(result))

  # Check that the tibble has the right columns and values
  expect_equal(names(result), c("source", "email", "last_update", "next_update"))
  expect_equal(result$email, "user@example.com")
  expect_equal(result$last_update, "January 2024")
  expect_equal(result$next_update, "March 2023")

})

test_that("extract_metadata returns error when no files are present", {
  # Mock external dependencies for no files scenario
  local_mocked_bindings(
    gcs_list_objects = function(bucket_name) {
      tibble(name = character(), updated = as.Date(character()))
    }
  )

    expect_error(extract_metadata("bucket_name"))
    expect_error(extract_metadata("bucket_name"), "No objects found in bucket ")

    }
)


test_that("extract_metadata returns error when no ods files are present", {
  # Mock external dependencies for no files scenario
  local_mocked_bindings(
    gcs_list_objects = function(bucket_name) {
      tibble(name = c("example.csv", "example.png", "example.ods"),
             updated = c(Sys.Date(), Sys.Date(), as.Date("2020-01-01")))
    }
  )

  expect_error(extract_metadata("bucket_name"))
  expect_error(extract_metadata("bucket_name"), "No ods objects found for most recent date")

}
)


test_that("extract_metadata correctly handles files with missing info", {
  # Mock external dependencies for missing metadata scenario
  local_mocked_bindings(
    download_cover = function(df_name) {
      tibble(
        info = c(NA_character_, "January 2024", "March 2023"),
        text = c(NA_character_, "updated", "next update"),
        source = df_name
      )
    }
  )

  result <- extract_metadata("bucket_name")

  # Check that the result is a tibble
  expect_true(is_tibble(result))

  # Check that rows with missing info are removed
  expect_equal(names(result), c("source", "last_update", "next_update"))
  expect_equal(result$last_update, "January 2024")
  expect_equal(result$next_update, "March 2023")

})

test_that("extract_metadata handles multiple .ods files with different metadata", {
  # Mock external dependencies for multiple files scenario

  local_mocked_bindings(
    gcs_list_objects = function(bucket_name) {
      tibble(
        name = c("example_table1.ods", "example_table2.ods"),
        updated = c(Sys.Date(), Sys.Date())
      )
    },

    download_cover = function(df_name) {
      if (df_name == "example_table1.ods") {
        tibble(
          info = c("user1@example.com", "February 2023"),
          text = c("email", "Updated on"),
          source = df_name
        )
      } else {
        tibble(
          info = c("user2@example.com", "March 2023"),
          text = c("email", "Next update"),
          source = df_name
        )
      }
    })

      result <- extract_metadata("bucket_name")

      # Check that result is a tibble
      expect_true(is_tibble(result))

      # Check that the tibble contains data from both files
      expect_equal(result$email[1], "user1@example.com")
      expect_equal(result$email[2], "user2@example.com")
      expect_equal(result$last_update[1], "February 2023")
      expect_true(is.na(result$last_update[2]))
      expect_equal(result$next_update[2], "March 2023")
      expect_true(is.na(result$next_update[1]))

})

